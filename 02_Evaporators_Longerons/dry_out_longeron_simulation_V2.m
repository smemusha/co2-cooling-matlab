%% DRY OUT TESTING OF LONGERON IN 'AQUARIUM'

% --- Inputs ---
Fluid = 'CO2';
P_range_bar = linspace(10, 30, 20);  % Pressure range in bar
D_in = 2.5e-3;        % Inner diameter [m]
A = pi * (D_in/2)^2;  % Cross-sectional area [m^2]
HFLX = 420;           % Heat flux [W/m²K]

% Mass flow range: 1.8 g/s to 4.2 g/s with step 0.2
m_dot_range = (1.8:0.2:4.2) * 1e-3;  % Convert to kg/s
num_cases = length(m_dot_range);

% Preallocate arrays
xdi_all = zeros(num_cases, length(P_range_bar));
T_sat_C = zeros(size(P_range_bar));  % Saturation temperature shared across cases

% Loop over pressures (compute T_sat once) and m_dot values
for i = 1:length(P_range_bar)
    P_bar = P_range_bar(i);
    P_kPa = P_bar * 100;  % Convert to kPa for REFPROP

    % Saturation temperature (same for all mass flows)
    T_sat_K = refpropm('T', 'P', P_kPa, 'Q', 0, Fluid);
    T_sat_C(i) = T_sat_K - 273.15;

    % Loop over mass flow cases
    for j = 1:num_cases
        m_dot = m_dot_range(j);     % kg/s
        MFLX = m_dot / A;           % kg/m²s
        xdi_all(j, i) = DryOut(Fluid, P_bar, MFLX, HFLX, A);  % Dryout VQ
    end
end

% --- Plotting ---
figure;

% Define cohesive colormap and marker styles
colors = lines(num_cases);  % MATLAB default line colors
markers = {'o','s','^','v','d','>','<','p','h','x','+','*','.'};

% Left Y-axis: Dryout vapor quality curves
yyaxis left
ax = gca;
ax.YColor = 'k';
hold on;
for j = 1:num_cases
    plot(P_range_bar, xdi_all(j, :), 'LineWidth', 1.5, ...
        'Color', colors(j,:), ...
        'Marker', markers{mod(j-1, length(markers))+1}, ...
        'MarkerIndices', 1:5:length(P_range_bar));
end
ylabel('Dryout Vapor Quality [-]');
% ylim([0.79 0.83]);

% Right Y-axis: Saturation Temperature
yyaxis right
plot(P_range_bar, T_sat_C, '-o', 'LineWidth', 1.5, ...
    'Color', [1, 0.5, 0], 'MarkerFaceColor', [1, 0.5, 0]);  % Orange
ylabel('Saturation Temperature [°C]');

% Axis labels and grid
xlabel('Pressure [bar]');
title(sprintf('Dryout Vapor Quality and CO₂ Saturation Temperature vs Pressure per Mass Flow Rate Case\nI.D. = %.2f mm | HFLX = %d W/m²K', D_in*1e3, HFLX));

% Legend
legend_entries = arrayfun(@(m) sprintf('m = %.1f g/s', m*1e3), m_dot_range, 'UniformOutput', false);
legend_entries{end+1} = 'T_{sat}';
legend(legend_entries, 'Location', 'eastoutside');

set(gcf, 'Position', [100, 100, 1000, 800]);  % [left, bottom, width, height]

xticks(10:1:30);
xlim([10 30]);
grid on;
