function dP_bend = FUNCTION_bend_dP(Fluid, P, T, MFLX, Ep, i_D, R_bend, theta, x)
% Function to calculate pressure drop in a bend of a tube.

% Inputs:
% Fluid  - In our case CO2
% P      - Pressure (bar) 
% T      - Temperature (°C)
% MFLX   - Mass flux (kg/m^2s)
% Ep     - Surface roughness of pipe (m)
% i_D    - Inner diameter of the tube (m)
% R_bend - Bending radius (m)
% theta  - Degrees of bending (°)
% x      - Phase quality

% Example:
% Fluid ='CO2';
% P = 14;
% T = -40;
% MFLX = 4.019e+03;
% Ep = 1.1e-6;
% i_D = 1.1e-3;
% R_bend = 4e-3;
% theta = 180;
% x = 0;

%--------------------------------------------------------------------------
% File path of the image
filePath = 'Bend loss coefficients for a pipe (Babcock & Wilcox Co.1978).jpeg';

% Read the image
imageData = imread(filePath);

% Display the image
imshow(imageData);
%--------------------------------------------------------------------------

% Geometric parameters
curvature_ratio = R_bend / i_D; % Curvature ratio
fprintf('curvature ratio = %.2f.\n',curvature_ratio);

theta_rad = deg2rad(theta);
Dh = theta_rad * R_bend; % section lenth of pipe -- in this case it's the arc length (m)

% Properties
rho = refpropm('D','T', T+273.15,'P',P*1e2,Fluid);  % kg/m3
DV = refpropm('V','T', T+273.15,'P',P*1e2,Fluid);   % Dynamic Viscosity (Pa*s)

%Dimensionless numbers
Re=MFLX*Dh/DV; % Reynolds number 

%Determination of the Darcy Friction Factor 'Fd'
if Re<4000
    Fd=BlasiusCorrelation(Re);
else
    %Fd=ColebrookEquation(Dh,Ep,Re);
    Fd=ColebrookEquation(Dh,Ep,Re);
end

K_bend = 0.27; % Bend-loss coefficient for single-phase -- TAKEN FROM GRAPH ABOVE -- FIRST IMPUT RANDOM
dP_bend_sf = ((0.5 * Fd * (MFLX^2)/rho * (pi*curvature_ratio) * (theta/180)) + (0.5 * K_bend * (MFLX^2)/rho))*1e-5; % dP for single-phase fluid bar

% Pressure drop
if x <= 0 || x >= 1
    % Case: Single-phase flow
    dP_bend = dP_bend_sf; % bar

elseif x > 0 && x < 1
    % Case: Two-phase flow
    rho_l = refpropm('D', 'T', T+273.15, 'Q', 0, Fluid); % Saturated liquid density (kg/m3)
    rho_g = refpropm('D', 'T', T+273.15, 'Q', 1, Fluid);  % Saturated vapor density (kg/m3)
    rho_ratio = ((1 - x) / x) * (rho_g / (1 / rho - x / rho_l));

    dP_bend = dP_bend_sf * (1 + (rho_ratio-1)*((1+(2.2/(K_bend*(2+curvature_ratio)))) * (x*(1-x)+(x^2))))*1e-5; % bar
end

% % Enthalpy change across the bend (simplified estimation)
%     h_in = refpropm('H', 'T', T + 273.15, 'P', P * 1e2, Fluid); % Enthalpy at inlet (J/kg)
%     s_in = refpropm('S', 'T', T + 273.15, 'P', P * 1e2, Fluid); % Entropy at inlet (J/kgK)
% 
%     h_out = refpropm('H', 'P', (P-dP_bend)*1e2, 'S', s_in, Fluid); % Enthalpy at inlet (J/kg)
%     dH_bend = h_in - h_out;
% 
%     x_bend = refpropm('Q', 'P', (P-dP_bend)*1e2, 'H', h_out, Fluid);

    fprintf('ΔP across the bend = %.4f bar.\n', dP_bend);
    % fprintf('ΔH across the bend = %.4f J/kg.\n', dH_bend);
    % fprintf('VQ at the end of the bend = %.4f .\n', x_bend);

%% Source: https://www.thermopedia.com/content/577/

% References
% Babcock and Wilcox Company (1978) Steam: Its Generation and Use.
% Chisholm, D. (1980) Two-phase flow in bends, Int. J. Multiphase Flow, vol. 6:363â€“367. DOI: 10.1016/0301-9322(80)90028-2
% Idelchik, I. E. (1986) Handbook of Hydraulic Resistance, Hemisphere Publishing Corp., Washington.
% Rowe, M. (1970) Measurement and computation of flow in pipe bends, J. Fluid Mech., 43:771â€“783. DOI: 10.1017/S0022112070002732
