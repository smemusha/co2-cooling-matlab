function plotTs_Sara(varargin)
% plotTs: Plots Temperature-Entropy (T-s) Diagram.
% Temperature is in degrees Celsius and entropy is in J/(kg*K).
% It can plot for CO2, R410A, and R507A based on the input argument.

% Check input arguments to determine the fluid
if nargin == 1
    if varargin{1} == 1
        % R410A
        fluid = 'R410A';
    elseif varargin{1} == 2
        % R507A
        fluid = 'R507A';
    else
        error('Invalid argument. Use 1 for R410A or 2 for R507A.');
    end
else
    % Default to CO2
    fluid = 'CO2';
end

% Define temperature range (in Kelvin)
T_min = -50 + 273.15;  % -50 degrees Celsius
T_max = 200 + 273.15;  % 200 degrees Celsius

% Define entropy range (in J/(kg*K))
s_min = 300;   % Minimum entropy
s_max = 1000;  % Maximum entropy

% Create a vector of temperature values
T = linspace(T_min, T_max, 100);

% Initialize vectors for saturation entropy values
s_liq = zeros(size(T));
s_vap = zeros(size(T));

% Calculate saturation entropy values
for i = 1:length(T)
    try
        s_liq(i) = refpropm('S', 'T', T(i), 'Q', 0, fluid);  % Liquid phase
        s_vap(i) = refpropm('S', 'T', T(i), 'Q', 1, fluid);  % Vapor phase
    catch
        s_liq(i) = NaN;  % Set NaN for temperatures beyond the critical point
        s_vap(i) = NaN;
    end
end

% Plot saturation lines
figure;
plot(s_liq, T, 'k', 'DisplayName', 'Saturation Liquid Line','LineStyle','--','LineWidth',1);
hold on;
plot(s_vap, T, 'k', 'DisplayName', 'Saturation Vapor Line','LineStyle','-.','LineWidth',1);

% Plot the critical point for CO2
if strcmp(fluid, 'CO2')
    Tc_CO2 = 304.13; % Critical temperature for CO2 in K
    critical_s_CO2 = refpropm('S', 'C', 0, ' ', 0, fluid);
    plot(critical_s_CO2, Tc_CO2, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'DisplayName', 'Critical Point');
end

% Customize plot
grid on;
xlabel('Entropy (J/(kg*K))');
ylabel('Temperature (K)');
title([fluid ' Temperature-Entropy Diagram']);
legend('show', 'Location', 'southeast');

end
