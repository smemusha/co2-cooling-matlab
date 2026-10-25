%% Capillary test results - dP vs mass flow (B180)

% Reads SCADA recordings of the COS setup (DP1050 pressure drop [bar],
% FT1030 mass flow [g/s]) and the stable time windows of each flow step,
% taken from the "Timestamps" Excel files (or from the manual
% backup list). For every capillary and step it computes mean, STD and CV of
% mass flow and dP, fits dP = a*m^2 + b*m through the origin (dP = a*m^2 for
% a single point) and plots dP vs mass flow with error bars.

% Inputs : one campaign folder holding the SCADA csv files, the "Timestamps"
%          xlsx files and lengths.xlsx (Capillary | Test length | Current length);
%          capillary IDs are read from the timestamp files.
% Outputs: dP vs mass flow figure, compact summary in the Command Window and
%          a formatted Excel report (one row per step, value +/- STD).

clear; clc;

% ================================================================
%  INPUTS
% ================================================================

% Campaign folder: SCADA csv files, "Timestamps" xlsx files and lengths.xlsx
campaignFolder = 'C:\Users\smemusha\cernbox\WINDOWS\Desktop\ITk\Capilaries\Measurements\Interalloy batch\PRODUCTION\I.D_0.76\No.9-12\Single_flow_point';
lengthsFile    = fullfile(campaignFolder, 'lengths.xlsx');   % Capillary | Test length (mm) | Current length (mm)
reportFile     = '';   % '' = automatic name, saved in the campaign folder

% BACKUP - manual windows, one row per flow step.
% timeRanges = {
%     % P.O.B-D076-009
%     ["2026/10/23 12:51:00", "2026/10/23 12:56:00"
%     %  "2026/10/23 10:28:00", "2026/10/23 10:33:00"
%     %  "2026/10/22 18:56:00", "2026/10/22 19:01:00"
%     %  "2026/10/22 16:22:00", "2026/10/22 16:27:00"
%     ]
%     % P.O.B-D076-010
%     ["2026/10/23 13:07:00", "2026/10/23 13:12:00"
%     %  "2026/10/23 10:04:00", "2026/10/23 10:09:00"
%     %  "2026/10/22 18:42:00", "2026/10/22 18:47:00"
%     %  "2026/10/22 16:36:00", "2026/10/22 16:41:00"
%     ]
%     % P.O.B-D076-011
%     ["2026/10/23 14:31:00", "2026/10/23 14:36:00"
%     %  "2026/10/23 09:47:00", "2026/10/23 09:52:00"
%     %  "2026/10/22 18:28:00", "2026/10/22 18:33:00"
%     %  "2026/10/22 16:48:00", "2026/10/22 16:53:00"
%     ]
%     % P.O.B-D076-012
%     ["2026/10/23 14:51:00", "2026/10/23 14:56:00"
%     %  "2026/10/23 09:30:00", "2026/10/23 09:35:00"
%     %  "2026/10/22 17:59:00", "2026/10/22 18:04:00"
%     %  "2026/10/22 17:01:00", "2026/10/22 17:06:00"
%     ]
% };
% capillaryIDs = ["P.O.B-D076-009"; "P.O.B-D076-010"; "P.O.B-D076-011"; "P.O.B-D076-012"];   % only with the manual windows

colors       = [0 0.4 0; 0 0.2 0.9; 0 0.7 0.7; 0.85 0.33 0.1];

% SCADA columns
timeColumn     = 'Year/Month/Day Hour:Minute:Second.Millisecond';
pressureColumn = 'CO2_COS_F:@CS0f_M0_DP1050.PosSt';
flowColumn     = 'CO2_COS_F:@CS0f_M0_FT1030.PosSt';

%% ---------------- ANALYSIS ----------------
pm = char(177);   % ±
fmtDay = 'dd.MM.yyyy'; fmtMin = 'HH:mm';

