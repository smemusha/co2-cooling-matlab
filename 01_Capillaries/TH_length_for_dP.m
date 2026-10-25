%% Capillary model - length needed for a target dP
% Model: REFPROP CO2 properties, Darcy-Weisbach (1-phase) / Friedel (2-phase),
% marched section by section at constant enthalpy until the target dP is
% reached; the last section is interpolated (cap_dP_march).
% Inputs : fluid, inlet T and P, mass flow, target dP, inner diameter,
%          roughness, section length.
% Outputs: required length and outlet pressure in the Command Window;
%          optional plot of pressure vs length with Psat.
clear; clc;

% ================================================================
%  INPUTS
% ================================================================
fld      = 'CO2';
T_inlet  = -45;      % inlet temperature [°C]
P_inlet  = 50;       % inlet pressure [bar]
m_dot    = 1.89;     % mass flow [g/s]
dP_dis   = 8.75;     % target dP [bar]
D_c_in   = 0.76;     % inner diameter [mm]
Ep_micro = 3.3;      % roughness [µm]
dL       = 0.5e-2;   % section length [m]
doPlot   = false;    % true -> plot pressure vs length

% ================================================================
r = cap_dP_march(fld, D_c_in, m_dot, T_inlet, P_inlet, Ep_micro*1e-6, [], dL, dP_dis);

fprintf('==== Capillary length for target dP ====\n');
fprintf('D_in = %.2f mm | m = %.2f g/s | T_in = %.1f °C | P_in = %.2f bar | Ep = %.1f µm | target dP = %.2f bar\n', ...
    D_c_in, m_dot, T_inlet, P_inlet, Ep_micro, dP_dis);
fprintf('Required length: %.3f m | P_out: %.2f bar | two-phase: %s\n', ...
    r.L_req, r.P_out, string(r.two_phase));

if doPlot
    figure; hold on; grid on;
    plot([0 r.L], r.P, 'LineWidth', 1.6);
    Psat = refpropm('P', 'T', T_inlet+273.15, 'Q', 0, fld)*1e-2;   % bar
    yline(Psat, '--', sprintf('P_{sat} = %.2f bar', Psat), 'LineWidth', 1.5);
    xlabel('Length (m)'); ylabel('Pressure (bar)');
    title(sprintf('Capillary Sizing to Reach \\DeltaP = %.2f bar (D_{in} = %.2f mm, m = %.2f g/s)', ...
        dP_dis, D_c_in, m_dot));
    xlim([0, r.L_req*1.05]);
end
