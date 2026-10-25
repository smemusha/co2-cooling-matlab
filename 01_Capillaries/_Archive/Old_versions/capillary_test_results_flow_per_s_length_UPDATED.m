%% CAPILLARY TESTING RESULTS - DP / MF (B180)
% SCADA pressure-drop / mass-flow analysis with timestamp-based assignment.
% For a new campaign, change only the USER INPUTS section below.
clear; clc;

%% ================================================================
%  USER INPUTS - EDIT HERE
% ================================================================

% 1) SOURCE CSV RECORDINGS - one entry per CSV file, not per capillary.
%    Files must be in MATLAB's current folder/path or use full paths.
files = {
    'POB COS Data 2026-10-23  POB-D076-009, POB-D076-010.csv'
    'POB COS1, Data 23-10-2026, P.O.B-D076-011,P.O.B-D076-012.csv'
};

% 2) CAPILLARY IDs - match order of lengths and time ranges.
capillaryIDs = ["P.O.B-D076-009"; "P.O.B-D076-010"; ...
                "P.O.B-D076-011"; "P.O.B-D076-012"];

% 3) LENGTH [mm] - one manually entered value per capillary.
%    Order: 005, 006, 007, 008 (matching capillaryIDs above).
lengthMm = [
    3307;  % P.O.B-D076-009
    3500;  % P.O.B-D076-010
    3027;  % P.O.B-D076-011
    3030;  % P.O.B-D076-012
];

% 4) OUTPUT DIRECTORY AND CSV FILENAMES
outputFolder = 'C:\Users\smemusha\cernbox\WINDOWS\Desktop\ITk\Capilaries\Measurements\Interalloy batch\PRODUCTION\I.D_0.76\No.9-12\Single_flow_point';
summaryFile = 'POB-D076-009_to_012_dp_summary.csv';
stepStatsFile = 'capillary_step_statistics.csv';
fitQualityFile = 'capillary_fit_quality.csv';

% 5) SCADA COLUMN HEADERS
 timeColumn = 'Year/Month/Day Hour:Minute:Second.Millisecond';
 pressureColumn = 'CO2_COS_F:@CS0f_M0_DP1050.PosSt';
 flowColumn = 'CO2_COS_F:@CS0f_M0_FT1030.PosSt';

% 6) STABLE TIMESTAMP BATCHES - one start/end pair per measurement step.
% Each row corresponds to one stable mass-flow step.

