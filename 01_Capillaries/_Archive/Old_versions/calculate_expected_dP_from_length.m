%% EXPECTED PRESSURE DROP FROM EXPERIMENTAL DATA (B180)
% Import all SCADA files once. Select each capillary solely by time ranges.
% At fixed flow: DP_expected = DP_test * currentLength / testLength.
clear; clc;

%% ================================================================
%  INPUTS
% ================================================================

% 1) SCADA CSV recordings (each file ONCE, irrespective of capillary)
%    Use full paths or files accessible from MATLAB's current folder/path.
fileNames = {
    'POB COS Data 2026-10-22  POB-D076-009, POB-D076-010,POB-D076-011,POB-D076-012.csv'
    'POB COS1, Data 21-10-2026,Flow Scan, P.O.B-D076-009,P.O.B-D076-010,P.O.B-D076-011,P.O.B-D076-012 .csv'
};

% 2) Capillary IDs - order must match lengths and time ranges below.
capillaryNames = {
    'P.O.B-D076-009'
    'P.O.B-D076-010'
    'P.O.B-D076-011'
    'P.O.B-D076-012'
};

% 3) Lengths [mm] - in the same order as capillaryNames.
testLength = [3500; 3500; 3500; 3500]; % Length during SCADA test
currentLength = [2940; 3160; 3473; 3297]; % Length to predict dP for

% 4) Target mass flow [g/s]
targetMassFlow = 1.89;

% 5) Output directory and result filename
outputFolder = 'C:\Users\smemusha\cernbox\WINDOWS\Desktop\ITk\Capilaries\Measurements\Interalloy batch\PRODUCTION\I.D_0.76\No.9-12';
expectedResultsFile = 'POB-D076-009_to_012_expected_dP_results.csv';

% 6) SCADA column headers (edit only if the export format changes)
timeColumn = 'Year/Month/Day Hour:Minute:Second.Millisecond';
pressureColumn = 'CO2_COS_F:@CS0f_M0_DP1050.PosSt';
flowColumn = 'CO2_COS_F:@CS0f_M0_FT1030.PosSt';
timeFormat = 'yyyy/MM/dd HH:mm:ss.SSS';

