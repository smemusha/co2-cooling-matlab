%% CAPILLARY TESTING RESULTS

% Post proceesing data (.csv files exported from SCADA) from the capillary testing setup in B180.
% Bach consistency test

%% Necessary paths for libraries

% Work PC ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% addpath('C:\Program Files\Matlab\R2023b')
% addpath(genpath('C:\Program Files (x86)\REFPROP'))
% addpath(genpath('C:\Users\smemusha\cernbox\WINDOWS\Desktop\CoBra Master'))
% addpath(genpath('C:\Users\smemusha\cernbox\WINDOWS\Desktop\ITk\Capilaries\Measurements'))

% Personal PC ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% addpath('C:\Program Files\Matlab\R2023b')
% addpath(genpath('C:\Program Files (x86)\REFPROP'))
% addpath(genpath('C:\Users\smemusha\cernbox\WINDOWS\Desktop\CoBra Master'))
% addpath(genpath('C:\Users\smemusha\cernbox\WINDOWS\Desktop\ITk\Capilaries\Measurements'))

%%
ID_cap = 1.10;
L_cap = 4000;

% Loading of CSV files
data1 = readtable('15.12.2025_COS_SS_OB_4000mm_1.1_OD.csv', 'VariableNamingRule', 'preserve');
data2 = readtable('17.12.2025_COS_SS_OB_3900mm_1.1_OD.csv', 'VariableNamingRule', 'preserve');
% data3 = readtable('17.12.2025_COS_SS_OB_3900mm_1.1_OD..csv', 'VariableNamingRule', 'preserve');
% data4 = readtable('17.12.2025_COS_SS_OB_3900mm_1.1_OD.csv', 'VariableNamingRule', 'preserve'); 
% data5 = readtable('17.12.2025_COS_SS_OB_3900mm_1.1_OD.csv', 'VariableNamingRule', 'preserve'); 
% data6 = readtable('17.12.2025_COS_SS_OB_3900mm_1.1_OD.csv', 'VariableNamingRule', 'preserve'); 
% data7 = readtable('2025.02.10_OB_1.1mm_4160mm_Straight_Part2.csv', 'VariableNamingRule', 'preserve');
% data8 = readtable('2025.02.10_OB_1.1mm_4160mm_Straight_Part2.csv', 'VariableNamingRule', 'preserve');
% data9 = readtable('2024.11.21_OB_099mm_2975mm_Straight.csv', 'VariableNamingRule', 'preserve'); 
% data10 = readtable('2024.11.21_OB_099mm_2975mm_Straight.csv', 'VariableNamingRule', 'preserve'); 

