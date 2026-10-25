% Add necessary paths for libraries
% addpath('C:\Program Files\Matlab\R2023b')
% addpath(genpath('C:\Program Files (x86)\REFPROP'))
% addpath(genpath('C:\Users\smemusha\cernbox\Desktop\CoBra Master'))

clear;
clc;

%--------------------------------------------------------------------------

% Initial Conditions
fld = 'CO2';

T_inlet = -40; % inlet temperature (°C)
P_inlet = 18; % inlet pressure of CO2 (bar)
H = refpropm('H','T',T_inlet+273.15 ,'P',P_inlet*1e2,fld); % enthalpy at inlet (J/kg)

D_c_in = 0.95; % Initial diameter in mm
A_cap = pi * ((D_c_in * 1e-3)^2) / 4; % Inner cross section of pipe (m^2)

% Parameters
MFLX_range = 1:10:500; % Mass flow rates in g/s
tube_lengths = [2.975, 3.190, 3.4]; % Tube lengths in meters

% Material properties (Annealed Titanium Grade 2)
Ep_Ti_micro = 1.1; % surface roughness of titanium pipe (μm)
Ep_Ti = Ep_Ti_micro * 1e-6; % surface roughness of titanium pipe (m)

% Length of pipe's division
section_length = 2e-2; % section length in m
num_sections = ceil(tube_lengths(i) / section_length); % number of sections

% Import experimental data
data = readtable('pressure_data.csv'); % Adjust file name to your data file

% Assuming the data file has columns named: 'MassFlowRate', 'Length', 'PressureDrop'
MFLX_range = unique(data.MassFlowRate); % g/s
tube_lengths = unique(data.Length);     % m

% Pre-allocate pressure drop matrix based on unique lengths and mass flow rates
pressure_drop = zeros(length(MFLX_range), length(tube_lengths));

% Populate pressure drop matrix
for i = 1:length(tube_lengths)
    L = tube_lengths(i);
    
    for j = 1:length(MFLX_range)
        m_dot = MFLX_range(j);
        
        % Find the matching pressure drop for this mass flow rate and tube length
        row = data.MassFlowRate == m_dot & data.Length == L;
        if any(row)
            pressure_drop(j, i) = data.PressureDrop(row);
        else
            pressure_drop(j, i) = NaN; % If no data is available
        end
    end
end

% Plotting the results
figure;
hold on;
for i = 1:length(tube_lengths)
    plot(MFLX_range, pressure_drop(:, i), 'DisplayName', ['L = ' num2str(tube_lengths(i)) ' m']);
end
hold off;

% Graph Labels
xlabel('Mass Flow Rate (g/s)');
ylabel('Pressure Drop (bar)');
title('Pressure Drop vs Mass Flow Rate for Different Tube Lengths');
title('ATLAS Capillary Sizing for ID = \nMF = %.2f g/s, T_{st} = %.0f\\circC, P_{in} = %.0f bar, dP_{desired} = %.2f bar, L_{exp} = %.3f m, Ep_{Ti} = %.1f μm', m_dot, T_inlet, P_inlet, dP_dis, L_total, Ep_Ti_micro))

legend('show');
grid on;
