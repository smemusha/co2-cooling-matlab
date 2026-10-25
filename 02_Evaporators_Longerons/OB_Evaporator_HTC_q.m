% Add necessary paths for libraries
% addpath('C:\Program Files\Matlab\R2023b')
% addpath(genpath('C:\Program Files (x86)\REFPROP'))
% addpath(genpath('C:\Users\smemusha\cernbox\Desktop\CoBra Master'))

clear;
clc;

%% THERMOFLUID ANALYSIS OF EVAPORATOR (LONGERON/IHR)
% Fluid Analysis of the Evaporator

% Constants
fld = 'CO2'; % Fluid

L = (735*2)*1e-3; % Total length of Longeron (m)

D_e = 2.5*1e-3; % Evaporator diameter (m)
A_e = pi * (D_e / 2)^2; % Cross-sectional area (m^2)
P_e = pi * D_e; % Cross-sectional area (m) -- HALF OF TOTAL PERIMETER HEATED

D_b = 20*1e-3; % Cooling block diameter (m)
A_b = pi * (D_b / 2)^2; % Block area (m^2)

T_inlet = 5; % Inlet temperature (°C)
P_inlet = refpropm('P', 'T', T_inlet+273.15, 'Q', 0, fld)*1e-2; % Inlet pressure (bar)
H_inlet = refpropm('H','T', T_inlet+273.15, 'Q', 0, fld); % Enthalpy at inlet (J/kg) -- saturated liquid
%H_inlet = refpropm('H', 'P', P_inlet * 1e2, 'Q', 0, fld);

m_dot = 1.5e-3; % Mass flow rate (kg/s) 
MFLX = m_dot / A_e; % Mass flux (kg/m^2s)

q = 5; % Heat applied though the probe (W)
HFLX = q / A_b; % Heat flux (W/m^2s)

Ep_Ti = 1.1e-6; % Surface roughness of titanium (m)

%% OUTPUT VARIABLES

% Loop for the total length of the Longeron
L_bare = 21.4*1e-3; % 

iter =ceil(L/(D_b+L_bare));

for i = 1:iter

[dP,HTC,VQ,rm,State,T] = dPandHTC(fld,P_inlet,H_inlet,MFLX,HFLX,D_e,A_e,P_e/2,Ep_Ti,0,0);

disp(['Pressure Drop (dP): ', num2str(dP), ' bar/m']);
disp(['Heat Transfer Coefficient (HTC): ', num2str(HTC), ' W/m^2K']);
disp(['Vapor Quality (VQ): ', num2str(VQ)]);
disp(['Relative Mass Density (rm): ', num2str(rm), ' kg/m']);
disp(['Thermodynamic State: ', State]);
disp(['Temperature (T): ', num2str(T), '°C']);

end
