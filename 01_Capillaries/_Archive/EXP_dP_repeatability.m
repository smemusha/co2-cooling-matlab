%% CAPILLARY TESTING RESULTS — 3 Capillaries, 2 Files

% Capillary Geometry
D_c_in = 0.76;
L_total = 3745;

%% Load data
dataA = readtable('2025.05.22_POB_0.76mm_1st_2nd_3rd_Measurement.csv', 'VariableNamingRule', 'preserve');
dataB = readtable('23.05.2025_POB_0.76mm_4th_5th_Measurement .csv', 'VariableNamingRule', 'preserve');

% Extract data
timestampsA = datetime(dataA{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'}, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
pressureA = dataA{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
massflowA = dataA{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};

timestampsB = datetime(dataB{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'}, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
pressureB = dataB{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
massflowB = dataB{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};

% Combine both files
timestamps = [timestampsA; timestampsB];
pressure = [pressureA; pressureB];
massflow = [massflowA; massflowB];

% Sort all data by time
[timestamps, idx] = sort(timestamps);
pressure = pressure(idx);
massflow = massflow(idx);

%% Define time ranges per capillary
% Capillary 1 (5 measurements)
timeRanges1 = [...
    datetime('2025/05/22 12:13:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/05/22 12:18:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/05/22 16:44:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/05/22 16:49:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/05/22 20:33:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/05/22 20:38:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/05/23 11:09:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/05/23 11:14:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/05/23 15:28:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/05/23 15:33:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
];

% Capillary 2
timeRanges2 = [...
    datetime('2025/05/22 11:37:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/05/22 11:42:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/05/22 16:17:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/05/22 16:22:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/05/22 20:07:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/05/22 20:12:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/05/23 10:36:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/05/23 10:41:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/05/23 15:05:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/05/23 15:10:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
];

% Capillary 3
timeRanges3 = [...
    datetime('2025/05/22 11:10:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/05/22 11:15:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/05/22 15:50:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/05/22 15:55:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/05/22 19:46:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/05/22 19:51:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/05/23 10:09:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/05/23 10:14:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/05/23 14:44:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/05/23 14:49:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
];

%% Helper function to extract average values
get_averages = @(ranges) arrayfun(@(i) ...
    mean(pressure(timestamps >= ranges(i,1)-seconds(2) & timestamps <= ranges(i,2)+seconds(2))), ...
    (1:size(ranges,1))');

get_massflows = @(ranges) arrayfun(@(i) ...
    mean(massflow(timestamps >= ranges(i,1)-seconds(2) & timestamps <= ranges(i,2)+seconds(2))), ...
    (1:size(ranges,1))');

%% Compute means
pressure1 = get_averages(timeRanges1);
massflow1 = get_massflows(timeRanges1);

pressure2 = get_averages(timeRanges2);
massflow2 = get_massflows(timeRanges2);

pressure3 = get_averages(timeRanges3);
massflow3 = get_massflows(timeRanges3);

%% Repetition axis
repetitions = 1:5;

%% Plotting
screenSize = get(0, 'ScreenSize');
figWidth = 800;
figHeight = 600;
xPos = (screenSize(3) - figWidth) / 2;
yPos = (screenSize(4) - figHeight) / 2;
figure('Position', [xPos, yPos, figWidth, figHeight]);

hold on; grid on;
ax = gca;
ax.Position(1) = ax.Position(1) + 0.03;

% Plot data
plot(repetitions, pressure1, 'o-', 'LineWidth', 1.5, 'Color', 'b', 'DisplayName', 'Capillary No.1 (Ti)');
plot(repetitions, pressure2, 's-', 'LineWidth', 1.5, 'Color', 'r', 'DisplayName', 'Capillary No.2 (Ti)');
plot(repetitions, pressure3, '^-', 'LineWidth', 1.5, 'Color', 'g', 'DisplayName', 'Capillary No.3 (Ti)');

% Annotate points
for i = 1:5
    text(repetitions(i)+0.1, pressure1(i)+0.08, sprintf('%.2f g/s', massflow1(i)), 'FontSize', 8, 'Color', 'b');
    text(repetitions(i)+0.1, pressure2(i)+0.08, sprintf('%.2f g/s', massflow2(i)), 'FontSize', 8, 'Color', 'r');
    text(repetitions(i)+0.1, pressure3(i)+0.08, sprintf('%.2f g/s', massflow3(i)), 'FontSize', 8, 'Color', 'g');
end

xlabel('Repetition Number');
xticks(1:1:5);
ylabel('Pressure Drop (bar)');
title(sprintf('O.B. Pixel: Capillary Pressure Drop vs Repetition\n I.D. = %.2f mm | L_{cap} = %.0f mm', D_c_in, L_total));
legend('Location', 'best');
hold off;