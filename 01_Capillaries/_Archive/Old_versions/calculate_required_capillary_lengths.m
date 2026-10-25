%% REQUIRED CAPILLARY LENGTHS FROM EXPERIMENTAL DATA
%
% Uses measurements obtained with four 3500 mm capillaries to calculate
% the length required for each capillary to produce the target pressure
% drop at the target mass-flow rate.
%
% Assumption at constant mass flow:
%       pressure drop is proportional to capillary length
%
% Therefore:
%       L_required = L_test * DP_target / DP_at_target_flow

clear;
clc;

%% User inputs

testLength = 3500;         % Experimental capillary length [mm]
targetPressureDrop = 8.75; % Required pressure drop [bar]
targetMassFlow = 1.89;     % Required mass-flow rate [g/s]

%% CSV files and capillary names

fileNames = {
    'POB COS Data 2026-08-26  Flow Scan P.O.B-D076-001.csv'
    'POB COS Data 2026-08-27  Flow Scan P.O.B-D076-002.csv'
    'POB COS1, Data 27-08-2026,Flow Scan, P.O.B-D076-003.csv'
    'POB COS1, Data 26-08-2026,Flow Scan, P.O.B-D076-004.csv'
};

capillaryNames = {
    'P.O.B-D076-001'
    'P.O.B-D076-002'
    'P.O.B-D076-003'
    'P.O.B-D076-004'
};

%% Stable time ranges for the four mass-flow steps

timeRanges = cell(4, 1);

timeRanges{1} = [
    datetime('2026/08/26 14:54:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/08/26 14:59:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/08/26 15:20:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/08/26 15:25:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/08/26 15:34:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/08/26 15:39:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/08/26 15:50:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/08/26 15:55:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS')
];

timeRanges{2} = [
    datetime('2026/08/27 10:01:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/08/27 10:06:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/08/27 10:25:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/08/27 10:30:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/08/27 10:47:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/08/27 10:52:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/08/27 11:15:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/08/27 11:20:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS')
];

timeRanges{3} = [
    datetime('2026/08/27 15:50:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/08/27 15:55:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/08/27 15:31:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/08/27 15:36:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/08/27 15:03:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/08/27 15:08:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/08/27 14:45:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/08/27 14:50:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS')
];

timeRanges{4} = [
    datetime('2026/08/26 10:36:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/08/26 10:41:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/08/26 10:54:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/08/26 10:59:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/08/26 11:17:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/08/26 11:22:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/08/26 11:39:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/08/26 11:44:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS')
];

%% Read data, average each stable step and interpolate at target mass flow

pressureAtTargetFlow = nan(4, 1);
requiredLength = nan(4, 1);

timeColumn = 'Year/Month/Day Hour:Minute:Second.Millisecond';
pressureColumn = 'CO2_COS_F:@CS0f_M0_DP1050.PosSt';
flowColumn = 'CO2_COS_F:@CS0f_M0_FT1030.PosSt';

for capillaryIndex = 1:4

    data = readtable(fileNames{capillaryIndex}, ...
        'VariableNamingRule', 'preserve');

    timeData = datetime(data{:, timeColumn}, ...
        'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    pressureData = data{:, pressureColumn};
    flowData = data{:, flowColumn};

    numberOfSteps = size(timeRanges{capillaryIndex}, 1);
    meanPressure = nan(numberOfSteps, 1);
    meanFlow = nan(numberOfSteps, 1);

    for stepIndex = 1:numberOfSteps
        startTime = timeRanges{capillaryIndex}(stepIndex, 1);
        endTime = timeRanges{capillaryIndex}(stepIndex, 2);
        timeMask = timeData >= startTime & timeData <= endTime;

        meanPressure(stepIndex) = mean(pressureData(timeMask), 'omitnan');
        meanFlow(stepIndex) = mean(flowData(timeMask), 'omitnan');
    end

    valid = ~isnan(meanFlow) & ~isnan(meanPressure);
    meanFlow = meanFlow(valid);
    meanPressure = meanPressure(valid);

    % Sort because interp1 requires increasing mass-flow values.
    [meanFlow, sortIndex] = sort(meanFlow);
    meanPressure = meanPressure(sortIndex);

    if numel(meanFlow) < 2
        warning('%s has fewer than two valid experimental points.', ...
            capillaryNames{capillaryIndex});
        continue;
    end

    if targetMassFlow < min(meanFlow) || targetMassFlow > max(meanFlow)
        warning(['For %s, %.2f g/s is outside the measured range ' ...
            '[%.3f, %.3f] g/s. The result uses extrapolation.'], ...
            capillaryNames{capillaryIndex}, targetMassFlow, ...
            min(meanFlow), max(meanFlow));
    end

    % Shape-preserving interpolation of the measured pressure-drop curve.
    pressureAtTargetFlow(capillaryIndex) = interp1( ...
        meanFlow, meanPressure, targetMassFlow, 'pchip', 'extrap');

    % Scale the tested length at constant mass flow.
    requiredLength(capillaryIndex) = testLength * targetPressureDrop / ...
        pressureAtTargetFlow(capillaryIndex);
end

%% Display results

requiredDP = repmat(targetPressureDrop, 4, 1);

results = table(string(capillaryNames), pressureAtTargetFlow, requiredDP, ...
    requiredLength, ...
    'VariableNames', {'Capillary', 'DP_at_3500_mm_bar', ...
    'DP_required_bar', 'Required_length_mm'});

results.Required_length_mm = round(results.Required_length_mm);

fprintf('\nTarget: DP = %.2f bar at mass flow = %.2f g/s\n', ...
    targetPressureDrop, targetMassFlow);
fprintf('Experimental reference length: %.0f mm\n\n', testLength);
disp(results);

%% Plot calculated required lengths

figure;
bar(requiredLength);
grid on;

xticks(1:4);
xticklabels(capillaryNames);
xtickangle(20);
ylabel('Required Capillary Length [mm]');
title('Required Length for Each Capillary');
subtitle(sprintf('Target: DP = %.2f bar at %.2f g/s', ...
    targetPressureDrop, targetMassFlow));

yLimits = ylim;
for capillaryIndex = 1:4
    text(capillaryIndex, requiredLength(capillaryIndex) + 0.02*diff(yLimits), ...
        sprintf('%.0f mm', requiredLength(capillaryIndex)), ...
        'HorizontalAlignment', 'center');
end

% Small watermark
text(0.99, 0.02, 'Sara Memushaj', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 8, ...
    'FontAngle', 'italic', ...
    'Color', [0.60 0.60 0.60], ...
    'HandleVisibility', 'off');
