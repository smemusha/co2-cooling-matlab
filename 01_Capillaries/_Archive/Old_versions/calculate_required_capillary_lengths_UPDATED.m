%% REQUIRED CAPILLARY LENGTHS FROM EXPERIMENTAL DATA
%
% Uses experimental capillary measurements to calculate the length required
% for each capillary to produce the target pressure drop at the target
% mass-flow rate.
%
% Assumption at constant mass flow:
%
%       pressure drop is proportional to capillary length
%
% Therefore:
%
%       L_required = L_test * DP_target / DP_at_target_flow
%
% Flow dependence:
%
% If only ONE non-zero flow point is available:
%
%       DP = a*F^2
%
% using the physical condition DP = 0 at F = 0.
%
% If MULTIPLE flow points are available:
%
%       DP = a*F^2 + b*F
%
% fitted by least squares and constrained through the origin.

clear;
clc;


%% USER INPUTS - EDIT THIS SECTION FOR EACH TEST CAMPAIGN

% Experimental length of each tested capillary [mm]

% ENTER THE ACTUAL TESTED LENGTHS HERE:

testLength = [
    3500;   % P.O.B-D076-013
    3500;   % P.O.B-D076-014
    3500;   % P.O.B-D076-015
    3500;   % P.O.B-D076-016
];

targetPressureDrop = 8.75;  % Required pressure drop [bar]
targetMassFlow = 1.89;      % Required mass-flow rate [g/s]

if any(isnan(testLength))
    error(['Enter the actual tested length of all four capillaries ' ...
        'in testLength at the top of the script.']);
end


%% CSV files and capillary names

% Add each recording only ONCE, even if it contains several capillaries.
fileNames = {
    'COS1, POB DATA_22_10_2026, POB-D076-013,POB-D076-14,POB-D076-15, POB-D076-16.csv'
    'POB COS Data 2026-10-23  POB-D076-013, POB-D076-014,POB-D076-015,POB-D076-016.csv'
    'POB COS1, Data 22-10-2026, 2.3 Flow Scan, P.O.B-D076-013,P.O.B-D076-014,P.O.B-D076-015,P.O.B-D076-016 .csv'
};

capillaryNames = {
    'P.O.B-D076-013'
    'P.O.B-D076-014'
    'P.O.B-D076-015'
    'P.O.B-D076-016'
};


%% Output folder and export filenames
% Directory for the final-length CSV only.
outputFolder = 'C:\Users\smemusha\cernbox\WINDOWS\Desktop\ITk\Capilaries\Measurements\Interalloy batch\PRODUCTION\I.D_0.76\No.13-16';

finalLengthsFile = 'POB-D076-013_to_016_capillary_final_lengths.csv';

%% CSV column names

timeColumn = ...
    'Year/Month/Day Hour:Minute:Second.Millisecond';

pressureColumn = ...
    'CO2_COS_F:@CS0f_M0_DP1050.PosSt';

flowColumn = ...
    'CO2_COS_F:@CS0f_M0_FT1030.PosSt';



%% Stable timestamp ranges - EDIT FOR EACH CAPILLARY

timeRanges = cell(4, 1);

