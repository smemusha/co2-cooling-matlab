clear all
clc

% Constants
fld = 'CO2';
L_total = 3.400;           % Total length of capillary (m)
T_inlet = -35;           % Inlet temperature of CO2 (°C) - known
P_inlet = 20;            % Inlet pressure of CO2 (bar) - known
D_c_in = 1.10;           % Capillary inner diameter (mm)
Ep_Ti = 3.3e-6;          % Roughness (m)
Ep_Ti_micro = 3.3;       % Roughness (μm)

% Mass flow rates (g/s)
mass_flows = 1.8:0.1:4.5;

% Discretization
section_length = 1.5e-2; % Segment length (m)
num_sections = ceil(L_total / section_length);

% Initialize storage
total_dP = zeros(length(mass_flows), 1);
T_outlet = zeros(length(mass_flows), 1);
phase_state = strings(length(mass_flows), 1);

% Loop over mass flows
for mf_iter = 1:length(mass_flows)
    m_dot = mass_flows(mf_iter);         % g/s
    A_cap = pi * ((D_c_in * 1e-3)^2) / 4;
    MFLX = (m_dot * 1e-3) / A_cap;        % kg/m^2s

    % Enthalpy from known inlet conditions
    H = refpropm('H', 'T', T_inlet + 273.15, 'P', P_inlet * 1e2, fld);  % J/kg

    P_inlet_section(1) = P_inlet;
    dP = zeros(1, num_sections);
    x = zeros(1, num_sections);
    T = zeros(1, num_sections);

    for i = 1:num_sections
        [T(i), rho(i), x(i)] = refpropm('TDQ', 'P', P_inlet_section(i) * 1e2, 'H', H, fld);

        if x(i) < 0 || x(i) > 1
            [dP_temp, ~, ~] = DarcyWeisbach(fld, P_inlet_section(i), H, MFLX, D_c_in * 1e-3, A_cap, Ep_Ti);
        else
            [dP_temp, ~] = FriedelCorrelation(fld, P_inlet_section(i), x(i), MFLX, D_c_in * 1e-3, A_cap);
        end

        dP(i) = dP_temp * section_length;

        if i < num_sections
            P_inlet_section(i + 1) = P_inlet_section(i) - dP(i);
        end
    end

    dP_tot = sum(dP);
    total_dP(mf_iter) = dP_tot;

    % Outlet temperature from final pressure and same enthalpy
    P_outlet = P_inlet - dP_tot;
    T_outlet(mf_iter) = refpropm('T', 'P', P_outlet * 1e2, 'H', H, fld) - 273.15;

    % % Determine phase state
    % if any(x > 0 & x < 1)
    %     phase_state(mf_iter) = "2\phi";
    % else
    %     phase_state(mf_iter) = "1\phi";
    % end
    % 
    % fprintf('ṁ = %.2f g/s → ΔP = %.2f bar → P_out = %.2f bar → T_out = %.2f °C\n', ...
    %     m_dot, dP_tot, P_outlet, T_outlet(mf_iter));
end

% Plot pressure drop
figure;
plot(mass_flows, total_dP, 'o-', 'LineWidth', 1.5, 'MarkerSize', 8, 'Color', 'm');
xlabel('Mass Flow Rate (g/s)');
ylabel('Total Pressure Drop (bar)');
title(sprintf('Capillary Pressure Drop vs Mass Flow\nI.D. = %.2f mm | T_{in} = %.0f°C | P_{in} = %.0f bar | L = %.0f mm | Ep_{Ti} = %.1f μm', ...
    D_c_in, T_inlet, P_inlet, L_total*1e3, Ep_Ti_micro));
grid on;

% xlim([3.7 4.6]);
% xticks(3.7:0.1:4.6);
% ylim([5.5 9]);
% yticks(5.5:0.5:9);

% Annotate phase state
for i = 1:length(mass_flows)
    text(mass_flows(i), total_dP(i) + 0.3, phase_state(i), ...
        'HorizontalAlignment', 'center', 'FontSize', 10);
end

% Custom legend
hold on;
h1 = plot(NaN, NaN, 'ko', 'MarkerFaceColor', 'none'); % 1-phase
h2 = plot(NaN, NaN, 'ko', 'MarkerFaceColor', 'k');    % 2-phase
legend([h1 h2], {'1\phi: Single-phase flow', '2\phi: Two-phase flow'}, 'Location', 'northwest');

% Watermark
text(0.99, 0.03, 'Sara Memushaj', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'FontSize', 7, ...
    'FontAngle', 'italic', ...
    'Color', [0.5 0.5 0.5]);
