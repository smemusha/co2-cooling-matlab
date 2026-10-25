%% CAPILLARY THEORETICAL SIZING

% Necessary paths for libraries
% addpath('C:\Program Files\Matlab\R2023b')
% addpath(genpath('C:\Program Files (x86)\REFPROP'))
% addpath(genpath('C:\Users\smemusha\cernbox\WINDOWS\Desktop\CoBra Master'))
% addpath(genpath('C:\Users\smemusha\cernbox\WINDOWS\Desktop\ITk\Capilaries\Measurements'))

clear;
clc;

%% Necessary paths for libraries

% Work PC ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% addpath('C:\Program Files\Matlab\R2023b')
% addpath(genpath('C:\Program Files (x86)\REFPROP'))
% addpath(genpath('C:\Users\smemusha\cernbox\WINDOWS\Desktop\CoBra Master'))
% addpath(genpath('C:\Users\smemusha\cernbox\WINDOWS\Desktop\ITk\Capilaries\Measurements'))

% Personal PC ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% addpath('C:\Program Files\Matlab\R2023b')
% addpath(genpath('C:\Program Files (x86)\REFPROP'))
% addpath(genpath('C:\Users\smemusha\cernbox\WINDOWS\Desktop\CoBra Master'))
% addpath(genpath('C:\Users\smemusha\cernbox\WINDOWS\Desktop\ITk\Capilaries\Measurements'))

%% ----------------------------------------------------------------------
% Constants
fld = 'CO2';
T_inlet = -45;                                              % °C
P_inlet = 50;                                               % bar
H = refpropm('H','T',T_inlet+273.15,'P',P_inlet*1e2,fld);   % J/kg
m_dot = 1.89;                                               % g/s
D_c_in = 0.76;                                              % mm
L_total = 3.5;                                              % m

%----------------------------------------------------------------------
% Material properties
Ep_Ti_micro = 1.1;                % μm
Ep_Ti = Ep_Ti_micro * 1e-6;       % m

% Section parameters
section_length = 0.5e-2;          % m
num_sections   = ceil(L_total/section_length);

% Geometry
A_cap = pi*((D_c_in*1e-3)^2)/4;   % m^2
MFLX  = (m_dot*1e-3)/A_cap;       % kg/m^2/s

%----------------------------------------------------------------------
% Preallocate
T   = zeros(1, num_sections);
rho = zeros(1, num_sections);
x   = zeros(1, num_sections);
dP_per_m = zeros(1, num_sections);     % bar/m
dP_sec   = zeros(1, num_sections);     % bar
P_inlet_section = zeros(1, num_sections+1);
pipe_lengths = zeros(1, num_sections);

% Initial conditions
P_inlet_section(1) = P_inlet;
cumulative_dP = 0;

%----------------------------------------------------------------------
% March along sections up to fixed length
for i = 1:num_sections

    % State at start of section
    [T(i), rho(i), x(i)] = refpropm('TDQ', ...
        'P', P_inlet_section(i)*1e2, ...
        'H', H, fld);

    % Get dP/m from correlations
    if x(i) <= 0 || x(i) >= 1
        [dP_per_m(i), ~, ~] = DarcyWeisbach( ...
            fld, P_inlet_section(i), H, MFLX, D_c_in*1e-3, A_cap, Ep_Ti);
    else
        [dP_per_m(i), ~] = FriedelCorrelation( ...
            fld, P_inlet_section(i), x(i), MFLX, D_c_in*1e-3, A_cap);
    end

    % Pressure drop for this section
    dP_sec(i) = dP_per_m(i) * section_length;
    cumulative_dP = cumulative_dP + dP_sec(i);

    % Update pressure
    if i < num_sections
        P_inlet_section(i+1) = P_inlet_section(i) - dP_sec(i);
    end

    % Length
    pipe_lengths(i) = i * section_length;
end

%----------------------------------------------------------------------
% Results
P_outlet = P_inlet_section(num_sections+1);

fprintf('== Capillary ΔP vs Length ==\n');
fprintf('D_in = %.2f mm | m_dot = %.2f g/s | T_in = %.1f °C | P_in = %.2f bar\n', ...
    D_c_in, m_dot, T_inlet, P_inlet);
fprintf('Total length: %.2f m\n', L_total);
fprintf('Total ΔP: %.2f bar\n', cumulative_dP);

%----------------------------------------------------------------------
% % Plot ΔP vs Length
% figure;
% plot([0 pipe_lengths], [0 cumsum(dP_sec)], 'LineWidth', 1.6);
% grid on;
% 
% xlabel('Length (m)');
% ylabel('Pressure Drop (bar)');
% title(sprintf('Capillary Pressure Drop vs Length (D_{in}=%.2f mm, m=%.2f g/s)', ...
%     D_c_in, m_dot));
% 
% xlim([0 L_total]);
% 
% % Optional Psat line
% Psat = refpropm('P','T',T_inlet+273.15,'Q',0,fld)*1e-2;
% yline(Psat, '--', sprintf('P_{sat} = %.2f bar', Psat), 'LineWidth', 1.4);
