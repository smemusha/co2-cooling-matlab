%% Capillary model - dP along a fixed length
% Model: REFPROP CO2 properties, Darcy-Weisbach (1-phase) / Friedel (2-phase),
% marched section by section at constant enthalpy (cap_dP_march).
% Inputs : fluid, inlet T and P, mass flow, inner diameter, length, roughness,
%          section length.
% Outputs: total dP and outlet pressure in the Command Window; optional plot
%          of cumulative dP vs length.
clear; clc;

% ================================================================
%  INPUTS
% ================================================================
fld      = 'CO2';
T_inlet  = -45;      % inlet temperature [°C]
P_inlet  = 50;       % inlet pressure [bar]
m_dot    = 1.89;     % mass flow [g/s]
D_c_in   = 0.76;     % inner diameter [mm]
L_total  = 3.5;      % length [m]
Ep_micro = 1.1;      % roughness [µm]
dL       = 0.5e-2;   % section length [m]
doPlot   = false;    % true -> plot cumulative dP vs length

% ================================================================
r = cap_dP_march(fld, D_c_in, m_dot, T_inlet, P_inlet, Ep_micro*1e-6, L_total, dL);

fprintf('==== Capillary dP vs length ====\n');
fprintf('D_in = %.2f mm | m = %.2f g/s | T_in = %.1f °C | P_in = %.2f bar | Ep = %.1f µm\n', ...
    D_c_in, m_dot, T_inlet, P_inlet, Ep_micro);
fprintf('Length: %.2f m | dP: %.2f bar | P_out: %.2f bar | two-phase: %s\n', ...
    L_total, r.dP_tot, r.P_out, string(r.two_phase));

if doPlot
    figure; hold on; grid on;
    plot([0 r.L], [0 cumsum(r.dP_sec)], 'LineWidth', 1.6);
    xlabel('Length (m)'); ylabel('Pressure Drop (bar)');
    title(sprintf('Capillary Pressure Drop vs Length (D_{in} = %.2f mm, m = %.2f g/s)', D_c_in, m_dot));
    xlim([0 L_total]);
end