% Capillary 13
timeRanges1 = [... 
    datetime('2026/10/23 12:51:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/23 12:56:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    % datetime('2026/10/23 10:28:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/23 10:33:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    % datetime('2026/10/22 18:56:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 19:01:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    % datetime('2026/10/22 16:22:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 16:27:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
];

% Capillary 14
timeRanges2 = [... 
    datetime('2026/10/23 13:07:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/23 13:12:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    % datetime('2026/10/23 10:04:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/23 10:09:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    % datetime('2026/10/22 18:42:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 18:47:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    % datetime('2026/10/22 16:36:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 16:41:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
];

% Capillary 15
timeRanges3 = [... 
    datetime('2026/10/23 14:31:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/23 14:36:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    % datetime('2026/10/23 09:47:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/23 09:52:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    % datetime('2026/10/22 18:28:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 18:33:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    % datetime('2026/10/22 16:48:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 16:53:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
];

% Capillary 16
timeRanges4 = [... 
    datetime('2026/10/23 14:51:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/23 14:56:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    % datetime('2026/10/23 09:30:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/23 09:35:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    % datetime('2026/10/22 17:59:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 18:04:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
    % datetime('2026/10/22 17:01:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/10/22 17:06:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
];

% Pair each group of intervals with its capillary (same order as capillaryIDs).
timeRanges = {timeRanges1, timeRanges2, timeRanges3, timeRanges4};

% 7) PLOT COLORS - same order as capillaryIDs.
colors = {[0 0.4 0], [0 0.2 0.9], [0 0.7 0.7], [0 0.65 0]};

%% ================================================================
%  END USER INPUTS - ANALYSIS BELOW
% ================================================================
nCapillaries = numel(capillaryIDs);
assert(numel(lengthMm) == nCapillaries, ...
    'Provide one length for each capillary.');
assert(numel(timeRanges) == nCapillaries, ...
    'Provide one time-range group for each capillary.');
assert(numel(colors) == nCapillaries, ...
    'Provide one plot color for each capillary.');
if ~isfolder(outputFolder)
    error('CSV export folder does not exist: %s', outputFolder);
end

%% Import all recordings and combine SCADA samples
allTime = datetime.empty(0,1);
allPressure = zeros(0,1);
allFlow = zeros(0,1);

for f = 1:numel(files)
    T = readtable(files{f}, 'VariableNamingRule', 'preserve');
    rawTime = T{:, timeColumn};
    if isdatetime(rawTime)
        t = rawTime;
    else
        t = datetime(string(rawTime), 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    end
    p = T{:, pressureColumn};
    m = T{:, flowColumn};
    if ~isnumeric(p), p = str2double(string(p)); end
    if ~isnumeric(m), m = str2double(string(m)); end
    allTime = [allTime; t(:)];
    allPressure = [allPressure; double(p(:))];
    allFlow = [allFlow; double(m(:))];
end

% Sort the combined dataset chronologically. Repeated identical time stamps
% can occur when CSV exports overlap; retain the first occurrence.
[allTime, order] = sort(allTime);
allPressure = allPressure(order);
allFlow = allFlow(order);
[allTime, keep] = unique(allTime, 'stable');
allPressure = allPressure(keep);
allFlow = allFlow(keep);
fprintf('Imported %d unique SCADA timestamps from %d files.\n', ...
    numel(allTime), numel(files));


%% Analyze each capillary by its stable time windows
nCapillaries = numel(capillaryIDs);
results = cell(nCapillaries,1);
flowMeans = cell(nCapillaries,1);
pressureMeans = cell(nCapillaries,1);
flowStds = cell(nCapillaries,1);
pressureStds = cell(nCapillaries,1);
fitRSquared = NaN(nCapillaries,1);

for c = 1:nCapillaries
    intervals = timeRanges{c};
    nSteps = size(intervals,1);
    meanFlow = NaN(nSteps,1);
    meanPressure = NaN(nSteps,1);
    stdFlow = NaN(nSteps,1);
    stdPressure = NaN(nSteps,1);
    sampleCount = zeros(nSteps,1);

    for k = 1:nSteps
        % Time selection always searches the WHOLE combined dataset.
        selected = allTime >= intervals(k,1) & allTime <= intervals(k,2);
        % Require both sensors to have valid samples.
        selected = selected & isfinite(allFlow) & isfinite(allPressure);
        sampleCount(k) = nnz(selected);
        if sampleCount(k) == 0
            warning('%s, step %d: no valid data in %s to %s.', ...
                capillaryIDs(c), k, string(intervals(k,1)), string(intervals(k,2)));
            continue
        end
        meanFlow(k) = mean(allFlow(selected));
        meanPressure(k) = mean(allPressure(selected));
        stdFlow(k) = std(allFlow(selected),0);
        stdPressure(k) = std(allPressure(selected),0);
    end

    % Keep original step numbers even if an interval has no samples.
    valid = sampleCount > 0;
    cvFlow = 100 * stdFlow ./ meanFlow;
    cvPressure = 100 * stdPressure ./ meanPressure;
    results{c} = table((1:nSteps)', sampleCount, ...
        round(meanFlow,2), round(stdFlow,2), round(cvFlow,2), ...
        round(meanPressure,2), round(stdPressure,2), round(cvPressure,2), ...
        'VariableNames', {'Step','N','Mean_mass_flow_g_s', ...
        'STD_mass_flow_g_s','CV_mass_flow_percent', ...
        'Mean_pressure_drop_bar','STD_pressure_drop_bar', ...
        'CV_pressure_drop_percent'});
    fprintf('\n%s\n', capillaryIDs(c));
    disp(results{c});

    flowMeans{c} = meanFlow(valid);
    pressureMeans{c} = meanPressure(valid);
    flowStds{c} = stdFlow(valid);
    pressureStds{c} = stdPressure(valid);
end

%% Export stable-step statistics for all capillaries
allResults = table();
for c = 1:nCapillaries
    oneResult = addvars(results{c}, ...
        repmat(capillaryIDs(c),height(results{c}),1), ...
        'Before',1,'NewVariableNames','Capillary');
    allResults = [allResults; oneResult];
end
writetable(allResults, fullfile(outputFolder, stepStatsFile));

%% Pressure drop vs mass flow with standard deviation error bars
figure; hold on; grid on;
for c = 1:nCapillaries
    x = flowMeans{c}; y = pressureMeans{c};
    sx = flowStds{c}; sy = pressureStds{c};
    if isempty(x), continue; end
    color = colors{c};
    scatter(x,y,50,'filled', 'MarkerFaceColor',color, ...
        'MarkerEdgeColor',color,'DisplayName',char(capillaryIDs(c)));
    errorbar(x,y,sy,sy,sx,sx,'LineStyle','none', ...
        'Color',color,'CapSize',8,'HandleVisibility','off');
    for k = 1:numel(x)
        label = sprintf('m = %.2f %c %.2f g/s\ndP = %.2f %c %.2f bar', ...
            x(k),char(177),sx(k),y(k),char(177),sy(k));
        text(x(k)+0.025,y(k)+0.2,label,'FontSize',7, ...
            'Color',color,'BackgroundColor','white', ...
            'HandleVisibility','off');
    end

    % Fit through origin: dP = a*m^2+b*m (one point: a*m^2).
    if numel(x) == 1
        if x(1) ~= 0
            a = y(1)/x(1)^2;
            xFit = linspace(0,x(1),100);
            yFit = a*xFit.^2;
        else
            xFit = []; yFit = [];
        end
    else
        A = [x.^2, x];
        coeff = A\y;
        fitted = A*coeff;
        ssTotal = sum((y-mean(y)).^2);
        if ssTotal > 0
            fitRSquared(c) = 1-sum((y-fitted).^2)/ssTotal;
        end
        xFit = linspace(0,max(x),100);
        yFit = coeff(1)*xFit.^2 + coeff(2)*xFit;
    end
    if ~isempty(xFit)
        plot(xFit,yFit,'-','Color',color, ...
            'LineWidth',1.5,'HandleVisibility','off');
    end
end
xlabel('Mass Flow Rate [g/s]');
ylabel('Pressure Drop DP1050 [bar]');
title('SS Capillaries I.D. 0.76 mm - Pressure Drop vs. Mass Flow Rate');
subtitle('SCADA samples selected by time interval');
legend('Location','best');
xlim([0 5]); ylim([0 9]);
hold off;

fitSummary = table(capillaryIDs, fitRSquared, ...
    'VariableNames',{'Capillary','R_squared'});
fprintf('\nQuadratic-fit quality\n');
disp(fitSummary);
writetable(fitSummary, fullfile(outputFolder, fitQualityFile));


%% Export simplified capillary dP test results
% Lengths are defined in USER INPUTS.

summaryCapillary = strings(0,1);
summaryLength = zeros(0,1);
summaryFlow = zeros(0,1);
summaryDP = zeros(0,1);

for c = 1:nCapillaries
    % One row per valid timestamp batch (mass-flow step).
    % Use the calculated means before rounding for accurate CSV values.
    validRows = isfinite(flowMeans{c}) & isfinite(pressureMeans{c});
    n = nnz(validRows);
    summaryCapillary = [summaryCapillary; repmat(capillaryIDs(c),n,1)];
    summaryLength = [summaryLength; repmat(lengthMm(c),n,1)];
    summaryFlow = [summaryFlow; round(flowMeans{c}(validRows),3)];
    summaryDP = [summaryDP; round(pressureMeans{c}(validRows),3)];
end

summaryTable = table(summaryCapillary, summaryLength, summaryFlow, summaryDP, ...
    'VariableNames', {'Capillary No.','Length (mm)', ...
                      'Mass flow (gr/s)','dP (bar)'});
% Write summary in the directory configured above.
outputFile = fullfile(outputFolder, summaryFile);
writetable(summaryTable, outputFile);
fprintf('\nExported %d measurements to:\n%s\n', height(summaryTable), outputFile);
