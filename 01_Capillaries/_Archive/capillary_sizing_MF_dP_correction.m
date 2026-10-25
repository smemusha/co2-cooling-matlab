clear all
clc

% Constants
fld = 'CO2';
L_total = 3.400;           % Total length of capillary (m)
T_inlet = -45;             % Inlet temperature of CO2 (°C) - known
P_inlet = 50;              % Inlet pressure of CO2 (bar) - known
D_c_in = 1.10;             % Capillary inner diameter (mm)
Ep_Ti = 1.1e-6;            % Roughness (m)
Ep_Ti_micro = 1.1;         % Roughness (μm)

% --- Added for second curve (higher roughness) ---
Ep_Ti_2 = 3.3e-6;          % Roughness (m)
Ep_Ti_2_micro = 3.3;       % Roughness (μm)
% -------------------------------------------------

% Mass flow rates (g/s)
mass_flows = 1.8:0.1:4.5;

% Discretization
section_length = 1.5e-2; % Segment length (m)
num_sections = ceil(L_total / section_length);

% Initialize storage
total_dP = zeros(length(mass_flows), 1);
T_outlet = zeros(length(mass_flows), 1);

% --- Added for second curve storage ---
total_dP_2 = zeros(length(mass_flows), 1);
T_outlet_2 = zeros(length(mass_flows), 1);
% -------------------------------------

% Loop over mass flows (Ep_Ti = 1.1e-6)
for mf_iter = 1:length(mass_flows)
    m_dot = mass_flows(mf_iter);         
    A_cap = pi * ((D_c_in * 1e-3)^2) / 4;
    MFLX = (m_dot * 1e-3) / A_cap;        

    H = refpropm('H', 'T', T_inlet + 273.15, 'P', P_inlet * 1e2, fld);  

    P_inlet_section(1) = P_inlet;
    dP = zeros(1, num_sections);

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

    total_dP(mf_iter) = sum(dP);
    P_outlet = P_inlet - total_dP(mf_iter);
    T_outlet(mf_iter) = refpropm('T', 'P', P_outlet * 1e2, 'H', H, fld) - 273.15;
end

% --- Second loop for higher roughness (Ep_Ti_2 = 3.3e-6) ---
for mf_iter = 1:length(mass_flows)
    m_dot = mass_flows(mf_iter);         
    A_cap = pi * ((D_c_in * 1e-3)^2) / 4;
    MFLX = (m_dot * 1e-3) / A_cap;        

    H = refpropm('H', 'T', T_inlet + 273.15, 'P', P_inlet * 1e2, fld);  

    P_inlet_section2(1) = P_inlet;
    dP2 = zeros(1, num_sections);

    for i = 1:num_sections
        [T2(i), rho2(i), x2(i)] = refpropm('TDQ', 'P', P_inlet_section2(i) * 1e2, 'H', H, fld);

        if x2(i) < 0 || x2(i) > 1
            [dP_temp2, ~, ~] = DarcyWeisbach(fld, P_inlet_section2(i), H, MFLX, D_c_in * 1e-3, A_cap, Ep_Ti_2);
        else
            [dP_temp2, ~] = FriedelCorrelation(fld, P_inlet_section2(i), x2(i), MFLX, D_c_in * 1e-3, A_cap);
        end

        dP2(i) = dP_temp2 * section_length;
        if i < num_sections
            P_inlet_section2(i + 1) = P_inlet_section2(i) - dP2(i);
        end
    end

    total_dP_2(mf_iter) = sum(dP2);
    P_outlet2 = P_inlet - total_dP_2(mf_iter);
    T_outlet_2(mf_iter) = refpropm('T', 'P', P_outlet2 * 1e2, 'H', H, fld) - 273.15;
end
% -------------------------------------------------------------

% Plot pressure drop
figure;
% --- Hidden first curve (commented out plotting line) ---
% hCurve1 = plot(mass_flows, total_dP, 'o-', 'LineWidth', 1.5, 'MarkerSize', 8, 'Color', 'm'); hold on;

% --- Only show second curve ---
hCurve2 = plot(mass_flows, total_dP_2, 's--', 'LineWidth', 1.5, 'MarkerSize', 6, 'Color', 'b'); hold on;

xlabel('Mass Flow Rate (g/s)');
ylabel('Total Pressure Drop (bar)');
title(sprintf('Capillary Pressure Drop vs Mass Flow\nI.D. = %.2f mm | T_{in} = %.0f°C | P_{in} = %.0f bar | L = %.0f mm', ...
    D_c_in, T_inlet, P_inlet, L_total*1e3));
grid on;

% --- Show exact dP values (above curve) ---
for i = 1:length(mass_flows)
    text(mass_flows(i), total_dP_2(i) + 0.25, sprintf('%.2f', total_dP_2(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', 'b', 'FontWeight', 'bold');
end
% -------------------------------------------------

% --- X-axis ticks every 0.1 ---
xlim([min(mass_flows) max(mass_flows)]);
xticks(mass_flows(1):0.1:mass_flows(end));
% -------------------------------

% --- Simplified legend (only visible curve) ---
legend(hCurve2, sprintf('Ep_{Ti} = %.1f \\mum', Ep_Ti_2_micro), 'Location', 'northwest');
% -----------------------------------------------

% Watermark
text(0.99, 0.03, 'Sara Memushaj', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'FontSize', 7, ...
    'FontAngle', 'italic', ...
    'Color', [0.5 0.5 0.5]);
