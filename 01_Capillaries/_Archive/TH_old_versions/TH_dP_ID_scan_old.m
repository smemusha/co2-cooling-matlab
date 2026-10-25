% Add paths for required directories
% addpath('C:\Program Files\Matlab\R2023b')
% addpath('C:\Program Files (x86)\REFPROP')
% addpath('C:\Users\smemusha\cernbox\Documents\Surface Storage\cobra-master')

clear all
clc

% Constants~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Temperature/enthalpy in the capillary constant cause we are in 1-PHASE/liquid (at least initially) 
fld = 'CO2';
L_total = 3.5; % total length of the capillary (coil included(?)) (m)
% L_long = 3.4
% L_IHR2 = 2.975
% L_IHR3 = 3.190
% L_IHR4 = 2.975
T_inlet = -40; % inlet temperature of CO2 (C)
P_inlet = 30; % inlet pressure of CO2 (bar)
H = refpropm('H','T',T_inlet+273.15 ,'P',P_inlet*1e2,fld); % enthalpy at inlet (J/kg)
m_dot = 1.89; % mass flow rate of CO2 (g/s)
% m_long = 4.14
% m_IHR2 = 1.84
% m_IHR3 = 2.53
% m_IHR4 = 3.22

dP_dis = 8.75; % desired pressure drop (bar)
% dP_long = 8
% dP_IHR2 = 8.75
% dP_IHR3 = 8.55
% dP_IHR4 = 8

% Assumed parameters~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Initial diameter
D_c_in_1 = 0.74; % mm

% Material properties (Annealed Titanium Grade 2)~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ep_Ti = 1.1*1e-6; % surface roughness of titanium pipe (m)
Ep_Ti_micro = 1.1; % μm

% Length of pipe's division~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
section_length = 1.5e-2; % m

% Initialize variables~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
num_sections = ceil(L_total/section_length);

% Initialize legend string
legend_str = cell(10, 1);

% Iterating over different capillary inner diameters~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
for diameter_iter = 1:10
    D_c_in = D_c_in_1 + 0.02 * diameter_iter; % Incrementing the diameter by 0.02 mm each iteration
    
    % Inner cross section of pipe (m^2)
    A_cap = pi*((D_c_in*1e-3)^2)/4; 

    MFLX = (m_dot*1e-3)/A_cap; % (kg/m^2s)

    P_inlet_section(1) = P_inlet;

    % Loop through each section of the pipe
    for i = 1:num_sections
        % Call the function and check the sizes of the outputs
        [T(i),rho(i),x(i)] = refpropm('TDQ','P',P_inlet_section(i)*1e2,'H',H,fld);
        if x(i)<=0 || x(i)>=1
            [dP_temp, rm_temp, State] = DarcyWeisbach(fld, P_inlet_section(i), H, MFLX, section_length, A_cap, Ep_Ti); % 1-PHASE
        else
            [dP_temp, rm_temp] = FriedelCorrelation(fld, P_inlet_section(i), x(i), MFLX, section_length, A_cap); % 2-PHASE
        end

        % Assigning outputs to the arrays
        dP(i) = dP_temp;

        % Update pressure at inlet of next section if not the last section
        if i < num_sections
            P_inlet_section(i+1) = P_inlet_section(i) - dP(i);
        end
    end

    % Calculate total dP
    dP_tot = sum(dP);

    P_outlet = P_inlet - dP_tot;

    % Check if maximum pressure drop condition is satisfied
    if dP_tot >= 0.95*dP_dis && dP_tot <= 1.05*dP_dis 
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

    % Plot of the cumulative pressure drop
    pipe_lengths = section_length * (1:num_sections);
    cumulative_dP = cumsum(dP);
    plot(pipe_lengths, cumulative_dP, 'LineWidth', 1.5);
    hold on;
    
    legend_str{diameter_iter} = ['D_{in} = ', sprintf('%.2f', D_c_in),' mm'];
end

% Legend~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
legend(legend_str, 'Location', 'southwest');

xlabel('Length (m)');
ylabel('Pressure Drop (bar)');
title(sprintf('ATLAS Capillary Sizing for IHR (2^{nd} Layer)\nMF = %.2f g/s, T_{st} = %.0f\\circC, P_{in} = %.0f bar, dP_{desired} = %.2f bar, L_{exp} = %.3f m, Ep_{Ti} = %.1f μm', m_dot, T_inlet, P_inlet, dP_dis,L_total, Ep_Ti_micro));
grid on;

% Add dashed line at Psat
Psat = refpropm('P','T',T_inlet+273.15,'Q',0,fld)*1e-2; % bar
yline(Psat, '--', 'P_{sat}', 'LabelHorizontalAlignment', 'center', 'LabelVerticalAlignment', 'middle', 'LineWidth', 2);

% Adjustments of axis limits and tick marks
xlim([0, max(pipe_lengths)]);
xticks(0:0.1:max(pipe_lengths));

ylim([0, 10]);
yticks(0:1:10);

% Set the position and size of the figure window
fig = gcf;
fig.Position = [100, 100, 800, 600];
