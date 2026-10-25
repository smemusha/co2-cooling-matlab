%% Capillary sizing - dP along the length for a range of inner diameters
% Model: REFPROP CO2 properties, Darcy-Weisbach (1-phase) / Friedel (2-phase),
% marched section by section at constant enthalpy (cap_dP_march).
% Inputs : fluid, length, inlet T and P, mass flow, target dP, first ID and
%          ID step, roughness, section length.
% Outputs: cumulative dP vs length for each ID (with Psat line) and, in the
%          Command Window, dP and outlet pressure per ID (green = within ±5 %
%          of the target dP).
clear; clc;

% ================================================================
%  INPUTS
% ================================================================
fld       = 'CO2';
L_total   = 3.5;     % capillary length [m]   (long 3.4, IHR2 2.975, IHR3 3.190, IHR4 2.975)
T_inlet   = -40;     % inlet temperature [°C]
P_inlet   = 30;      % inlet pressure [bar]
m_dot     = 1.89;    % mass flow [g/s]        (long 4.14, IHR2 1.84, IHR3 2.53, IHR4 3.22)
dP_dis    = 8.75;    % target dP [bar]        (long 8, IHR2 8.75, IHR3 8.55, IHR4 8)
D_first   = 0.76;    % first inner diameter [mm]
D_step    = 0.02;    % ID step [mm]
nD        = 10;      % number of diameters
Ep_micro  = 1.1;     % roughness [µm] (annealed Ti grade 2)
dL        = 1.5e-2;  % section length [m]

% ================================================================
D_list = D_first + D_step*(0:nD-1);
figure; hold on; grid on;
fprintf('==== Capillary sizing: dP for %d IDs ====\n', nD);
fprintf('L = %.3f m | m = %.2f g/s | T_in = %.0f °C | P_in = %.0f bar | target dP = %.2f bar\n\n', ...
    L_total, m_dot, T_inlet, P_inlet, dP_dis);
fprintf('  %-8s %10s %10s\n', 'ID [mm]', 'dP [bar]', 'P_out [bar]');
for k = 1:nD
    r = cap_dP_march(fld, D_list(k), m_dot, T_inlet, P_inlet, Ep_micro*1e-6, L_total, dL);
    ok = abs(r.dP_tot - dP_dis) <= 0.05*dP_dis;
    line = sprintf('  %-8.2f %10.2f %10.2f', D_list(k), r.dP_tot, r.P_out);
    if ok, cprintf('_green', '%s   within ±5 %%\n', line); else, fprintf('%s\n', line); end
    plot(r.L, cumsum(r.dP_sec), 'LineWidth', 1.5, 'DisplayName', sprintf('D_{in} = %.2f mm', D_list(k)));
end

legend('Location', 'southwest');
xlabel('Length (m)'); ylabel('Pressure Drop (bar)');
title(sprintf(['ATLAS Capillary Sizing for IHR (2^{nd} Layer)\nMF = %.2f g/s, T_{st} = %.0f\\circC, ' ...
    'P_{in} = %.0f bar, dP_{desired} = %.2f bar, L_{exp} = %.3f m, Ep_{Ti} = %.1f μm'], ...
    m_dot, T_inlet, P_inlet, dP_dis, L_total, Ep_micro));
Psat = refpropm('P', 'T', T_inlet+273.15, 'Q', 0, fld)*1e-2;   % bar
yline(Psat, '--', 'P_{sat}', 'LabelHorizontalAlignment', 'center', ...
    'LabelVerticalAlignment', 'middle', 'LineWidth', 2, 'HandleVisibility', 'off');
xlim([0, L_total]); xticks(0:0.1:L_total);
ylim([0, 10]); yticks(0:1:10);
set(gcf, 'Position', [100, 100, 800, 600]);