%% Read SCADA data
if isempty(which('cap_read_timestamps'))   % shared functions in 06_Utilities\capillary_lib
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', '06_Utilities', 'capillary_lib'));
end
[files, timestampFiles] = cap_find_files(campaignFolder, timeColumn);
nFiles = numel(files);
[allTime, allPressure, allFlow] = cap_read_scada(files, timeColumn, pressureColumn, flowColumn, 'time');

fprintf('==== Capillary dP test results ====\n');
fprintf('SCADA: %d samples from %d files (%s - %s)\n', numel(allTime), nFiles, ...
    char(min(allTime), [fmtDay ' ' fmtMin]), char(max(allTime), [fmtDay ' ' fmtMin]));

%% Stable time windows
if exist('timeRanges', 'var')
    fprintf('\nStable windows: manual timeRanges (backup)\n');
    assert(exist('capillaryIDs', 'var') == 1, 'With the manual windows, also uncomment capillaryIDs');
else
    if ~exist('capillaryIDs', 'var'), capillaryIDs = strings(0,1); end
    [timeRanges, found, capillaryIDs] = cap_read_timestamps(timestampFiles, capillaryIDs, allTime);
    cap_print_windows(found);
end
[testLength, currentLength] = cap_read_lengths(lengthsFile, capillaryIDs);
lengthMm = testLength;
nCap = numel(capillaryIDs);
if isempty(colors) || size(colors,1) ~= nCap, colors = lines(nCap); end
assert(numel(timeRanges) == nCap, 'timeRanges: one group per capillary');
fprintf('\nCapillaries and lengths\n  %-16s %6s\n', 'Capillary', 'L [mm]');
fprintf('  %-16s %6s\n', [capillaryIDs, string(lengthMm(:))].');

%% Mean / STD per step
stats = cell(nCap,1);
for c = 1:nCap
    win = datetime(timeRanges{c}, 'InputFormat', 'yyyy/MM/dd HH:mm:ss');
    nSteps = size(win,1);
    S = NaN(nSteps,4);   % meanF stdF meanP stdP
    N = zeros(nSteps,1);
    for k = 1:nSteps
        sel = allTime >= win(k,1) & allTime <= win(k,2);
        N(k) = nnz(sel);
        if N(k) == 0
            warning('%s step %d: no SCADA data between %s and %s', capillaryIDs(c), k, ...
                char(win(k,1), [fmtDay ' ' fmtMin]), char(win(k,2), fmtMin));
            continue
        end
        F = allFlow(sel); P = allPressure(sel);
        S(k,:) = [mean(F) std(F) mean(P) std(P)];
    end
    stats{c} = table((1:nSteps)', N, S(:,1), S(:,2), S(:,3), S(:,4), ...
        'VariableNames', {'Step','N','mF','sF','dP','sP'});
    stats{c}(N == 0,:) = [];
end

%% Plot + fit through origin
% 1 point: dP = a*m^2, more points: dP = a*m^2 + b*m
fitA = NaN(nCap,1); fitB = NaN(nCap,1); fitR2 = NaN(nCap,1);

figure; hold on; grid on;
for c = 1:nCap
    if isempty(stats{c}), continue; end
    x = stats{c}.mF; sx = stats{c}.sF;
    y = stats{c}.dP; sy = stats{c}.sP;
    col = colors(c,:);

    errorbar(x, y, sy, sy, sx, sx, 'o', 'Color', col, 'MarkerFaceColor', col, ...
        'MarkerSize', 7, 'CapSize', 8, 'DisplayName', char(capillaryIDs(c)));
    labels = compose("m = %.2f " + pm + " %.2f g/s\ndP = %.2f " + pm + " %.2f bar", [x sx y sy]);
    text(x+0.025, y+0.2, labels, 'FontSize', 7, 'Color', col, 'BackgroundColor', 'white');

    if isscalar(x)
        coeff = [y/x^2; 0];
    else
        A = [x.^2, x];
        coeff = A\y;
        ssTot = sum((y-mean(y)).^2);
        if ssTot > 0, fitR2(c) = 1 - sum((y-A*coeff).^2)/ssTot; end
    end
    if all(isfinite(coeff))
        fitA(c) = coeff(1); fitB(c) = coeff(2);
        xFit = linspace(0, max(x), 100);
        plot(xFit, coeff(1)*xFit.^2 + coeff(2)*xFit, '-', 'Color', col, ...
            'LineWidth', 1.5, 'HandleVisibility', 'off');
    end
end
xlabel('Mass Flow Rate [g/s]');
ylabel('Pressure Drop DP1050 [bar]');
title('SS Capillaries I.D. 0.76 mm - Pressure Drop vs. Mass Flow Rate');
legend('Location','best');
xlim([0 5]); ylim([0 9]);
hold off;

% watermark
wm = text(0.98, 0.03, 'Sara Memushaj', 'Units', 'normalized', 'FontSize', 10, ...
    'FontAngle', 'italic', 'Color', [0.6 0.6 0.6], ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
    'HandleVisibility', 'off', 'HitTest', 'off');
uistack(wm, 'bottom');

%% Results
nRows = cellfun(@height, stats);
R = vertcat(stats{:});
rep = @(v) repelem(v, nRows);
capR = rep(capillaryIDs); lenR = rep(lengthMm);
mStr  = compose("%.2f " + pm + " %.2f", [R.mF R.sF]);
dpStr = compose("%.2f " + pm + " %.2f", [R.dP R.sP]);
cvF = 100*R.sF./R.mF; cvP = 100*R.sP./R.dP;

fprintf('\nResults (mean %s STD)\n', pm);
fprintf('  %-16s %6s %4s %5s  %-13s %7s  %-13s %7s\n', 'Capillary', 'L [mm]', 'Step', 'N', ...
    'm [g/s]', 'CV m [%]', 'dP [bar]', 'CV dP [%]');
for i = 1:height(R)
    fprintf('  %-16s %6g %4d %5d  %-13s %7.2f  %-13s %7.2f\n', capR(i), lenR(i), R.Step(i), ...
        R.N(i), mStr(i), cvF(i), dpStr(i), cvP(i));
end

fprintf('\nFit through origin: dP = a%cm%c + b%cm\n', char(183), char(178), char(183));
fprintf('  %-16s %15s %13s %6s\n', 'Capillary', ['a [bar' char(183) 's' char(178) '/g' char(178) ']'], ...
    ['b [bar' char(183) 's/g]'], ['R' char(178)]);
for c = 1:nCap
    r2 = "-"; if isfinite(fitR2(c)), r2 = sprintf('%.2f', fitR2(c)); end
    fprintf('  %-16s %15.2f %13.2f %6s\n', capillaryIDs(c), fitA(c), fitB(c), r2);
end

%% Excel report (one file, value ± STD in the same cell)
report = table(capR, lenR, R.Step, R.N, mStr, round(cvF, 2), dpStr, round(cvP, 2), ...
    round(rep(fitA), 2), round(rep(fitB), 2), round(rep(fitR2), 2), ...
    'VariableNames', {'Capillary No.','Length (mm)','Step','Samples', ...
    'Mass flow (g/s)','CV mass flow (%)','dP (bar)','CV dP (%)', ...
    'Fit a (bar.s2/g2)','Fit b (bar.s/g)','Fit R2'});

if isempty(reportFile), reportFile = cap_report_name(capillaryIDs, 'report'); end
outputFile = fullfile(campaignFolder, reportFile);
if isfile(outputFile), delete(outputFile); end   % start clean, no old formatting
writetable(report, outputFile, 'Sheet', 'Report');
cap_format_report(outputFile, height(report), width(report), nRows, 7, [6 8 9 10 11]);   % 7 = dP column
fprintf('\nReport saved: %s\n', outputFile);
