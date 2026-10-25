
clear;
clc;

%% THERMOFLUID ANALYSIS OF EVAPORATOR (BACKWARDS CALCULATION)

% --- 1. Inputs from Configuration Image ---
m_dot = 0.02;             % Mass flow [kg/s]
P_out = 6;                % Pressure at outlet [bar]
x_out = 1;                % Vapor quality at outlet (1 = Saturated Vapor)
power_total = 3000;       % Heat supplied to evaporator [W]
D_mm = 6;                 % Pipe diameter [mm]
L = 9;                    % Pipe length [m]
rough_mm = 1e-3;          % Surface roughness [mm]
theta_deg = 0;            % Pipe incline [deg]
n_steps = 500;            % Pipe divisions number
fluid = 'CO2';            % Fluid

% --- 2. Conversions & Geometric Constants ---
D = D_mm * 1e-3;          % Pipe diameter (m)
rough = rough_mm * 1e-3;  % Surface roughness (m)
A_e = pi * (D / 2)^2;     % Cross-sectional area (m^2)
P_e = pi * D;             % Full perimeter (m)

% --- 3. Flux Calculations ---
MFLX = m_dot / A_e;       % Mass flux (kg/m^2s)
% Heat flux based on total surface area (Perimeter * Length)
HFLX = power_total / (P_e * L); 

% --- 4. Starting State at Outlet ---
% We calculate enthalpy at the outlet to begin our march backwards
% Pressure in kPa for REFPROP (6 bar = 600 kPa)
P_kPa_out = P_out * 100;
H_out = refpropm('H', 'P', P_kPa_out, 'Q', x_out, fluid); 

%% 5. BACKWARDS ITERATION LOOP
dz = L / n_steps;         % Step size [m]
P_current = P_out;        % Current Pressure [bar]
H_current = H_out;        % Current Enthalpy [J/kg]

% Pre-allocate arrays for plotting
dist = linspace(L, 0, n_steps); % Distance from inlet (9m to 0m)
P_vec = zeros(1, n_steps);
T_vec = zeros(1, n_steps);
X_vec = zeros(1, n_steps);

disp('--- Calculation (Marching from Outlet to Inlet) ---');

for i = 1:n_steps
    % 1. Calculate local properties using your function
    % dP is usually returned as [bar/m]
    [dP, HTC, VQ, rm, State, T] = dPandHTC(fluid, P_current, H_current, MFLX, HFLX, D, A_e, P_e, rough, theta_deg, 0);
    
    % 2. Store data for plotting
    P_vec(i) = P_current;
    T_vec(i) = T;
    X_vec(i) = VQ;
    
    % 3. Print progress every 100 steps to avoid clutter
    if mod(i, 100) == 0 || i == 1
        fprintf('Step %d: Pos=%.2fm, P=%.2f bar, T=%.2f C, Qual=%.2f\n', i, dist(i), P_current, T, VQ);
    end
    
    % 4. UPDATE STATE FOR NEXT STEP (GOING BACKWARDS)
    % As we move towards the inlet (upstream):
    % Pressure INCREASES (since flow moves from high to low pressure)
    % Enthalpy DECREASES (since we haven't added the heat yet)
    
    P_current = P_current + (dP * dz); 
    H_current = H_current - ((HFLX * P_e * dz) / m_dot); 
end

%% 6. VISUALIZATION
figure('Name', 'Evaporator Analysis Results');
subplot(2,1,1);
plot(dist, P_vec, 'b', 'LineWidth', 1.5);
xlabel('Distance from Inlet (m)');
ylabel('Pressure (bar)');
title('Pressure Distribution along Pipe');
grid on;

subplot(2,1,2);
plot(dist, T_vec, 'r', 'LineWidth', 1.5);
xlabel('Distance from Inlet (m)');
ylabel('Temperature (°C)');
title('Temperature Distribution along Pipe');
grid on;

disp('--- Analysis Complete ---');
fprintf('Calculated Inlet Pressure: %.3f bar\n', P_current);
fprintf('Calculated Inlet Temperature: %.3f °C\n', T_vec(end));

% Final subtraction to show total pressure drop
Total_dP = P_current - P_out;
fprintf('Total dP: %.4f bar\n', Total_dP);