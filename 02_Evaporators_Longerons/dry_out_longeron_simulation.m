%% DRY OUT TESTING OF LONGERON IN 'AQUARIUM'

clc; clear; close all;

%%
% --- Inputs ---
Fluid = 'CO2';
P_range_bar = linspace(10, 30, 20);  % Pressure range in bar
m_dot = 4.14e-3;      % kg/s
D_in = 2.5e-3;        % m
A = pi * (D_in/2)^2;  % m^2

MFLX = m_dot / A;     % kg/m^2s
HFLX_1 = 420;         % W/m^2K
HFLX_2 = 500;         % W/m^2K

% --- Preallocate ---
xdi_420 = zeros(size(P_range_bar));
xdi_500 = zeros(size(P_range_bar));
T_sat_C = zeros(size(P_range_bar));

% --- Loop over pressures ---
for i = 1:length(P_range_bar)
    P_bar = P_range_bar(i);
    P_kPa = P_bar * 100;  % Convert to kPa for refpropm

    % Dryout vapor quality for HFLX = 420
    xdi_420(i) = DryOut(Fluid, P_bar, MFLX, HFLX_1, A);

    % Dryout vapor quality for HFLX = 500
    xdi_500(i) = DryOut(Fluid, P_bar, MFLX, HFLX_2, A);

    % Saturation temperature
    T_sat_K = refpropm('T', 'P', P_kPa, 'Q', 0, Fluid);
    T_sat_C(i) = T_sat_K - 273.15;
end

% --- Plotting ---
figure;

% Left Y-axis: Dryout VQ
yyaxis left
plot(P_range_bar, xdi_420, '-o', 'LineWidth', 1.5);
hold on;
plot(P_range_bar, xdi_500, '-^', 'LineWidth', 1.5);
ylabel('Dryout Vapor Quality [-]');
ylim([0.79 0.83]);

% Right Y-axis: Saturation Temp
yyaxis right
plot(P_range_bar, T_sat_C, '--s', 'LineWidth', 1.5);
ylabel('Saturation Temperature [°C]');

xlabel('Pressure [bar]');
title(sprintf('Dryout Vapor Quality and CO₂ Saturation Temperature vs Pressure\n m = %.2f g/s | I.D. = %.2f mm', m_dot*1e3, D_in*1e3));
legend('x_{dryout} @ 420 W/m²K', 'x_{dryout} @ 500 W/m²K', 'T_{sat}', 'Location', 'best');
xticks(10:1:30);
xlim([10 30]);
grid on;
