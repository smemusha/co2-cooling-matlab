%% CAPILLARY THEORETICAL SIZING

% Necessary paths for libraries
% addpath('C:\Program Files\Matlab\R2023b')
% addpath(genpath('C:\Program Files (x86)\REFPROP'))
% addpath(genpath('C:\Users\smemusha\cernbox\WINDOWS\Desktop\CoBra Master'))
% addpath(genpath('C:\Users\smemusha\cernbox\WINDOWS\Desktop\ITk\Capilaries\Measurements'))

clear;
clc;

%--------------------------------------------------------------------------

% Constants
fld = 'CO2';
L_total = 3.4; % total length of the capillary (m)
% L_long = 3.4
% L_IHR2 = 2.975
% L_IHR3 = 3.190
% L_IHR4 = 2.975
T_inlet = -40; % inlet temperature of CO2 (°C)
P_inlet = 18; % inlet pressure of CO2 (bar)
H = refpropm('H','T',T_inlet+273.15 ,'P',P_inlet*1e2,fld); % enthalpy at inlet (J/kg)
m_dot = 4.14; % mass flow rate of CO2 (g/s)
% m_long = 4.14
% m_IHR2 = 1.84
% m_IHR3 = 2.53
% m_IHR4 = 3.22
dP_dis = 8; % desired pressure drop (bar)
% dP_long = 8.00
% dP_IHR2 = 8.75
% dP_IHR3 = 8.55
% dP_IHR4 = 8.00

%--------------------------------------------------------------------------

% Assumed parameters
D_c_in_1 = 1.04; % Initial diameter in mm

% Material properties (Annealed Titanium Grade 2)
Ep_Ti_micro = 1.1; % surface roughness of titanium pipe (μm)
Ep_Ti = Ep_Ti_micro * 1e-6; % surface roughness of titanium pipe (m)

% Length of pipe's division
section_length = 2e-2; % section length in m
num_sections = ceil(L_total / section_length); % number of sections

% Initialize legend string
legend_str = cell(10, 1);

% Plotting initialization
figure;
hold on;

% Iterating over different capillary inner diameters
for diameter_iter = 1:10
    D_c_in = D_c_in_1 + 0.01 * diameter_iter; % Incrementing the diameter by 0.02 mm each iteration
    
    % Inner cross section of pipe (m^2)
    A_cap = pi * ((D_c_in * 1e-3)^2) / 4; 

    % Mass flux (kg/m^2s)
    MFLX = (m_dot * 1e-3) / A_cap;

    % Pre-allocation of variables for each iteration
    P_inlet_section = zeros(1, num_sections); 
    dP = zeros(1, num_sections);
    T = zeros(1, num_sections);
    rho = zeros(1, num_sections);
    x = zeros(1, num_sections);

    P_inlet_section(1) = P_inlet; % Initial pressure (bar)

    % Loop through each section of the pipe
    for i = 1:num_sections
        % Call the function and check the sizes of the outputs
        [T(i), rho(i), x(i)] = refpropm('TDQ', 'P', P_inlet_section(i) * 1e2, 'H', H, fld);
        
        if x(i) <= 0 || x(i) >= 1
            % Single-phase pressure drop
            [dP_temp, ~, ~] = DarcyWeisbach(fld, P_inlet_section(i), H, MFLX, D_c_in * 1e-3, A_cap, Ep_Ti); 
        else
            % Two-phase pressure drop
            [dP_temp, ~] = FriedelCorrelation(fld, P_inlet_section(i), x(i), MFLX, D_c_in * 1e-3, A_cap); 
        end

        % Scale the pressure drop by the section length
        dP(i) = dP_temp * section_length; % bar per section

        % Update pressure at inlet of next section if not the last section
        if i < num_sections
            P_inlet_section(i + 1) = P_inlet_section(i) - dP(i); % Update pressure
        end
    end

    % Calculate total dP
    dP_tot = sum(dP); % Total pressure drop (bar)

    % Outlet pressure calculation
    P_outlet = P_inlet - dP_tot; % Outlet pressure (bar)

    % Check if desired pressure drop condition is satisfied
    if dP_tot >= 0.95 * dP_dis && dP_tot <= 1.05 * dP_dis 
        fprintf('For D_c_in = %.2f mm:\n', D_c_in);
        cprintf('_green', 'Desired pressure drop condition SATISFIED.\n');
        fprintf('Total pressure drop at the capillary is %.2f bar.\n', dP_tot);
        fprintf('Outlet pressure of the capillary is %.2f bar.\n', P_outlet);
    else
        fprintf('For D_c_in = %.2f mm:\n', D_c_in);
        cprintf('_red', 'Desired pressure drop condition NOT SATISFIED.\n');
        fprintf('Total pressure drop at the capillary is %.2f bar.\n', dP_tot);
        fprintf('Outlet pressure of the capillary is %.2f bar.\n', P_outlet);
    end

    % Plot the pressure drop
    pipe_lengths = section_length * (1:num_sections);
    plot(pipe_lengths, P_inlet_section, 'LineWidth', 1.5);
    
    % Update legend string
    legend_str{diameter_iter} = ['D_{in} = ', sprintf('%.2f', D_c_in), ' mm'];
end

% Dashed line at Psat
Psat = refpropm('P', 'T', T_inlet + 273.15, 'Q', 0, fld) * 1e-2; % Psat in bar
yline(Psat, '--', 'P_{sat}', 'LabelHorizontalAlignment', 'center', 'LabelVerticalAlignment', 'middle', 'LineWidth', 2);

% Legend
legend_str{diameter_iter + 1} = sprintf('Sat. Pressure (P_{sat} = %.2f bar)', Psat);
legend(legend_str, 'Location', 'southwest');

xlabel('Length (m)');
ylabel('Pressure (bar)');
title(sprintf('ATLAS Capillary Sizing for IHR (4^{th} Layer)\nMF = %.2f g/s | T_{st} = %.0f\\circC | P_{in} = %.0f bar | dP_{desired} = %.2f bar | L_{exp} = %.3f m | Ep_{Ti} = %.1f μm', m_dot, T_inlet, P_inlet, dP_dis, L_total, Ep_Ti_micro));
grid on;

% Adjustments of axis limits and tick marks
xlim([0, max(pipe_lengths)]);
xticks(0:0.1:max(pipe_lengths));

ylim([5, max(P_inlet_section)]);
yticks(0:1:max(P_inlet_section));

% Set the position and size of the figure window
fig = gcf;
fig.Position = [100, 100, 800, 600];
