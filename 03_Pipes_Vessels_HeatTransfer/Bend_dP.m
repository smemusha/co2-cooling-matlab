%% BEND PRESSURE DROP AS A FUNCTION OF NUMBER OF COILS

clear; clc;

% --- Input Parameters ---
Fluid  = 'CO2';
P      = 11;             % Pressure in bar
T      = -40;            % Temperature in °C
Ep     = 1.1e-6;         % Pipe surface roughness (m)
i_D    = 1.1e-3;         % Inner diameter of pipe (m)
R_bend = 2e-2;           % Bending radius (m)
x      = 0;              % Phase quality (0 = liquid)
m_dot  = 4.14e-3;        % Mass flow rate (kg/s)

A = (pi/4) * i_D^2;      % Cross-sectional area of the tube (m²)
MFLX = m_dot / A;        % Mass flux (kg/m²·s)

% Number of coils to analyze
num_coils_array = 0:5;

% Initialize array to store dP results
dP_total_array = zeros(size(num_coils_array));

% -------------------------------------------------------------------------
% Geometry & Pre-computed values
curvature_ratio = R_bend / i_D;
theta_per_coil = 360;                     % each coil is 360°
theta_rad = deg2rad(theta_per_coil);
Dh = theta_rad * R_bend;                  % arc length per full coil (m)

% Fluid properties
rho = refpropm('D', 'T', T+273.15, 'P', P*1e2, Fluid);  % Density (kg/m³)
DV  = refpropm('V', 'T', T+273.15, 'P', P*1e2, Fluid);  % Dynamic viscosity (Pa·s)

% Reynolds number
Re = MFLX * Dh / DV;

% Friction factor
if Re < 4000
    Fd = BlasiusCorrelation(Re);
else
    Fd = ColebrookEquation(Dh, Ep, Re);
end

% Bend loss coefficient (from chart or assumption)
K_bend = 0.27;

% Pressure drop for a single 360° coil
dP_bend_sf = ((0.5 * Fd * (MFLX^2)/rho * (pi * curvature_ratio) * (theta_per_coil / 180)) ...
             + (0.5 * K_bend * (MFLX^2)/rho)) * 1e-5; % bar

% Loop over each number of coils and compute total dP
for i = 1:length(num_coils_array)
    n_coils = num_coils_array(i);

    if x <= 0 || x >= 1
        % Single-phase flow
        dP_total_array(i) = 2 * n_coils * dP_bend_sf; % It's 2x cause the empirical equations correspond to a bend of 180°
    else
        % Two-phase correction
        rho_l = refpropm('D', 'T', T+273.15, 'Q', 0, Fluid);
        rho_g = refpropm('D', 'T', T+273.15, 'Q', 1, Fluid);
        rho_ratio = ((1 - x) / x) * (rho_g / (1 / rho - x / rho_l));
        correction = (1 + (rho_ratio - 1) * ((1 + (2.2 / (K_bend * (2 + curvature_ratio)))) * (x * (1 - x) + x^2)));
        dP_total_array(i) = n_coils * dP_bend_sf * correction;
    end
end

% -------------------------------------------------------------------------
% Plotting
figure;
plot(num_coils_array, dP_total_array, 'o-b', 'LineWidth', 1.5, 'MarkerSize', 6);
xlabel('Number of Coils');
xticks(0:1:5);
ylabel('Total Pressure Drop ΔP [bar]');
yticks(0:0.05:1.4);
title(sprintf('Pressure Drop vs. Number of Coils\n I.D. = %.2f mm | D_{coil} = %.0f mm | Ep_{Ti} = %.1f μm', i_D*1e3, R_bend*2*1e3, Ep*1e6));
grid on;

% Add value labels on top of each data point
for i = 1:length(num_coils_array)
    x_val = num_coils_array(i);
    y_val = dP_total_array(i);
    text(x_val, y_val + 0.02, sprintf('%.3f bar', y_val), ...
        'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
end

%% Source: https://www.thermopedia.com/content/577/

% References:
% Babcock and Wilcox Company (1978) Steam: Its Generation and Use.
% Chisholm, D. (1980) Two-phase flow in bends, Int. J. Multiphase Flow, vol. 6:363â€“367. DOI: 10.1016/0301-9322(80)90028-2
% Idelchik, I. E. (1986) Handbook of Hydraulic Resistance, Hemisphere Publishing Corp., Washington.
% Rowe, M. (1970) Measurement and computation of flow in pipe bends, J. Fluid Mech., 43:771â€“783. DOI: 10.1017/S0022112070002732