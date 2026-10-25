%% Capillary model - dP vs mass flow
% Model: REFPROP CO2 properties, Darcy-Weisbach (1-phase) / Friedel (2-phase),
% marched section by section at constant enthalpy (cap_dP_march).
% Inputs : fluid, length, inlet T and P, inner diameter, roughness, mass-flow
%          range, section length.
% Outputs: total dP vs mass flow, each point labelled 1φ / 2φ, and the
%          outlet temperature per flow (variable T_outlet).
clear; clc;

% ================================================================
%  INPUTS
% ================================================================
fld        = 'CO2';
L_total    = 3.400;          % length [m]
T_inlet    = -35;            % inlet temperature [°C]
P_inlet    = 20;             % inlet pressure [bar]
D_c_in     = 1.10;           % inner diameter [mm]
Ep_micro   = 3.3;            % roughness [µm]
mass_flows = 1.8:0.1:4.5;    % [g/s]
dL         = 1.5e-2;         % section length [m]

% ================================================================
n = numel(mass_flows);
total_dP = zeros(n,1); T_outlet = zeros(n,1); twoPhase = false(n,1);
for k = 1:n
    r = cap_dP_march(fld, D_c_in, mass_flows(k), T_inlet, P_inlet, Ep_micro*1e-6, L_total, dL);
    total_dP(k) = r.dP_tot; T_outlet(k) = r.T_out_C; twoPhase(k) = r.two_phase;
end

figure; hold on; grid on;
plot(mass_flows, total_dP, '-', 'LineWidth', 1.5, 'Color', 'm', 'HandleVisibility', 'off');
h1 = plot(mass_flows(~twoPhase), total_dP(~twoPhase), 'o', 'MarkerSize', 8, 'Color', 'm');
h2 = plot(mass_flows(twoPhase), total_dP(twoPhase), 'o', 'MarkerSize', 8, 'Color', 'm', 'MarkerFaceColor', 'm');
xlabel('Mass Flow Rate (g/s)'); ylabel('Total Pressure Drop (bar)');
title(sprintf('Capillary Pressure Drop vs Mass Flow\nI.D. = %.2f mm | T_{in} = %.0f°C | P_{in} = %.0f bar | L = %.0f mm | Ep_{Ti} = %.1f μm', ...
    D_c_in, T_inlet, P_inlet, L_total*1e3, Ep_micro));
legend([h1 h2], {'1\phi: Single-phase flow', '2\phi: Two-phase flow'}, 'Location', 'northwest');

% watermark
wm = text(0.98, 0.03, 'Sara Memushaj', 'Units', 'normalized', 'FontSize', 10, ...
    'FontAngle', 'italic', 'Color', [0.6 0.6 0.6], ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
    'HandleVisibility', 'off', 'HitTest', 'off');
uistack(wm, 'bottom');