% Capillary 13
timeRanges1 = [... 
    datetime('2026/10/23 08:09:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/23 08:14:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    datetime('2026/10/23 10:28:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/23 10:33:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    datetime('2026/10/22 18:56:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 19:01:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    datetime('2026/10/22 16:22:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 16:27:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
];

% Capillary 14
timeRanges2 = [... 
    datetime('2026/10/23 08:29:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/23 08:34:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/10/23 10:04:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/23 10:09:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    datetime('2026/10/22 18:42:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 18:47:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    datetime('2026/10/22 16:36:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 16:41:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
];

% Capillary 15
timeRanges3 = [... 
    datetime('2026/10/23 08:57:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/23 09:02:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/10/23 09:47:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/23 09:52:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    datetime('2026/10/22 18:28:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 18:33:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    datetime('2026/10/22 16:48:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 16:53:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
];

% Capillary 16
timeRanges4 = [... 
    datetime('2026/10/23 09:19:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/23 09:24:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/10/23 09:30:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/23 09:35:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    datetime('2026/10/22 17:59:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 18:04:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    datetime('2026/10/22 17:01:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 17:06:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
];

% Store all time ranges in the cell array

timeRanges{1} = timeRanges1;
timeRanges{2} = timeRanges2;
timeRanges{3} = timeRanges3;
timeRanges{4} = timeRanges4;


%% End of user inputs / validation
if numel(capillaryNames) ~= numel(testLength) || ...
        numel(capillaryNames) ~= numel(timeRanges)
    error('Capillary IDs, tested lengths and time-range groups must match.');
end
if ~isfolder(outputFolder)
    error('CSV export folder does not exist: %s', outputFolder);
end

%% Read data and calculate results

pressureAtTargetFlow = nan(4, 1);
pressureStdAtTargetFlow = nan(4, 1);

requiredLength = nan(4, 1);
requiredLengthStd = nan(4, 1);

rSquared = nan(4, 1);

allStepResults = table();


fprintf('\nStable-step averages and sample standard deviations\n');
fprintf(['Standard deviations describe the raw SCADA values ' ...
    'inside each stable interval.\n']);


%% Import all CSV recordings into one common dataset
% Files are data sources; no file is associated with a capillary.
% Each capillary is identified only through the stable timestamp intervals.

allTime = datetime.empty(0,1);
allPressure = zeros(0,1);
allFlow = zeros(0,1);

for fileIndex = 1:numel(fileNames)
    raw = readtable(fileNames{fileIndex}, 'VariableNamingRule', 'preserve');
    rawTime = raw{:, timeColumn};
    if isdatetime(rawTime)
        importedTime = rawTime;
    else
        importedTime = datetime(string(rawTime), ...
            'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    end

    allTime = [allTime; importedTime(:)];
    allPressure = [allPressure; raw{:, pressureColumn}];
    allFlow = [allFlow; raw{:, flowColumn}];
end

% Sort recordings chronologically. Identical readings from repeated imports
% are removed, while conflicting values at the same timestamp are retained.
[allTime, order] = sort(allTime);
allPressure = allPressure(order);
allFlow = allFlow(order);
[~, uniqueIndex] = unique(table(allTime, allPressure, allFlow), 'rows', 'stable');
allTime = allTime(uniqueIndex);
allPressure = allPressure(uniqueIndex);
allFlow = allFlow(uniqueIndex);

%% Process each capillary using timestamps from the common dataset

for capillaryIndex = 1:numel(capillaryNames)

    timeData = allTime;
    pressureData = allPressure;
    flowData = allFlow;

    %% Number of stable flow steps

    numberOfSteps = ...
        size(timeRanges{capillaryIndex}, 1);


    %% Preallocate

    meanPressure = nan(numberOfSteps, 1);
    meanFlow = nan(numberOfSteps, 1);

    stdPressure = nan(numberOfSteps, 1);
    stdFlow = nan(numberOfSteps, 1);

    sampleCount = nan(numberOfSteps, 1);


    %% Calculate mean and standard deviation for each stable interval

    for stepIndex = 1:numberOfSteps

        startTime = ...
            timeRanges{capillaryIndex}(stepIndex, 1);

        endTime = ...
            timeRanges{capillaryIndex}(stepIndex, 2);


        timeMask = ...
            timeData >= startTime & ...
            timeData <= endTime;


        meanPressure(stepIndex) = ...
            mean(pressureData(timeMask), 'omitnan');


        meanFlow(stepIndex) = ...
            mean(flowData(timeMask), 'omitnan');


        stdPressure(stepIndex) = ...
            std(pressureData(timeMask), 0, 'omitnan');


        stdFlow(stepIndex) = ...
            std(flowData(timeMask), 0, 'omitnan');


        sampleCount(stepIndex) = ...
            sum( ...
            timeMask & ...
            ~isnan(pressureData) & ...
            ~isnan(flowData));

    end


    %% Remove invalid / empty intervals

    valid = ...
        ~isnan(meanFlow) & ...
        ~isnan(meanPressure);


    meanFlow = meanFlow(valid);

    meanPressure = meanPressure(valid);

    stdFlow = stdFlow(valid);

    stdPressure = stdPressure(valid);

    sampleCount = sampleCount(valid);


    %% Check that some data exist

    if isempty(meanFlow)

        warning( ...
            'No valid experimental data found for %s.', ...
            capillaryNames{capillaryIndex});

        continue;

    end


    %% Sort experimental points by increasing flow

    [meanFlow, sortIndex] = sort(meanFlow);

    meanPressure = meanPressure(sortIndex);

    stdFlow = stdFlow(sortIndex);

    stdPressure = stdPressure(sortIndex);

    sampleCount = sampleCount(sortIndex);


    %% Calculate CV values

    stepNumber = (1:numel(meanFlow))';

    cvFlow = ...
        100 * stdFlow ./ meanFlow;

    cvPressure = ...
        100 * stdPressure ./ meanPressure;


    %% Build stable-step results table

    stepResults = table( ...
        stepNumber, ...
        sampleCount, ...
        meanFlow, ...
        stdFlow, ...
        cvFlow, ...
        meanPressure, ...
        stdPressure, ...
        cvPressure, ...
        'VariableNames', { ...
        'Step', ...
        'N', ...
        'Mean_mass_flow_g_s', ...
        'STD_mass_flow_g_s', ...
        'CV_mass_flow_percent', ...
        'Mean_pressure_drop_bar', ...
        'STD_pressure_drop_bar', ...
        'CV_pressure_drop_percent'});


    fprintf( ...
        '\nCapillary %s\n', ...
        capillaryNames{capillaryIndex});

    fprintf( ...
        'Tested length: %.0f mm\n', ...
        testLength(capillaryIndex));

    disp(stepResults);


    %% Add capillary name and tested length

    stepResults = addvars( ...
        stepResults, ...
        repmat( ...
        string(capillaryNames{capillaryIndex}), ...
        height(stepResults), 1), ...
        repmat( ...
        testLength(capillaryIndex), ...
        height(stepResults), 1), ...
        'Before', 1, ...
        'NewVariableNames', { ...
        'Capillary', ...
        'Test_length_mm'});


    %% Combine results from all capillaries

    if isempty(allStepResults)

        allStepResults = stepResults;

    else

        allStepResults = ...
            [allStepResults; stepResults];

    end


    %% ============================================================
    %  CALCULATE DP AT TARGET MASS FLOW
    % ============================================================


    if numel(meanFlow) == 1

        %% SINGLE NON-ZERO EXPERIMENTAL FLOW POINT
        %
        % Known physical point:
        %
        %       F = 0  ->  DP = 0
        %
        % With only one measured non-zero flow point, use:
        %
        %       DP = a*F^2
        %
        % where:
        %
        %       a = DP_measured / F_measured^2


        measuredFlow = meanFlow(1);

        measuredPressure = meanPressure(1);


        a = ...
            measuredPressure / measuredFlow^2;


        %% Calculate pressure at target flow

        pressureAtTargetFlow(capillaryIndex) = ...
            a * targetMassFlow^2;


        %% Scale pressure standard deviation
        %
        % Use the same F^2 scaling as the pressure calculation.

        pressureStdAtTargetFlow(capillaryIndex) = ...
            stdPressure(1) * ...
            (targetMassFlow / measuredFlow)^2;


        %% R^2 is not meaningful with one measured non-zero point

        rSquared(capillaryIndex) = NaN;


        fprintf( ...
            ['Single experimental flow point detected.\n' ...
            'Using DP = a*F^2 and physical point DP(0) = 0.\n']);


        fprintf( ...
            'Measured:   F = %.3f g/s, DP = %.3f bar\n', ...
            measuredFlow, ...
            measuredPressure);


        fprintf( ...
            'Calculated: F = %.3f g/s, DP = %.3f bar\n', ...
            targetMassFlow, ...
            pressureAtTargetFlow(capillaryIndex));


        %% Extrapolation warning only if target is ABOVE measured flow
        %
        % If target is between 0 and the measured flow, it lies between
        % the known physical origin and the measured experimental point.

        if targetMassFlow > measuredFlow

            warning( ...
                ['For %s, target flow %.2f g/s is above the ' ...
                'measured flow %.3f g/s. Result uses extrapolation.'], ...
                capillaryNames{capillaryIndex}, ...
                targetMassFlow, ...
                measuredFlow);

        end


    else

        %% MULTIPLE EXPERIMENTAL FLOW POINTS
        %
        % Use constrained quadratic least-squares model:
        %
        %       DP = a*F^2 + b*F
        %
        % This automatically satisfies:
        %
        %       DP = 0 at F = 0


        %% Check target against experimental flow range

        if ...
                targetMassFlow < min(meanFlow) || ...
                targetMassFlow > max(meanFlow)

            warning( ...
                ['For %s, %.2f g/s is outside the measured range ' ...
                '[%.3f, %.3f] g/s. The result uses extrapolation.'], ...
                capillaryNames{capillaryIndex}, ...
                targetMassFlow, ...
                min(meanFlow), ...
                max(meanFlow));

        end


        %% Quadratic fit constrained through origin

        fitMatrix = ...
            [meanFlow.^2, meanFlow];


        coefficients = ...
            fitMatrix \ meanPressure;


        a = coefficients(1);

        b = coefficients(2);


        %% Calculate fitted pressure at measured points

        fittedPressure = ...
            fitMatrix * coefficients;


        %% R squared

        rSquared(capillaryIndex) = ...
            1 - ...
            sum( ...
            (meanPressure - fittedPressure).^2) / ...
            sum( ...
            (meanPressure - mean(meanPressure)).^2);


        %% Evaluate fitted curve at target mass flow

        pressureAtTargetFlow(capillaryIndex) = ...
            a * targetMassFlow^2 + ...
            b * targetMassFlow;


        %% Interpolate measured pressure scatter to target flow

        pressureStdAtTargetFlow(capillaryIndex) = ...
            interp1( ...
            meanFlow, ...
            stdPressure, ...
            targetMassFlow, ...
            'linear', ...
            'extrap');

    end


    %% ============================================================
    %  CALCULATE REQUIRED LENGTH
    % ============================================================
    %
    % At constant mass flow:
    %
    %       DP proportional to L
    %
    % Therefore:
    %
    %       L_required =
    %       L_test * DP_required / DP_at_target_flow


    requiredLength(capillaryIndex) = ...
        testLength(capillaryIndex) * ...
        targetPressureDrop / ...
        pressureAtTargetFlow(capillaryIndex);


    %% Propagate pressure uncertainty into required length
    %
    % For:
    %
    %       L = constant / DP
    %
    % relative uncertainty is:
    %
    %       sigma_L / L = sigma_DP / DP


    requiredLengthStd(capillaryIndex) = ...
        requiredLength(capillaryIndex) * ...
        pressureStdAtTargetFlow(capillaryIndex) / ...
        pressureAtTargetFlow(capillaryIndex);


    %% Display calculation

    fprintf( ...
        'DP at target flow %.2f g/s: %.3f +/- %.3f bar\n', ...
        targetMassFlow, ...
        pressureAtTargetFlow(capillaryIndex), ...
        pressureStdAtTargetFlow(capillaryIndex));


    fprintf( ...
        'Required length for %.2f bar: %.0f +/- %.0f mm\n', ...
        targetPressureDrop, ...
        requiredLength(capillaryIndex), ...
        requiredLengthStd(capillaryIndex));

end


if isempty(allStepResults) || ~ismember('Capillary', allStepResults.Properties.VariableNames)
    error('No valid capillary steps were found. Check CSV files and timestamp ranges.');
end

%% ================================================================
%  DISPLAY FINAL RESULTS
% ================================================================

requiredDP = ...
    repmat(targetPressureDrop, 4, 1);


results = table( ...
    string(capillaryNames), ...
    testLength, ...
    rSquared, ...
    pressureAtTargetFlow, ...
    pressureStdAtTargetFlow, ...
    requiredDP, ...
    requiredLength, ...
    requiredLengthStd, ...
    'VariableNames', { ...
    'Capillary', ...
    'Test_length_mm', ...
    'R_squared', ...
    'DP_at_target_flow_bar', ...
    'DP_std_bar', ...
    'DP_required_bar', ...
    'Required_length_mm', ...
    'Required_length_std_mm'});


%% Round final length results

results.Required_length_mm = ...
    round(results.Required_length_mm);

results.Required_length_std_mm = ...
    round(results.Required_length_std_mm);


%% Display target information

fprintf( ...
    '\n====================================================\n');

fprintf( ...
    'Target: DP = %.2f bar at mass flow = %.2f g/s\n', ...
    targetPressureDrop, ...
    targetMassFlow);

fprintf( ...
    '====================================================\n\n');


disp(results);


%% Export calculated final capillary lengths to the same folder
% One row per capillary. Values are those calculated at the target
% pressure drop and target mass flow, with lengths rounded to 1 mm.
% Format the length and its standard deviation together in one column.
% Example: 3120 +/- 45 (mm). Use char(177) for the plus-minus symbol.
finalLengthWithStd = compose('%.0f %c %.0f', ...
    results.Required_length_mm, char(177), results.Required_length_std_mm);

finalLengthSummary = table( ...
    string(capillaryNames(:)), ...
    finalLengthWithStd, ...
    'VariableNames', {'Capillary_No', 'Final_length_mm'});

finalLengthFile = fullfile(outputFolder, finalLengthsFile);
writetable(finalLengthSummary, finalLengthFile);
fprintf('Final lengths exported to: %s\n', finalLengthFile);



%% ================================================================
%  PLOT CALCULATED REQUIRED LENGTHS
% ================================================================

figure;

bar(requiredLength);

grid on;

hold on;


%% Error bars

errorbar( ...
    1:4, ...
    requiredLength, ...
    requiredLengthStd, ...
    'k', ...
    'LineStyle', 'none', ...
    'LineWidth', 1.2, ...
    'CapSize', 10, ...
    'HandleVisibility', 'off');


%% Axis labels

xticks(1:4);

xticklabels(capillaryNames);

xtickangle(20);

ylabel( ...
    'Required Capillary Length [mm]');


title( ...
    'Required Length for Each Capillary');


subtitle( ...
    sprintf( ...
    'Target: DP = %.2f bar at %.2f g/s', ...
    targetPressureDrop, ...
    targetMassFlow));


%% Add value labels above bars

yLimits = ylim;


for capillaryIndex = 1:4

    text( ...
        capillaryIndex, ...
        requiredLength(capillaryIndex) + ...
        0.02 * diff(yLimits), ...
        sprintf( ...
        '%.0f %c %.0f mm', ...
        requiredLength(capillaryIndex), ...
        char(177), ...
        requiredLengthStd(capillaryIndex)), ...
        'HorizontalAlignment', 'center');

end


%% Small watermark

text( ...
    0.99, ...
    0.02, ...
    'Sara Memushaj', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 8, ...
    'FontAngle', 'italic', ...
    'Color', [0.60 0.60 0.60], ...
    'HandleVisibility', 'off');


hold off;