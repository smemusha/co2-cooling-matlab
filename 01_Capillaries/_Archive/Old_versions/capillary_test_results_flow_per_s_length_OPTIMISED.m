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

% 2) CAPILLARIES - ID, length [mm], stable time windows, plot colour.
%    One row per capillary. Time windows: one [start, end] row per
%    mass-flow step, format 'yyyy/MM/dd HH:mm:ss'.
capillaryIDs = ["P.O.B-D076-009"; "P.O.B-D076-010"; ...
                "P.O.B-D076-011"; "P.O.B-D076-012"];

lengthMm = [3307; 3500; 3027; 3030];

timeRanges = {
    % P.O.B-D076-009
    ["2026/10/23 12:51:00", "2026/10/23 12:56:00"
    %  "2026/10/23 10:28:00", "2026/10/23 10:33:00"
    %  "2026/10/22 18:56:00", "2026/10/22 19:01:00"
    %  "2026/10/22 16:22:00", "2026/10/22 16:27:00"
    ]
    % P.O.B-D076-010
    ["2026/10/23 13:07:00", "2026/10/23 13:12:00"
    %  "2026/10/23 10:04:00", "2026/10/23 10:09:00"
    %  "2026/10/22 18:42:00", "2026/10/22 18:47:00"
    %  "2026/10/22 16:36:00", "2026/10/22 16:41:00"
    ]
    % P.O.B-D076-011
    ["2026/10/23 14:31:00", "2026/10/23 14:36:00"
    %  "2026/10/23 09:47:00", "2026/10/23 09:52:00"
    %  "2026/10/22 18:28:00", "2026/10/22 18:33:00"
    %  "2026/10/22 16:48:00", "2026/10/22 16:53:00"
    ]
    % P.O.B-D076-012
    ["2026/10/23 14:51:00", "2026/10/23 14:56:00"
    %  "2026/10/23 09:30:00", "2026/10/23 09:35:00"
    %  "2026/10/22 17:59:00", "2026/10/22 18:04:00"
    %  "2026/10/22 17:01:00", "2026/10/22 17:06:00"
    ]
};

% Leave empty ([]) to use MATLAB's default distinct colours.
colors = [0 0.4 0; 0 0.2 0.9; 0 0.7 0.7; 0.85 0.33 0.1];

% 3) OUTPUT
outputFolder = 'C:\Users\smemusha\cernbox\WINDOWS\Desktop\ITk\Capilaries\Measurements\Interalloy batch\PRODUCTION\I.D_0.76\No.9-12\Single_flow_point';
summaryFile    = 'POB-D076-009_to_012_dp_summary_v2.csv';
exportStepStats  = false;   % true -> also write capillary_step_statistics.csv
exportFitQuality = false;   % true -> also write capillary_fit_quality.csv

% 4) SCADA COLUMN HEADERS
timeColumn     = 'Year/Month/Day Hour:Minute:Second.Millisecond';
pressureColumn = 'CO2_COS_F:@CS0f_M0_DP1050.PosSt';
flowColumn     = 'CO2_COS_F:@CS0f_M0_FT1030.PosSt';

%% ================================================================
%  END USER INPUTS - ANALYSIS BELOW
% ================================================================
nCap = numel(capillaryIDs);
assert(numel(lengthMm) == nCap, 'Provide one length per capillary.');
assert(numel(timeRanges) == nCap, 'Provide one time-range group per capillary.');
if isempty(colors), colors = lines(nCap); end
assert(size(colors,1) == nCap, 'Provide one plot colour per capillary.');
assert(isfolder(outputFolder), 'Output folder does not exist: %s', outputFolder);

%% Import all recordings (cell-collect, concatenate once)
nFiles = numel(files);
tC = cell(nFiles,1); pC = tC; mC = tC;
for f = 1:nFiles
    T = readtable(files{f}, 'VariableNamingRule', 'preserve');
    tC{f} = toDatetime(T{:, timeColumn});
    pC{f} = toNumeric(T{:, pressureColumn});
    mC{f} = toNumeric(T{:, flowColumn});
end
allTime = vertcat(tC{:});
allPressure = vertcat(pC{:});
allFlow = vertcat(mC{:});

% Sort + drop duplicate timestamps (overlapping exports) + drop NaN samples,
% all once, so per-step selection is a cheap mask on clean data.
[allTime, idx] = unique(allTime);          % sorted, first occurrence kept
allPressure = allPressure(idx);
allFlow = allFlow(idx);
ok = ~isnat(allTime) & isfinite(allPressure) & isfinite(allFlow);
allTime = allTime(ok); allPressure = allPressure(ok); allFlow = allFlow(ok);
fprintf('Imported %d valid unique SCADA samples from %d files.\n', numel(allTime), nFiles);

