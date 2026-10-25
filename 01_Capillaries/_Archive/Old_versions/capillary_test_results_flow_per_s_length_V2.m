%% CAPILLARY TESTING RESULTS - DP / MF (B180)

% Post processing data (.csv files exported from SCADA) from
% the capillary testing setup in B180.

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

%% Loading of CSV files

data1 = readtable('POB COS1, Data 17-09-2026,Flow Scan, P.O.B-20260303-8.csv', 'VariableNamingRule', 'preserve');
data2 = readtable('POB COS Data 2026-09-18  Flow Scan P.O.B-ID 1.1-20260303-06.csv', 'VariableNamingRule', 'preserve');
data3 = readtable('POB COS Data 11-06-2026 Capillary-01 Flow Scan.csv', 'VariableNamingRule', 'preserve');
data4 = readtable('POB COS Data 12-06-2026 Capillary-03 Flow Scan.csv', 'VariableNamingRule', 'preserve');

%% Definition of time ranges

% Each row corresponds to one stable mass-flow step.

% Capillary 1
timeRanges1 = [... 
    datetime('2026/09/17 14:26:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/09/17 14:31:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    datetime('2026/09/17 14:03:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/09/17 14:08:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/09/17 13:49:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/09/17 13:54:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/09/17 13:37:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/09/17 13:42:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/09/17 13:26:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/09/17 13:31:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
];

% Capillary 2
timeRanges2 = [... 
    datetime('2026/09/18 14:36:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/09/18 14:41:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/09/18 14:44:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/09/18 14:49:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/09/18 14:58:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/09/18 15:03:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/09/18 15:11:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/09/18 15:16:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/09/18 15:29:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/09/18 15:34:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
];

% Capillary 3
timeRanges3 = [... 
    datetime('2026/06/11 14:53:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/11 14:58:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/11 15:35:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/11 15:40:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/11 15:51:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/11 15:56:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/11 16:08:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/11 16:13:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/11 16:25:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/11 16:30:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
];

% Capillary 4
timeRanges4 = [... 
    datetime('2026/06/12 14:30:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/12 14:35:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/12 14:41:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/12 14:46:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/12 14:54:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/12 14:59:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/12 15:11:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/12 15:16:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/12 15:30:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/12 15:35:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
];
%% Extract columns from CSV files

% Capillary 6 - After brazing
timestamps1 = data1{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'};
pressure_diff1 = data1{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
mass_flow_rate1 = data1{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};
timeData1 = datetime(timestamps1, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');

% Capillary 7 - After brazing
timestamps2 = data2{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'};
pressure_diff2 = data2{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
mass_flow_rate2 = data2{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};
timeData2 = datetime(timestamps2, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');

% Capillary 8 - After brazing
timestamps3 = data3{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'};
pressure_diff3 = data3{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
mass_flow_rate3 = data3{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};
timeData3 = datetime(timestamps3, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');

% Capillary 6 - Before brazing
timestamps4 = data4{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'};
pressure_diff4 = data4{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
mass_flow_rate4 = data4{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};
timeData4 = datetime(timestamps4, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');

%% Calculate mean value for each mass-flow step

% Instead of plotting every raw SCADA point, each time range is reduced
% to one average pressure-drop value and one average mass-flow value.

meanPressureDiff1 = [];
meanMassFlowRate1 = [];

meanPressureDiff2 = [];
meanMassFlowRate2 = [];

meanPressureDiff3 = [];
meanMassFlowRate3 = [];

meanPressureDiff4 = [];
meanMassFlowRate4 = [];

% Capillary 1
for i = 1:size(timeRanges1, 1)

    startTime = timeRanges1(i, 1);
    endTime = timeRanges1(i, 2);

    timeMask = (timeData1 >= startTime) & (timeData1 <= endTime);

    meanPressureDiff1 = [meanPressureDiff1; mean(pressure_diff1(timeMask), 'omitnan')];
    meanMassFlowRate1 = [meanMassFlowRate1; mean(mass_flow_rate1(timeMask), 'omitnan')];

end

% Capillary 2
for i = 1:size(timeRanges2, 1)

    startTime = timeRanges2(i, 1);
    endTime = timeRanges2(i, 2);

    timeMask = (timeData2 >= startTime) & (timeData2 <= endTime);

    meanPressureDiff2 = [meanPressureDiff2; mean(pressure_diff2(timeMask), 'omitnan')];
    meanMassFlowRate2 = [meanMassFlowRate2; mean(mass_flow_rate2(timeMask), 'omitnan')];

end

% Capillary 3
for i = 1:size(timeRanges3, 1)

    startTime = timeRanges3(i, 1);
    endTime = timeRanges3(i, 2);

    timeMask = (timeData3 >= startTime) & (timeData3 <= endTime);

    meanPressureDiff3 = [meanPressureDiff3; mean(pressure_diff3(timeMask), 'omitnan')];
    meanMassFlowRate3 = [meanMassFlowRate3; mean(mass_flow_rate3(timeMask), 'omitnan')];

end

% Capillary 4
for i = 1:size(timeRanges4, 1)

    startTime = timeRanges4(i, 1);
    endTime = timeRanges4(i, 2);

    timeMask = (timeData4 >= startTime) & (timeData4 <= endTime);

    meanPressureDiff4 = [meanPressureDiff4; mean(pressure_diff4(timeMask), 'omitnan')];
    meanMassFlowRate4 = [meanMassFlowRate4; mean(mass_flow_rate4(timeMask), 'omitnan')];

end

%% Remove possible NaN values caused by empty time ranges

valid1 = ~isnan(meanMassFlowRate1) & ~isnan(meanPressureDiff1);
meanMassFlowRate1 = meanMassFlowRate1(valid1);
meanPressureDiff1 = meanPressureDiff1(valid1);

valid2 = ~isnan(meanMassFlowRate2) & ~isnan(meanPressureDiff2);
meanMassFlowRate2 = meanMassFlowRate2(valid2);
meanPressureDiff2 = meanPressureDiff2(valid2);

valid3 = ~isnan(meanMassFlowRate3) & ~isnan(meanPressureDiff3);
meanMassFlowRate3 = meanMassFlowRate3(valid3);
meanPressureDiff3 = meanPressureDiff3(valid3);

valid4 = ~isnan(meanMassFlowRate4) & ~isnan(meanPressureDiff4);
meanMassFlowRate4 = meanMassFlowRate4(valid4);
meanPressureDiff4 = meanPressureDiff4(valid4);

%% Display separate results tables in the Command Window

resultsTable1 = table((1:numel(meanMassFlowRate1))', ...
    meanMassFlowRate1, meanPressureDiff1, ...
    'VariableNames', {'Step', 'AverageMassFlow_g_s', ...
    'AveragePressureDrop_bar'});

resultsTable2 = table((1:numel(meanMassFlowRate2))', ...
    meanMassFlowRate2, meanPressureDiff2, ...
    'VariableNames', {'Step', 'AverageMassFlow_g_s', ...
    'AveragePressureDrop_bar'});

resultsTable3 = table((1:numel(meanMassFlowRate3))', ...
    meanMassFlowRate3, meanPressureDiff3, ...
    'VariableNames', {'Step', 'AverageMassFlow_g_s', ...
    'AveragePressureDrop_bar'});

resultsTable4 = table((1:numel(meanMassFlowRate4))', ...
    meanMassFlowRate4, meanPressureDiff4, ...
    'VariableNames', {'Step', 'AverageMassFlow_g_s', ...
    'AveragePressureDrop_bar'});

fprintf('\nCAPILLARY P.O.B-D076-001\n\n');
disp(resultsTable1);

fprintf('\nCAPILLARY P.O.B-D076-002\n\n');
disp(resultsTable2);

fprintf('\nCAPILLARY P.O.B-D076-003\n\n');
disp(resultsTable3);

fprintf('\nCAPILLARY P.O.B-D076-004\n\n');
disp(resultsTable4);

%% Plot pressure drop vs mass flow rate

figure;
hold on;
grid on;

% Capillary 1
scatter(meanMassFlowRate1, meanPressureDiff1, 50, 'filled', ...
    'MarkerEdgeColor', 'blue', ...
    'MarkerFaceColor', 'blue', ...
    'DisplayName', 'Capillary P.O.B-D076-001');

[x_fit_1, trendline1] = quadraticTrendlineFromZero(meanMassFlowRate1, meanPressureDiff1);

plot(x_fit_1, trendline1, '-b', 'LineWidth', 1.5, ...
    'HandleVisibility', 'off');

% Capillary 2
scatter(meanMassFlowRate2, meanPressureDiff2, 50, 'filled', ...
    'MarkerEdgeColor', 'red', ...
    'MarkerFaceColor', 'red', ...
    'DisplayName', 'Capillary P.O.B-D076-002');

[x_fit_2, trendline2] = quadraticTrendlineFromZero(meanMassFlowRate2, meanPressureDiff2);

plot(x_fit_2, trendline2, '-r', 'LineWidth', 1.5, ...
    'HandleVisibility', 'off');

% Capillary 3
scatter(meanMassFlowRate3, meanPressureDiff3, 50, 'filled', ...
    'MarkerEdgeColor', 'green', ...
    'MarkerFaceColor', 'green', ...
    'DisplayName', 'Capillary P.O.B-D076-003');

[x_fit_3, trendline3] = quadraticTrendlineFromZero(meanMassFlowRate3, meanPressureDiff3);

plot(x_fit_3, trendline3, '-g', 'LineWidth', 1.5, ...
    'HandleVisibility', 'off');

% Capillary 4
scatter(meanMassFlowRate4, meanPressureDiff4, 50, ...
    'MarkerEdgeColor', 'cyan', ...
    'MarkerFaceColor', 'cyan', ...
    'DisplayName', 'Capillary P.O.B-D076-004');

[x_fit_4, trendline4] = quadraticTrendlineFromZero(meanMassFlowRate4, meanPressureDiff4);

plot(x_fit_4, trendline4, '-c', 'LineWidth', 1.5, ...
    'HandleVisibility', 'off');

%% Labels, title and legend

xlabel('Mass Flow Rate [g/s]');
ylabel('Pressure Drop DP1050 [bar]');
title('SS Capillaries I.D. 0.76 - Pressure Drop vs. Mass Flow Rate');
subtitle('m_{nominal} = 1.89 g/s | L = 3500 mm', ...
    'Interpreter', 'tex');

legend('Location', 'best');

xlim([0 2.4]);
xticks(0:0.1:2.4);
ylim([0 16]);
yticks(0:0.5:16);

% Small watermark
text(0.99, 0.02, 'Sara Memushaj', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 8, ...
    'FontAngle', 'italic', ...
    'Color', [0.60 0.60 0.60], ...
    'HandleVisibility', 'off');

hold off;

%% Local function

function [x_fit, y_fit] = quadraticTrendlineFromZero(x_data, y_data)

    x_data = x_data(:);
    y_data = y_data(:);

    valid = ~isnan(x_data) & ~isnan(y_data);
    x_data = x_data(valid);
    y_data = y_data(valid);

    if isempty(x_data)

        x_fit = [];
        y_fit = [];

    elseif length(x_data) == 1

        % With only one point, use y = a*x^2 so that the curve passes
        % through both (0,0) and the single measured point.
        a = y_data(1) / x_data(1)^2;

        x_fit = linspace(0, x_data(1), 100);
        y_fit = a*x_fit.^2;

    else

        % Quadratic fit constrained through the origin:
        % y = a*x^2 + b*x
        A = [x_data.^2, x_data];
        coeff = A \ y_data;

        a = coeff(1);
        b = coeff(2);

        x_fit = linspace(0, max(x_data), 100);
        y_fit = a*x_fit.^2 + b*x_fit;

    end

end