% Define time ranges for the first file
timeRanges1 = [... 
    datetime('2025/12/15 14:35:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/15 14:40:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    datetime('2025/12/17 15:05:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/17 15:10:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    % datetime('2025/12/15 15:25:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/15 15:30:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
];
timeRanges2 = [... 
    datetime('2025/12/15 15:10:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/15 15:15:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/12/17 15:45:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/17 15:50:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    % datetime('2025/12/17 15:25:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/17 15:30:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
];
timeRanges3 = [... 
    datetime('2025/12/15 15:25:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/15 15:30:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    datetime('2025/12/17 16:05:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/17 16:10:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    % datetime('2025/08/12 16:08:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/08/12 16:13:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
];
% timeRanges4 = [... 
%     datetime('2025/09/18 14:32:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/09/18 14:37:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
%     % datetime('2025/04/14 11:09:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/04/14 11:14:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
%     % datetime('2025/04/14 11:26:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/04/14 11:31:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
%     % datetime('2025/04/14 11:47:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/04/14 11:52:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
% ];
% timeRanges5 = [... 
%     datetime('2025/04/14 14:25:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/04/14 14:30:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
%     datetime('2025/04/14 14:39:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/04/14 14:44:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
%     datetime('2025/04/14 14:49:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/04/14 14:54:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
%     datetime('2025/04/14 15:13:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/04/14 15:18:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
% ];
% timeRanges6 = [...
%     datetime('2025/04/14 16:01:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/04/14 16:06:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
%     datetime('2025/04/14 16:15:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/04/14 16:20:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
%     datetime('2025/04/14 16:32:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/04/14 16:37:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
%     datetime('2025/04/14 16:52:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/04/14 16:57:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
% ];6
% timeRanges7 = [... 
%     datetime('2025/02/10 15:15:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/02/10 15:20:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
%     datetime('2025/02/10 15:30:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/02/10 15:35:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
%     datetime('2025/02/10 15:54:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/02/10 15:59:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
%     datetime('2025/02/10 16:12:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/02/10 16:17:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
% ];
% timeRanges8 = [... 
%     datetime('2025/02/10 16:31:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/02/10 16:36:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
%     datetime('2025/02/10 16:43:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/02/10 16:48:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
%     datetime('2025/02/10 16:56:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/02/10 17:00:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
%     datetime('2025/02/10 17:11:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/02/10 17:16:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
% ];
% timeRanges9 = [... 
%     datetime('2024/11/21 14:45:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2024/11/21 14:50:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
%     datetime('2024/11/21 15:00:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2024/11/21 15:05:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
%     datetime('2024/11/21 15:15:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2024/11/21 15:20:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
% ];
% timeRanges10 = [... 
%     datetime('2024/11/21 14:45:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2024/11/21 14:50:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
%     datetime('2024/11/21 15:00:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2024/11/21 15:05:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
%     datetime('2024/11/21 15:15:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2024/11/21 15:20:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
% ];

% Extracting columns from the files
timestamps1 = data1{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'};
pressure_diff1 = data1{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
mass_flow_rate1 = data1{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};
timeData1 = datetime(timestamps1, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');

timestamps2 = data2{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'};
pressure_diff2 = data2{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
mass_flow_rate2 = data2{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};
timeData2 = datetime(timestamps2, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
% 
% timestamps3 = data3{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'};
% pressure_diff3 = data3{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
% mass_flow_rate3 = data3{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};
% timeData3 = datetime(timestamps3, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
% 
% timestamps4 = data4{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'};
% pressure_diff4 = data4{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
% mass_flow_rate4 = data4{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};
% timeData4 = datetime(timestamps4, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
% 
% timestamps5 = data5{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'};
% pressure_diff5 = data5{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
% mass_flow_rate5 = data5{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};
% timeData5 = datetime(timestamps5, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
% 
% timestamps6 = data6{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'};
% pressure_diff6 = data6{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
% mass_flow_rate6 = data6{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};
% timeData6 = datetime(timestamps6, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');

% timestamps7 = data7{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'};
% pressure_diff7 = data7{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
% mass_flow_rate7 = data7{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};
% timeData7 = datetime(timestamps7, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
% 
% timestamps8 = data8{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'};
% pressure_diff8 = data8{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
% mass_flow_rate8 = data8{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};
% timeData8 = datetime(timestamps8, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');

% timestamps9 = data9{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'};
% pressure_diff9 = data9{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
% mass_flow_rate9 = data9{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};
% timeData9 = datetime(timestamps9, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
% 
% timestamps10 = data10{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'};
% pressure_diff10 = data10{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
% mass_flow_rate10 = data10{:, 'CO2_COS_F:@CS0f_M0_FT1030.PosSt'};
% timeData10 = datetime(timestamps10, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');

% Initialize arrays for combined data
allPressureDiff1 = [];
allMassFlowRate1 = [];

allPressureDiff2 = [];
allMassFlowRate2 = [];

% allPressureDiff3 = [];
% allMassFlowRate3 = [];
% 
% allPressureDiff4 = [];
% allMassFlowRate4 = [];

% allPressureDiff5 = [];
% allMassFlowRate5 = [];
% 
% allPressureDiff6 = [];
% allMassFlowRate6 = [];
% 
% allPressureDiff7 = [];
% allMassFlowRate7 = [];
% 
% allPressureDiff8 = [];
% allMassFlowRate8 = [];

% allPressureDiff9 = [];
% allMassFlowRate9 = [];
% 
% allPressureDiff10 = [];
% allMassFlowRate10 = [];

% Process time ranges for the 1st file
for i = 1:size(timeRanges1, 1)
    startTime = timeRanges1(i, 1);
    endTime = timeRanges1(i, 2);

    % Filter data for the current time range
    timeMask = (timeData1 >= startTime) & (timeData1 <= endTime);
    allPressureDiff1 = [allPressureDiff1; pressure_diff1(timeMask)];
    allMassFlowRate1 = [allMassFlowRate1; mass_flow_rate1(timeMask)];
end

% Process time ranges for the 2nd file
for i = 1:size(timeRanges2, 1)
    startTime = timeRanges2(i, 1);
    endTime = timeRanges2(i, 2);

    % Filter data for the current time range
    timeMask = (timeData2 >= startTime) & (timeData2 <= endTime);
    allPressureDiff2 = [allPressureDiff2; pressure_diff2(timeMask)];
    allMassFlowRate2 = [allMassFlowRate2; mass_flow_rate2(timeMask)];
end

% % Process time ranges for the 3rd file
% for i = 1:size(timeRanges3, 1)
%     startTime = timeRanges3(i, 1);
%     endTime = timeRanges3(i, 2);
% 
%     % Filter data for the current time range
%     timeMask = (timeData3 >= startTime) & (timeData3 <= endTime);
%     allPressureDiff3 = [allPressureDiff3; pressure_diff3(timeMask)];
%     allMassFlowRate3 = [allMassFlowRate3; mass_flow_rate3(timeMask)];
% end
% 
% % Process time ranges for the 4th file
% for i = 1:size(timeRanges4, 1)
%     startTime = timeRanges4(i, 1);
%     endTime = timeRanges4(i, 2);
% 
%     % Filter data for the current time range
%     timeMask = (timeData4 >= startTime) & (timeData4 <= endTime);
%     allPressureDiff4 = [allPressureDiff4; pressure_diff4(timeMask)];
%     allMassFlowRate4 = [allMassFlowRate4; mass_flow_rate4(timeMask)];
% end
% 
% % Process time ranges for the 5th file
% for i = 1:size(timeRanges5, 1)
%     startTime = timeRanges5(i, 1);
%     endTime = timeRanges5(i, 2);
% 
%     % Filter data for the current time range
%     timeMask = (timeData5 >= startTime) & (timeData5 <= endTime);
%     allPressureDiff5 = [allPressureDiff5; pressure_diff5(timeMask)];
%     allMassFlowRate5 = [allMassFlowRate5; mass_flow_rate5(timeMask)];
% end
% 
% % Process time ranges for the 6th file
% for i = 1:size(timeRanges6, 1)
%     startTime = timeRanges6(i, 1);
%     endTime = timeRanges6(i, 2);
% 
%     % Filter data for the current time range
%     timeMask = (timeData6 >= startTime) & (timeData6 <= endTime);
%     allPressureDiff6 = [allPressureDiff6; pressure_diff6(timeMask)];
%     allMassFlowRate6 = [allMassFlowRate6; mass_flow_rate6(timeMask)];
% end

% % Process time ranges for the 7th file
% for i = 1:size(timeRanges7, 1)
%     startTime = timeRanges7(i, 1);
%     endTime = timeRanges7(i, 2);
% 
%     % Filter data for the current time range
%     timeMask = (timeData7 >= startTime) & (timeData7 <= endTime);
%     allPressureDiff7 = [allPressureDiff7; pressure_diff7(timeMask)];
%     allMassFlowRate7 = [allMassFlowRate7; mass_flow_rate7(timeMask)];
% end
% 
% % Process time ranges for the 8th file
% for i = 1:size(timeRanges8, 1)
%     startTime = timeRanges8(i, 1);
%     endTime = timeRanges8(i, 2);
% 
%     % Filter data for the current time range
%     timeMask = (timeData8 >= startTime) & (timeData8 <= endTime);
%     allPressureDiff8 = [allPressureDiff8; pressure_diff8(timeMask)];
%     allMassFlowRate8 = [allMassFlowRate8; mass_flow_rate8(timeMask)];
% end

% % Process time ranges for the 9th file
% for i = 1:size(timeRanges9, 1)
%     startTime = timeRanges9(i, 1);
%     endTime = timeRanges9(i, 2);
% 
%     % Filter data for the current time range
%     timeMask = (timeData9 >= startTime) & (timeData9 <= endTime);
%     allPressureDiff9 = [allPressureDiff9; pressure_diff9(timeMask)];
%     allMassFlowRate9 = [allMassFlowRate9; mass_flow_rate9(timeMask)];
% end
% 
% % Process time ranges for the 10th file
% for i = 1:size(timeRanges10, 1)
%     startTime = timeRanges10(i, 1);
%     endTime = timeRanges10(i, 2);
% 
%     % Filter data for the current time range
%     timeMask = (timeData10 >= startTime) & (timeData10 <= endTime);
%     allPressureDiff10 = [allPressureDiff10; pressure_diff10(timeMask)];
%     allMassFlowRate10 = [allMassFlowRate10; mass_flow_rate10(timeMask)];
% end


%% Plot data and trendlines
figure;
hold on;
grid on;

% Plot data and trendline for the 1st file
scatter(allMassFlowRate1, allPressureDiff1, 0.1, 'filled', 'MarkerEdgeColor', 'blue', 'HandleVisibility', 'off'); 
coeff1 = polyfit(allMassFlowRate1, allPressureDiff1, 2);
x_fit_1 = linspace(min(allMassFlowRate1), max(allMassFlowRate1), 100); 
trendline1 = polyval(coeff1, x_fit_1);
plot(x_fit_1, trendline1, '-b', 'LineWidth', 1.5, 'DisplayName', 'Capillary No.1 (17.09.2025)');

% Plot data and trendline for the 2nd file
scatter(allMassFlowRate2, allPressureDiff2, 0.1, 'filled', 'MarkerEdgeColor', 'red', 'HandleVisibility', 'off');
coeff2 = polyfit(allMassFlowRate2, allPressureDiff2, 2);
x_fit_2 = linspace(min(allMassFlowRate2), max(allMassFlowRate2), 100); 
trendline2 = polyval(coeff2, x_fit_2);
plot(x_fit_2, trendline2, '-r', 'LineWidth', 1.5, 'DisplayName', 'Capillary No.1 - 1 coil (17.09.2025)');

% % Plot data and trendline for the 3rd file
% scatter(allMassFlowRate3, allPressureDiff3, 0.1, 'filled', 'MarkerEdgeColor', 'green', 'HandleVisibility', 'off');
% coeff3 = polyfit(allMassFlowRate3, allPressureDiff3, 2);
% x_fit_3 = linspace(min(allMassFlowRate3), max(allMassFlowRate3), 100); 
% trendline3 = polyval(coeff3, x_fit_3);
% plot(x_fit_3, trendline3, '-g', 'LineWidth', 1.5, 'DisplayName', 'Capillary No.1 - 2 coils (18.09.2025)');
% 
% % Plot data and trendline for the 4th file
% scatter(allMassFlowRate4, allPressureDiff4, 0.1, 'filled', 'MarkerEdgeColor', 'cyan', 'HandleVisibility', 'off');
% coeff4 = polyfit(allMassFlowRate4, allPressureDiff4, 2);
% x_fit_4 = linspace(min(allMassFlowRate4), max(allMassFlowRate4), 100); 
% trendline4 = polyval(coeff4, x_fit_4);
% plot(x_fit_4, trendline4, '--b', 'LineWidth', 1.5, 'DisplayName', 'Capillary No.1 - 3 coils (18.09.2025)');

% % Plot data and trendline for the 5th file
% scatter(allMassFlowRate5, allPressureDiff5, 1, 'filled', 'MarkerEdgeColor', 'red', 'HandleVisibility', 'off');
% coeff5 = polyfit(allMassFlowRate5, allPressureDiff5, 2);
% x_fit_5 = linspace(min(allMassFlowRate5), max(allMassFlowRate5), 100); 
% trendline5 = polyval(coeff5, x_fit_5);
% plot(x_fit_5, trendline5, '--r', 'LineWidth', 1.5, 'DisplayName', 'Capillary No.2 (14.04.2025)');
% 
% % Plot data and trendline for the 6th file
% scatter(allMassFlowRate6, allPressureDiff6, 0.1, 'filled', 'MarkerEdgeColor', 'red', 'HandleVisibility', 'off');
% coeff6 = polyfit(allMassFlowRate6, allPressureDiff6, 2);
% x_fit_6 = linspace(min(allMassFlowRate6), max(allMassFlowRate6), 100); 
% trendline6 = polyval(coeff6, x_fit_6);
% plot(x_fit_6, trendline6, '--g', 'LineWidth', 1.5, 'DisplayName', 'Capillary No.3 (14.04.2025)');

% % Plot data and trendline for the 7th file
% scatter(allMassFlowRate7, allPressureDiff7, 0.1, 'filled', 'MarkerEdgeColor', 'red', 'HandleVisibility', 'off');
% coeff7 = polyfit(allMassFlowRate7, allPressureDiff7, 2);
% x_fit_7 = linspace(min(allMassFlowRate7), max(allMassFlowRate7), 100); 
% trendline7 = polyval(coeff7, x_fit_7);
% plot(x_fit_7, trendline7, '-k', 'LineWidth', 1.5, 'DisplayName', 'Capillary No.7');
% 
% % Plot data and trendline for the 8th file
% scatter(allMassFlowRate8, allPressureDiff8, 0.1, 'filled', 'MarkerEdgeColor', 'red', 'HandleVisibility', 'off');
% coeff8 = polyfit(allMassFlowRate8, allPressureDiff8, 2);
% x_fit_8 = linspace(min(allMassFlowRate8), max(allMassFlowRate8), 100); 
% trendline8 = polyval(coeff8, x_fit_8);
% plot(x_fit_8, trendline8, '--r', 'LineWidth', 1.5, 'DisplayName', 'Capillary No.8');

% % Plot data and trendline for the 9th file
% scatter(allMassFlowRate9, allPressureDiff9, 1, 'filled', 'MarkerEdgeColor', 'red', 'HandleVisibility', 'off');
% coeff9 = polyfit(allMassFlowRate9, allPressureDiff9, 2);
% x_fit_9 = linspace(min(allMassFlowRate9), max(allMassFlowRate9), 100); 
% trendline9 = polyval(coeff9, x_fit_9);
% plot(x_fit_9, trendline9, '--b', 'LineWidth', 1.5, 'DisplayName', 'Capillary No.9');
% 
% % Plot data and trendline for the 10th file
% scatter(allMassFlowRate10, allPressureDiff10, 1, 'filled', 'MarkerEdgeColor', 'red', 'HandleVisibility', 'off');
% coeff10 = polyfit(allMassFlowRate10, allPressureDiff10, 2);
% x_fit_10 = linspace(min(allMassFlowRate10), max(allMassFlowRate10), 100); 
% trendline10 = polyval(coeff10, x_fit_10);
% plot(x_fit_10, trendline10, '--g', 'LineWidth', 1.5, 'DisplayName', 'Capillary No.10');

% Add labels and legend
xlabel('Mass Flow Rate (g/s)'); 
% xticks(1.5:0.1:5)
ylabel('Pressure Drop (bar)');
% yticks(0:0.5:14);
title(sprintf('Capillary Batch Consistency - Coiled\nPressure Drop (DP1050) vs. Mass Flow Rate\nID = %.2f mm | L = %.0f mm', ID_cap, L_cap));
legend('Location', 'southeast');
hold off;

%% === EXTRA SECTION: Average ΔP at specified mass flows for each capillary ===
% Target mass flows from the table (g/s)
targetMassFlows = [4.17; 3.20; 2.60; 1.80];

% Tolerances (in g/s)
tol_primary  = 0.05;   % ±0.05 g/s window
tol_fallback = 0.10;   % broaden to ±0.10 g/s if empty
k_nearest    = 25;     % final fallback: average of nearest N samples

% Collect available datasets (1..6)
mfCell = {};
dpCell = {};
for capIdx = 1:6
    mfName = sprintf('allMassFlowRate%d', capIdx);
    dpName = sprintf('allPressureDiff%d', capIdx);
    if exist(mfName,'var') && exist(dpName,'var')
        mfCell{end+1} = eval(mfName); %#ok<EVLDIR,AGROW>
        dpCell{end+1} = eval(dpName); %#ok<EVLDIR,AGROW>
    end
end
nCaps = numel(mfCell);

if nCaps == 0
    warning('No allMassFlowRate*/allPressureDiff* datasets found. Nothing to compute.');
else
    % Compute averages (rows = target Mdot, cols = Capillary)
    avgMat = nan(numel(targetMassFlows), nCaps);

    for j = 1:nCaps
        mf = mfCell{j};
        dp = dpCell{j};

        for k = 1:numel(targetMassFlows)
            t = targetMassFlows(k);

            % Primary window
            idx = abs(mf - t) <= tol_primary;

            % Fallback window
            if ~any(idx)
                idx = abs(mf - t) <= tol_fallback;
            end

            % Final fallback: nearest k_nearest samples
            if ~any(idx) && ~isempty(mf)
                [~, order] = sort(abs(mf - t), 'ascend');
                idx = order(1:min(k_nearest, numel(order)));
            end

            if any(idx)
                avgMat(k, j) = mean(dp(idx), 'omitnan');
            else
                avgMat(k, j) = NaN;
            end
        end
    end

    % Build results table with custom column names
    colNames = cell(1, nCaps+1);
    colNames{1} = 'Massflow_g_s';
    for j = 1:nCaps
        if j <= 3
            colNames{j+1} = sprintf('Capillary No.%d (17.09.2025)', j);
        else
            colNames{j+1} = sprintf('Capillary No.%d - 1 coil (17.09.2025)', j-3);
        end
    end

    AverageDP_byMassflow = array2table([targetMassFlows, round(avgMat, 2)], ...
        'VariableNames', colNames);

    % Show in Command Window
    fprintf('\n=== Average ΔP at specified mass flows (bar) ===\n');
    disp(AverageDP_byMassflow);

    % Save to CSV in current script folder
    writetable(AverageDP_byMassflow, 'AverageDP_byMassflow.csv');
    fprintf('Results saved to %s\n', fullfile(pwd, 'AverageDP_byMassflow.csv'));
end