%% Step statistics per capillary
stats = cell(nCap,1);
fitR2 = NaN(nCap,1);
for c = 1:nCap
    win = datetime(timeRanges{c}, 'InputFormat', 'yyyy/MM/dd HH:mm:ss');
    nSteps = size(win,1);
    S = NaN(nSteps,4);                 % [meanF stdF meanP stdP]
    N = zeros(nSteps,1);
    for k = 1:nSteps
        sel = allTime >= win(k,1) & allTime <= win(k,2);
        N(k) = nnz(sel);
        if N(k) == 0
            warning('%s, step %d: no valid data in %s to %s.', ...
                capillaryIDs(c), k, string(win(k,1)), string(win(k,2)));
            continue
        end
        F = allFlow(sel); P = allPressure(sel);
        S(k,:) = [mean(F) std(F) mean(P) std(P)];
    end
    stats{c} = table((1:nSteps)', N, S(:,1), S(:,2), 100*S(:,2)./S(:,1), ...
        S(:,3), S(:,4), 100*S(:,4)./S(:,3), ...
        'VariableNames', {'Step','N','Mean_mass_flow_g_s','STD_mass_flow_g_s', ...
        'CV_mass_flow_percent','Mean_pressure_drop_bar','STD_pressure_drop_bar', ...
        'CV_pressure_drop_percent'});
    stats{c}(N == 0,:) = [];
    fprintf('\n%s\n', capillaryIDs(c));
    shown = stats{c}; shown{:,:} = round(shown{:,:}, 2);
    disp(shown);
end

%% Plot dP vs mass flow with fits through origin
figure; hold on; grid on;
for c = 1:nCap
    if isempty(stats{c}), continue; end
    x = stats{c}.Mean_mass_flow_g_s;   sx = stats{c}.STD_mass_flow_g_s;
    y = stats{c}.Mean_pressure_drop_bar; sy = stats{c}.STD_pressure_drop_bar;
    col = colors(c,:);

    errorbar(x, y, sy, sy, sx, sx, 'o', 'Color', col, 'MarkerFaceColor', col, ...
        'MarkerSize', 7, 'CapSize', 8, 'DisplayName', char(capillaryIDs(c)));
    pm = char(177);
    labels = compose("m = %.2f " + pm + " %.2f g/s\ndP = %.2f " + pm + " %.2f bar", [x sx y sy]);
    text(x+0.025, y+0.2, labels, 'FontSize', 7, 'Color', col, 'BackgroundColor', 'white');

    % dP = a*m^2 (one point) or dP = a*m^2 + b*m (several points)
    if isscalar(x)
        coeff = [y/x^2; 0];
    else
        A = [x.^2, x];
        coeff = A\y;
        ssTot = sum((y-mean(y)).^2);
        if ssTot > 0, fitR2(c) = 1 - sum((y-A*coeff).^2)/ssTot; end
    end
    if all(isfinite(coeff))
        xFit = linspace(0, max(x), 100);
        plot(xFit, coeff(1)*xFit.^2 + coeff(2)*xFit, '-', 'Color', col, ...
            'LineWidth', 1.5, 'HandleVisibility', 'off');
    end
end
xlabel('Mass Flow Rate [g/s]');
ylabel('Pressure Drop DP1050 [bar]');
title('SS Capillaries I.D. 0.76 mm - Pressure Drop vs. Mass Flow Rate');
subtitle('SCADA samples selected by time interval');
legend('Location','best');
xlim([0 5]); ylim([0 9]);
hold off;

%% Exports
nRows = cellfun(@height, stats);
summaryTable = table(repelem(capillaryIDs, nRows), repelem(lengthMm, nRows), ...
    round(cell2mat(cellfun(@(s) s.Mean_mass_flow_g_s, stats, 'UniformOutput', false)),3), ...
    round(cell2mat(cellfun(@(s) s.Mean_pressure_drop_bar, stats, 'UniformOutput', false)),3), ...
    'VariableNames', {'Capillary No.','Length (mm)','Mass flow (gr/s)','dP (bar)'});
outputFile = fullfile(outputFolder, summaryFile);
writetable(summaryTable, outputFile);
fprintf('\nExported %d measurements to:\n%s\n', height(summaryTable), outputFile);

if exportStepStats
    allStats = vertcat(stats{:});
    allStats = addvars(allStats, repelem(capillaryIDs, nRows), 'Before', 1, ...
        'NewVariableNames', 'Capillary');
    writetable(allStats, fullfile(outputFolder, 'capillary_step_statistics.csv'));
end
if exportFitQuality
    writetable(table(capillaryIDs, fitR2, 'VariableNames', {'Capillary','R_squared'}), ...
        fullfile(outputFolder, 'capillary_fit_quality.csv'));
end

%% Local helpers
function t = toDatetime(raw)
    if isdatetime(raw), t = raw(:); return; end
    t = datetime(string(raw(:)), 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
end

function v = toNumeric(raw)
    if ~isnumeric(raw), raw = str2double(string(raw)); end
    v = double(raw(:));
end