% 7) Stable time ranges - one [start, end] row per measured flow step.
%    Ranges are associated by order with the capillary IDs above.
%    Verify these timestamps correspond to the intended capillaries.
% Capillary 9
timeRanges1 = [... 
    datetime('2026/10/21 19:04:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/21 19:09:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    datetime('2026/10/21 17:22:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/21 17:27:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    datetime('2026/10/22 08:00:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 08:05:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/10/22 09:24:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 09:29:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
];

% Capillary 10
timeRanges2 = [... 
    datetime('2026/10/21 18:46:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/21 18:51:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/10/21 17:38:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/21 17:43:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/10/22 08:17:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 08:22:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/10/22 09:38:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 09:43:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
];

% Capillary 11
timeRanges3 = [... 
    datetime('2026/10/21 18:29:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/21 18:34:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/10/21 17:52:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/21 17:57:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/10/22 08:35:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 08:40:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/10/22 09:56:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 10:01:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
];

% Capillary 12
timeRanges4 = [... 
    datetime('2026/10/21 18:17:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/21 18:22:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/10/21 18:05:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/21 18:10:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/10/22 08:51:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 08:56:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/10/22 10:13:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 10:18:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
];

timeRanges = {timeRanges1, timeRanges2, timeRanges3, timeRanges4};

%% ================================================================
%  END USER INPUTS - ANALYSIS BELOW
% ================================================================

nCapillaries = numel(capillaryNames);
testLength = testLength(:);
currentLength = currentLength(:);
assert(numel(fileNames) > 0, 'Add at least one source CSV filename.');
assert(numel(testLength) == nCapillaries && ...
    all(isfinite(testLength)) && all(testLength > 0), ...
    'Enter one positive test length per capillary.');
assert(numel(currentLength) == nCapillaries && ...
    all(isfinite(currentLength)) && all(currentLength > 0), ...
    'Enter one positive current length per capillary.');
assert(numel(timeRanges) == nCapillaries, ...
    'The number of time-range sets must equal the number of capillaries.');
assert(isscalar(targetMassFlow) && isfinite(targetMassFlow) && ...
    targetMassFlow > 0, 'Enter a positive target mass flow.');
if ~isfolder(outputFolder)
    error('Output directory does not exist: %s', outputFolder);
end

%% Import all CSVs into a common dataset; files are NOT capillary-specific
allTime = datetime.empty(0,1);
allPressure = zeros(0,1);
allFlow = zeros(0,1);
for fileIndex = 1:numel(fileNames)
    raw = readtable(fileNames{fileIndex}, 'VariableNamingRule', 'preserve');
    rawTime = raw{:, timeColumn};
    if isdatetime(rawTime)
        t = rawTime(:);
    else
        t = datetime(string(rawTime(:)), 'InputFormat', timeFormat);
    end
    p = raw{:, pressureColumn};
    m = raw{:, flowColumn};
    if ~isnumeric(p), p = str2double(string(p)); end
    if ~isnumeric(m), m = str2double(string(m)); end
    allTime = [allTime; t(:)];
    allPressure = [allPressure; double(p(:))];
    allFlow = [allFlow; double(m(:))];
end

% Remove identical duplicate recordings, not legitimate different readings.
[allTime, order] = sort(allTime);
allPressure = allPressure(order);
allFlow = allFlow(order);
[~, keep] = unique(table(allTime, allPressure, allFlow), 'rows', 'stable');
allTime = allTime(keep);
allPressure = allPressure(keep);
allFlow = allFlow(keep);
fprintf('Imported %d SCADA samples from %d CSV files.\n', ...
    numel(allTime), numel(fileNames));

%% Stable-step statistics and fitted pressure predictions
pressureAtTargetFlow = nan(nCapillaries,1);
pressureStdAtTargetFlow = nan(nCapillaries,1);
expectedPressure = nan(nCapillaries,1);
expectedPressureStd = nan(nCapillaries,1);
rSquared = nan(nCapillaries,1);
outsideMeasuredRange = false(nCapillaries,1);
allStepResults = table();

for c = 1:nCapillaries
    intervals = timeRanges{c};
    nSteps = size(intervals,1);
    meanPressure = nan(nSteps,1);
    meanFlow = nan(nSteps,1);
    stdPressure = nan(nSteps,1);
    stdFlow = nan(nSteps,1);
    sampleCount = zeros(nSteps,1);

    for stepIndex = 1:nSteps
        selected = allTime >= intervals(stepIndex,1) & ...
                   allTime <= intervals(stepIndex,2) & ...
                   isfinite(allPressure) & isfinite(allFlow);
        sampleCount(stepIndex) = nnz(selected);
        if sampleCount(stepIndex) == 0
            warning('%s step %d: no valid data for selected interval.', ...
                capillaryNames{c}, stepIndex);
            continue;
        end
        meanPressure(stepIndex) = mean(allPressure(selected));
        meanFlow(stepIndex) = mean(allFlow(selected));
        stdPressure(stepIndex) = std(allPressure(selected), 0);
        stdFlow(stepIndex) = std(allFlow(selected), 0);
    end

    % Only valid time batches enter the calculations; retain batch numbers.
    valid = isfinite(meanFlow) & isfinite(meanPressure);
    originalStep = find(valid);
    meanFlow = meanFlow(valid);
    meanPressure = meanPressure(valid);
    stdFlow = stdFlow(valid);
    stdPressure = stdPressure(valid);
    sampleCount = sampleCount(valid);
    [meanFlow, idx] = sort(meanFlow);
    meanPressure = meanPressure(idx);
    stdFlow = stdFlow(idx);
    stdPressure = stdPressure(idx);
    sampleCount = sampleCount(idx);
    originalStep = originalStep(idx);

    cvFlow = 100 * stdFlow ./ meanFlow;
    cvPressure = 100 * stdPressure ./ meanPressure;
    stepResults = table(originalStep, sampleCount, meanFlow, stdFlow, ...
        cvFlow, meanPressure, stdPressure, cvPressure, ...
        'VariableNames', {'Step','N','Mean_mass_flow_g_s', ...
        'STD_mass_flow_g_s','CV_mass_flow_percent', ...
        'Mean_pressure_drop_bar','STD_pressure_drop_bar', ...
        'CV_pressure_drop_percent'});
    fprintf('\nCapillary %s\n', capillaryNames{c});
    disp(stepResults);
    stepResults = addvars(stepResults, ...
        repmat(string(capillaryNames{c}),height(stepResults),1), ...
        'Before',1,'NewVariableNames','Capillary');
    allStepResults = [allStepResults; stepResults];

    if numel(meanFlow) < 2
        warning('%s has fewer than two valid flow steps; dP prediction left NaN.', ...
            capillaryNames{c});
        continue;
    end
    outsideMeasuredRange(c) = targetMassFlow < min(meanFlow) || ...
                              targetMassFlow > max(meanFlow);
    if outsideMeasuredRange(c)
        warning('%s target flow %.2f g/s outside [%.3f, %.3f] g/s: extrapolation.', ...
            capillaryNames{c}, targetMassFlow, min(meanFlow), max(meanFlow));
    end

    % Constrained quadratic through the origin: dP = a*F^2 + b*F
    A = [meanFlow.^2, meanFlow];
    coeff = A \ meanPressure;
    fitted = A * coeff;
    ssTotal = sum((meanPressure - mean(meanPressure)).^2);
    if ssTotal > 0
        rSquared(c) = 1 - sum((meanPressure - fitted).^2) / ssTotal;
    end
    pressureAtTargetFlow(c) = [targetMassFlow^2, targetMassFlow] * coeff;
    % As in the original script, interpolate SCADA pressure scatter by flow.
    % For duplicate mean-flow values, consolidate their SDs before interp1.
    [uniqueFlows, ~, group] = unique(meanFlow);
    uniqueStds = accumarray(group, stdPressure, [], @mean);
    if numel(uniqueFlows) >= 2
        pressureStdAtTargetFlow(c) = interp1(uniqueFlows, uniqueStds, ...
            targetMassFlow, 'linear', 'extrap');
    else
        pressureStdAtTargetFlow(c) = uniqueStds(1);
    end

    scale = currentLength(c) / testLength(c);
    expectedPressure(c) = pressureAtTargetFlow(c) * scale;
    expectedPressureStd(c) = pressureStdAtTargetFlow(c) * scale;
end

if isempty(allStepResults)
    error('No stable time ranges matched SCADA data. Check CSV dates/timestamps.');
end

%% Display and export results to the user-selected directory
results = table(string(capillaryNames), rSquared, testLength, currentLength, ...
    pressureAtTargetFlow, pressureStdAtTargetFlow, expectedPressure, ...
    expectedPressureStd, 'VariableNames', {'Capillary', 'R_squared', ...
    'Test_length_mm', 'Current_length_mm', 'DP_at_test_length_bar', ...
    'DP_std_at_test_length_bar', 'Expected_DP_bar', 'Expected_DP_std_bar'});
fprintf('\nExpected pressure drop at target mass flow %.2f g/s\n', targetMassFlow);
disp(results);

resultsFile = fullfile(outputFolder, expectedResultsFile);
writetable(results, resultsFile);
fprintf('Expected dP results exported to: %s\n', resultsFile);

%% Plot expected pressure drop with standard deviation error bars
figure;
bar(expectedPressure); grid on; hold on;
errorbar(1:nCapillaries, expectedPressure, expectedPressureStd, ...
    'k', 'LineStyle','none','LineWidth',1.2,'CapSize',10, ...
    'HandleVisibility','off');
xticks(1:nCapillaries);
xticklabels(capillaryNames);
xtickangle(20);
ylabel('Expected Pressure Drop [bar]');
title('Expected Pressure Drop at Current Capillary Length');
subtitle(sprintf('Mass flow = %.2f g/s', targetMassFlow));
if any(outsideMeasuredRange)
    text(0.02, 0.96, 'WARNING: target flow requires extrapolation', ...
        'Units','normalized','Color','red','FontWeight','bold', ...
        'VerticalAlignment','top','HandleVisibility','off');
end
yLimits = ylim;
for c = 1:nCapillaries
    if isfinite(expectedPressure(c)) && isfinite(expectedPressureStd(c))
        text(c, expectedPressure(c) + 0.02*diff(yLimits), ...
            sprintf('%.2f %c %.2f bar',expectedPressure(c),char(177), ...
            expectedPressureStd(c)), 'HorizontalAlignment','center');
    end
end
text(0.99, 0.02, 'Sara Memushaj', 'Units','normalized', ...
    'HorizontalAlignment','right','VerticalAlignment','bottom', ...
    'FontSize',8,'FontAngle','italic','Color',[0.60 0.60 0.60], ...
    'HandleVisibility','off');
hold off;
