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

data1 = readtable('POB COS Data 11-06-2026 Capillary-01 Flow Scan.csv', 'VariableNamingRule', 'preserve');
data2 = readtable('POB COS Data 12-06-2026 Capillary-02 Flow Scan.csv', 'VariableNamingRule', 'preserve');
data3 = readtable('POB COS Data 12-06-2026 Capillary-03 Flow Scan.csv', 'VariableNamingRule', 'preserve');
data4 = readtable('09.01.2026_COS_SS_OB_3200mm_1.1_OD.csv', 'VariableNamingRule', 'preserve');
data5 = readtable('12.01.2026_COS_SS_OB_3300_3200mm_1.1_OD_CAP8.csv', 'VariableNamingRule', 'preserve');

%% Definition of time ranges

% Each row corresponds to one stable mass-flow step.
% timeRanges1, 2, 3: Capillaries 6, 7, 8 after brazing
% timeRanges4, 5, 6: Capillaries 6, 7, 8 before brazing

% Capillary 6 - After brazing
timeRanges1 = [... 
    datetime('2026/06/11 14:53:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/11 14:58:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    datetime('2026/06/11 15:35:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/11 15:40:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/11 15:51:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/11 15:56:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/11 16:08:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/11 16:13:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/11 16:25:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/11 16:30:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
];

% Capillary 7 - After brazing
timeRanges2 = [... 
    datetime('2026/06/12 10:04:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/12 10:09:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/12 10:14:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/12 10:19:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/12 10:27:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/12 10:32:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/12 10:43:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/12 10:48:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/12 11:03:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/12 11:08:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
];

% Capillary 8 - After brazing
timeRanges3 = [... 
    datetime('2026/06/12 14:30:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/12 14:35:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/12 14:41:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/12 14:46:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/12 14:54:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/12 14:59:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/12 15:11:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/12 15:16:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/06/12 15:30:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/12 15:35:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
];

% Capillary 6 - Before brazing
% Data taken from data4
timeRanges4 = [... 
    datetime('2026/01/09 14:52:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/01/09 14:57:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
];

% Capillary 7 - Before brazing
% Data taken from data4
timeRanges5 = [... 
    datetime('2026/01/09 15:13:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/01/09 15:18:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
];

% Capillary 8 - Before brazing
% Data taken from data5
timeRanges6 = [... 
    datetime('2026/01/12 14:43:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/01/12 14:48:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
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

% Capillaries 6 and 7 - Before brazing
timestamps4 = data4{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'};
pressure_diff4 = data4{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
mass_flow_rate4 = data4{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};
timeData4 = datetime(timestamps4, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');

% Capillary 8 - Before brazing
timestamps5 = data5{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'};
pressure_diff5 = data5{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
mass_flow_rate5 = data5{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};
timeData5 = datetime(timestamps5, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');

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

meanPressureDiff5 = [];
meanMassFlowRate5 = [];

meanPressureDiff6 = [];
meanMassFlowRate6 = [];

% Capillary 6 - After brazing
for i = 1:size(timeRanges1, 1)

    startTime = timeRanges1(i, 1);
    endTime = timeRanges1(i, 2);

    timeMask = (timeData1 >= startTime) & (timeData1 <= endTime);

    meanPressureDiff1 = [meanPressureDiff1; mean(pressure_diff1(timeMask), 'omitnan')];
    meanMassFlowRate1 = [meanMassFlowRate1; mean(mass_flow_rate1(timeMask), 'omitnan')];

end

% Capillary 7 - After brazing
for i = 1:size(timeRanges2, 1)

    startTime = timeRanges2(i, 1);
    endTime = timeRanges2(i, 2);

    timeMask = (timeData2 >= startTime) & (timeData2 <= endTime);

    meanPressureDiff2 = [meanPressureDiff2; mean(pressure_diff2(timeMask), 'omitnan')];
    meanMassFlowRate2 = [meanMassFlowRate2; mean(mass_flow_rate2(timeMask), 'omitnan')];

end

% Capillary 8 - After brazing
for i = 1:size(timeRanges3, 1)

    startTime = timeRanges3(i, 1);
    endTime = timeRanges3(i, 2);

    timeMask = (timeData3 >= startTime) & (timeData3 <= endTime);

    meanPressureDiff3 = [meanPressureDiff3; mean(pressure_diff3(timeMask), 'omitnan')];
    meanMassFlowRate3 = [meanMassFlowRate3; mean(mass_flow_rate3(timeMask), 'omitnan')];

end

% Capillary 6 - Before brazing
for i = 1:size(timeRanges4, 1)

    startTime = timeRanges4(i, 1);
    endTime = timeRanges4(i, 2);

    timeMask = (timeData4 >= startTime) & (timeData4 <= endTime);

    meanPressureDiff4 = [meanPressureDiff4; mean(pressure_diff4(timeMask), 'omitnan')];
    meanMassFlowRate4 = [meanMassFlowRate4; mean(mass_flow_rate4(timeMask), 'omitnan')];

end

% Capillary 7 - Before brazing
for i = 1:size(timeRanges5, 1)

    startTime = timeRanges5(i, 1);
    endTime = timeRanges5(i, 2);

    timeMask = (timeData4 >= startTime) & (timeData4 <= endTime);

    meanPressureDiff5 = [meanPressureDiff5; mean(pressure_diff4(timeMask), 'omitnan')];
    meanMassFlowRate5 = [meanMassFlowRate5; mean(mass_flow_rate4(timeMask), 'omitnan')];

end

% Capillary 8 - Before brazing
for i = 1:size(timeRanges6, 1)

    startTime = timeRanges6(i, 1);
    endTime = timeRanges6(i, 2);

    timeMask = (timeData5 >= startTime) & (timeData5 <= endTime);

    meanPressureDiff6 = [meanPressureDiff6; mean(pressure_diff5(timeMask), 'omitnan')];
    meanMassFlowRate6 = [meanMassFlowRate6; mean(mass_flow_rate5(timeMask), 'omitnan')];

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

valid5 = ~isnan(meanMassFlowRate5) & ~isnan(meanPressureDiff5);
meanMassFlowRate5 = meanMassFlowRate5(valid5);
meanPressureDiff5 = meanPressureDiff5(valid5);

valid6 = ~isnan(meanMassFlowRate6) & ~isnan(meanPressureDiff6);
meanMassFlowRate6 = meanMassFlowRate6(valid6);
meanPressureDiff6 = meanPressureDiff6(valid6);

%% Plot pressure drop vs mass flow rate

figure;
hold on;
grid on;

% Capillary 6 - After brazing
scatter(meanMassFlowRate1, meanPressureDiff1, 50, 'filled', ...
    'MarkerEdgeColor', 'blue', ...
    'MarkerFaceColor', 'blue', ...
    'DisplayName', 'Capillary 6 - After brazing');

[x_fit_1, trendline1] = quadraticTrendlineFromZero(meanMassFlowRate1, meanPressureDiff1);

plot(x_fit_1, trendline1, '-b', 'LineWidth', 1.5, ...
    'DisplayName', 'Trendline Capillary 6 - After brazing');

% Capillary 7 - After brazing
scatter(meanMassFlowRate2, meanPressureDiff2, 50, 'filled', ...
    'MarkerEdgeColor', 'red', ...
    'MarkerFaceColor', 'red', ...
    'DisplayName', 'Capillary 7 - After brazing');

[x_fit_2, trendline2] = quadraticTrendlineFromZero(meanMassFlowRate2, meanPressureDiff2);

plot(x_fit_2, trendline2, '-r', 'LineWidth', 1.5, ...
    'DisplayName', 'Trendline Capillary 7 - After brazing');

% Capillary 8 - After brazing
scatter(meanMassFlowRate3, meanPressureDiff3, 50, 'filled', ...
    'MarkerEdgeColor', 'green', ...
    'MarkerFaceColor', 'green', ...
    'DisplayName', 'Capillary 8 - After brazing');

[x_fit_3, trendline3] = quadraticTrendlineFromZero(meanMassFlowRate3, meanPressureDiff3);

plot(x_fit_3, trendline3, '-g', 'LineWidth', 1.5, ...
    'DisplayName', 'Trendline Capillary 8 - After brazing');

% Capillary 6 - Before brazing
scatter(meanMassFlowRate4, meanPressureDiff4, 50, ...
    'MarkerEdgeColor', 'blue', ...
    'MarkerFaceColor', 'none', ...
    'DisplayName', 'Capillary 6 - Before brazing');

[x_fit_4, trendline4] = quadraticTrendlineFromZero(meanMassFlowRate4, meanPressureDiff4);

plot(x_fit_4, trendline4, '--b', 'LineWidth', 1.5, ...
    'DisplayName', 'Trendline Capillary 6 - Before brazing');

% Capillary 7 - Before brazing
scatter(meanMassFlowRate5, meanPressureDiff5, 50, ...
    'MarkerEdgeColor', 'red', ...
    'MarkerFaceColor', 'none', ...
    'DisplayName', 'Capillary 7 - Before brazing');

[x_fit_5, trendline5] = quadraticTrendlineFromZero(meanMassFlowRate5, meanPressureDiff5);

plot(x_fit_5, trendline5, '--r', 'LineWidth', 1.5, ...
    'DisplayName', 'Trendline Capillary 7 - Before brazing');

% Capillary 8 - Before brazing
scatter(meanMassFlowRate6, meanPressureDiff6, 50, ...
    'MarkerEdgeColor', 'green', ...
    'MarkerFaceColor', 'none', ...
    'DisplayName', 'Capillary 8 - Before brazing');

[x_fit_6, trendline6] = quadraticTrendlineFromZero(meanMassFlowRate6, meanPressureDiff6);

plot(x_fit_6, trendline6, '--g', 'LineWidth', 1.5, ...
    'DisplayName', 'Trendline Capillary 8 - Before brazing');

%% Labels, title and legend

xlabel('Mass Flow Rate [g/s]');
ylabel('Pressure Drop DP1050 [bar]');
title('Interalloy Capillaries 6, 7 and 8 (Before and After Brazing) - Pressure Drop vs. Mass Flow Rate, L = 3200 mm');

legend('Location', 'best');

xlim([0 inf]);
ylim([0 9]);
yticks(0:0.5:9);

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