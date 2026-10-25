%% Expected pressure drop from capillary length (B180)

% Reads SCADA recordings of the COS test stand (DP1050 pressure drop [bar],
% FT1030 mass flow [g/s]) and the stable time windows of each flow step,
% taken from the "Timestamps" Excel files (or from the manual backup list).
% For every capillary it computes mean, STD and CV per step, fits
% dP = a*m^2 + b*m through the origin (at least 2 steps needed), evaluates
% dP at the target mass flow and scales it to the current length:
% dP_expected = dP_test * L_current / L_test.

% Inputs : one campaign folder holding the SCADA csv files, the "Timestamps"
%          xlsx files and lengths.xlsx (Capillary | Test length | Current length);
%          capillary IDs are read from the timestamp files.
% Outputs: expected-dP bar chart, compact summary in the Command Window and
%          a formatted Excel report (value +/- STD in the same cell).
clear; clc;

% ================================================================
%  INPUTS
% ================================================================

% Campaign folder: SCADA csv files, "Timestamps" xlsx files and lengths.xlsx
campaignFolder = 'C:\Users\smemusha\cernbox\WINDOWS\Desktop\ITk\Capilaries\Measurements\Interalloy batch\PRODUCTION\I.D_0.76\No.9-12';
lengthsFile    = fullfile(campaignFolder, 'lengths.xlsx');   % Capillary | Test length (mm) | Current length (mm)
reportFile     = '';   % '' = automatic name, saved in the campaign folder

% BACKUP - manual windows, one row per flow step.
% timeRanges = {
%     % P.O.B-D076-009
%     ["2026/10/21 19:04:00", "2026/10/21 19:09:00"
%      "2026/10/21 17:22:00", "2026/10/21 17:27:00"
%      "2026/10/22 08:00:00", "2026/10/22 08:05:00"
%      "2026/10/22 09:24:00", "2026/10/22 09:29:00"]
%     % P.O.B-D076-010
%     ["2026/10/21 18:46:00", "2026/10/21 18:51:00"
%      "2026/10/21 17:38:00", "2026/10/21 17:43:00"
%      "2026/10/22 08:17:00", "2026/10/22 08:22:00"
%      "2026/10/22 09:38:00", "2026/10/22 09:43:00"]
%     % P.O.B-D076-011
%     ["2026/10/21 18:29:00", "2026/10/21 18:34:00"
%      "2026/10/21 17:52:00", "2026/10/21 17:57:00"
%      "2026/10/22 08:35:00", "2026/10/22 08:40:00"
%      "2026/10/22 09:56:00", "2026/10/22 10:01:00"]
%     % P.O.B-D076-012
%     ["2026/10/21 18:17:00", "2026/10/21 18:22:00"
%      "2026/10/21 18:05:00", "2026/10/21 18:10:00"
%      "2026/10/22 08:51:00", "2026/10/22 08:56:00"
%      "2026/10/22 10:13:00", "2026/10/22 10:18:00"]
% };
% capillaryIDs = ["P.O.B-D076-009"; "P.O.B-D076-010"; "P.O.B-D076-011"; "P.O.B-D076-012"];   % only with the manual windows


% Target
targetMassFlow = 1.89;   % [g/s]

% SCADA columns
timeColumn     = 'Year/Month/Day Hour:Minute:Second.Millisecond';
pressureColumn = 'CO2_COS_F:@CS0f_M0_DP1050.PosSt';
flowColumn     = 'CO2_COS_F:@CS0f_M0_FT1030.PosSt';

%% ---------------- ANALYSIS ----------------
assert(isscalar(targetMassFlow) && isfinite(targetMassFlow) && targetMassFlow > 0, ...
    'Enter a positive target mass flow');
pm = char(177);   % ±
fmtDay = 'dd.MM.yyyy'; fmtMin = 'HH:mm';

%% Read SCADA data
if isempty(which('cap_read_timestamps'))   % shared functions in 06_Utilities\capillary_lib
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', '06_Utilities', 'capillary_lib'));
end
[files, timestampFiles] = cap_find_files(campaignFolder, timeColumn);
nFiles = numel(files);
[allTime, allPressure, allFlow] = cap_read_scada(files, timeColumn, pressureColumn, flowColumn, 'rows');

fprintf('==== Expected dP from capillary length ====\n');
fprintf('Target mass flow: %.2f g/s\n', targetMassFlow);
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
nCap = numel(capillaryIDs);
bad = ~(isfinite(currentLength) & currentLength > 0);
assert(~any(bad), '%s: no current length for %s', lengthsFile, strjoin(capillaryIDs(bad), ', '));
assert(numel(timeRanges) == nCap, 'timeRanges: one group per capillary');
fprintf('\nCapillaries and lengths\n  %-16s %6s %6s\n', 'Capillary', 'L test', 'L now');
fprintf('  %-16s %6s %6s\n', [capillaryIDs, string(testLength), string(currentLength)].');

%% Mean / STD per step, fit and expected dP
stats = cell(nCap,1);
fitA = NaN(nCap,1); fitB = NaN(nCap,1); rSquared = NaN(nCap,1);
dpTarget = NaN(nCap,1); dpTargetStd = NaN(nCap,1);
expectedPressure = NaN(nCap,1); expectedPressureStd = NaN(nCap,1);
outsideMeasuredRange = false(nCap,1);
ok = isfinite(allPressure) & isfinite(allFlow);

for c = 1:nCap
    win = datetime(timeRanges{c}, 'InputFormat', 'yyyy/MM/dd HH:mm:ss');
    nSteps = size(win,1);
    S = NaN(nSteps,4);   % meanF stdF meanP stdP
    N = zeros(nSteps,1);
    for k = 1:nSteps
        sel = allTime >= win(k,1) & allTime <= win(k,2) & ok;
        N(k) = nnz(sel);
        if N(k) == 0
            warning('%s step %d: no SCADA data between %s and %s', capillaryIDs(c), k, ...
                char(win(k,1), [fmtDay ' ' fmtMin]), char(win(k,2), fmtMin));
            continue
        end
        F = allFlow(sel); P = allPressure(sel);
        S(k,:) = [mean(F) std(F) mean(P) std(P)];
    end
    step = find(N > 0);                        % original step numbers kept
    S = S(step,:); N = N(step);
    [~, o] = sort(S(:,1));                      % by increasing flow
    S = S(o,:); N = N(o); step = step(o);
    stats{c} = table(step(:), N, S(:,1), S(:,2), S(:,3), S(:,4), ...
        'VariableNames', {'Step','N','mF','sF','dP','sP'});
    x = S(:,1); y = S(:,3); sy = S(:,4);

    if numel(x) < 2
        warning('%s has fewer than two valid flow steps; dP prediction left NaN', capillaryIDs(c));
        continue
    end
    outsideMeasuredRange(c) = targetMassFlow < min(x) || targetMassFlow > max(x);
    if outsideMeasuredRange(c)
        warning('%s: target %.2f g/s outside measured range [%.3f, %.3f] g/s (extrapolation)', ...
            capillaryIDs(c), targetMassFlow, min(x), max(x));
    end

    % dP = a*m^2 + b*m through the origin
    A = [x.^2, x];
    coeff = A\y;
    fitA(c) = coeff(1); fitB(c) = coeff(2);
    ssTot = sum((y - mean(y)).^2);
    if ssTot > 0, rSquared(c) = 1 - sum((y - A*coeff).^2)/ssTot; end
    dpTarget(c) = [targetMassFlow^2, targetMassFlow]*coeff;

    % STD interpolated in flow; repeated flows averaged first
    [uF, ~, g] = unique(x);
    uS = accumarray(g, sy, [], @mean);
    if numel(uF) >= 2
        dpTargetStd(c) = interp1(uF, uS, targetMassFlow, 'linear', 'extrap');
    else
        dpTargetStd(c) = uS(1);
    end

    % dP proportional to L at constant flow
    scale = currentLength(c)/testLength(c);
    expectedPressure(c) = dpTarget(c)*scale;
    expectedPressureStd(c) = dpTargetStd(c)*scale;
end

nRows = cellfun(@height, stats);
assert(any(nRows > 0), 'No stable windows matched the SCADA data. Check csv dates and windows.');

%% Command Window summary
R = vertcat(stats{:});
rep = @(v) repelem(v, nRows);
capR = rep(capillaryIDs); lenR = rep(testLength); curR = rep(currentLength);
mStr  = compose("%.2f " + pm + " %.2f", [R.mF R.sF]);
dpStr = compose("%.2f " + pm + " %.2f", [R.dP R.sP]);
cvF = 100*R.sF./R.mF; cvP = 100*R.sP./R.dP;

fprintf('\nStable steps (mean %s STD, sorted by flow)\n', pm);
fprintf('  %-16s %6s %4s %5s  %-13s %7s  %-13s %7s\n', 'Capillary', 'L [mm]', 'Step', 'N', ...
    'm [g/s]', 'CV m [%]', 'dP [bar]', 'CV dP [%]');
for i = 1:height(R)
    fprintf('  %-16s %6g %4d %5d  %-13s %7.2f  %-13s %7.2f\n', capR(i), lenR(i), R.Step(i), ...
        R.N(i), mStr(i), cvF(i), dpStr(i), cvP(i));
end

dpTStr  = compose("%.2f " + pm + " %.2f", [dpTarget dpTargetStd]);
expStr  = compose("%.2f " + pm + " %.2f", [expectedPressure expectedPressureStd]);

fprintf('\nExpected dP at %.2f g/s   (fit: dP = a%cm%c + b%cm)\n', ...
    targetMassFlow, char(183), char(178), char(183));
fprintf('  %-16s %6s %6s %15s %13s %6s  %-14s %-14s\n', 'Capillary', 'L test', 'L now', ...
    ['a [bar' char(183) 's' char(178) '/g' char(178) ']'], ['b [bar' char(183) 's/g]'], ...
    ['R' char(178)], 'dP test [bar]', 'dP exp [bar]');
for c = 1:nCap
    r2 = "-"; if isfinite(rSquared(c)), r2 = sprintf('%.2f', rSquared(c)); end
    fprintf('  %-16s %6g %6g %15.2f %13.2f %6s  %-14s %-14s\n', capillaryIDs(c), testLength(c), ...
        currentLength(c), fitA(c), fitB(c), r2, dpTStr(c), expStr(c));
end
fprintf('  (L in mm)\n');

%% Excel report (one file, value ± STD in the same cell)
% expected dP only once per capillary (cells merged in Excel)
expR = rep(expStr);
firstRow = [true; capR(2:end) ~= capR(1:end-1)];
expR(~firstRow) = "";

report = table(capR, lenR, curR, R.Step, R.N, mStr, round(cvF, 2), dpStr, round(cvP, 2), ...
    round(rep(fitA), 2), round(rep(fitB), 2), round(rep(rSquared), 2), rep(dpTStr), expR, ...
    'VariableNames', {'Capillary No.','Test length (mm)','Current length (mm)','Step','Samples', ...
    'Mass flow (g/s)','CV mass flow (%)','dP (bar)','CV dP (%)', ...
    ['Fit a (bar' char(183) 's' char(178) '/g' char(178) ')'], ...
    ['Fit b (bar' char(183) 's/g)'], ['Fit R' char(178)], ...
    sprintf('dP at %.2f g/s, test length (bar)', targetMassFlow), 'Expected dP (bar)'});

if isempty(reportFile), reportFile = cap_report_name(capillaryIDs, 'expected_dP_report'); end
outputFile = fullfile(campaignFolder, reportFile);
if isfile(outputFile), delete(outputFile); end   % start clean, no old formatting
writetable(report, outputFile, 'Sheet', 'Report');
cap_format_report(outputFile, height(report), width(report), nRows, 14, [7 9 10 11 12], true);   % 14 = expected dP
fprintf('\nReport saved: %s\n', outputFile);

%% Plot expected dP
figure; hold on; grid on;
bar(1:nCap, expectedPressure);
errorbar(1:nCap, expectedPressure, expectedPressureStd, 'k', 'LineStyle', 'none', ...
    'LineWidth', 1.2, 'CapSize', 10, 'HandleVisibility', 'off');
xticks(1:nCap); xticklabels(capillaryIDs); xtickangle(20);
ylabel('Expected Pressure Drop [bar]');
title('Expected Pressure Drop at Current Capillary Length');
subtitle(sprintf('Mass flow = %.2f g/s', targetMassFlow));
if any(outsideMeasuredRange)
    text(0.02, 0.96, 'WARNING: target flow requires extrapolation', 'Units', 'normalized', ...
        'Color', 'red', 'FontWeight', 'bold', 'VerticalAlignment', 'top', 'HandleVisibility', 'off');
end
if any(isfinite(expectedPressure))
    ylim([0 1.12*max(expectedPressure + expectedPressureStd, [], 'omitnan')]);   % room for labels
end
yl = ylim;
lbl = isfinite(expectedPressure) & isfinite(expectedPressureStd);
text(find(lbl), expectedPressure(lbl) + 0.02*diff(yl), expStr(lbl) + " bar", ...
    'HorizontalAlignment', 'center');

% watermark
wm = text(0.98, 0.03, 'Sara Memushaj', 'Units', 'normalized', 'FontSize', 10, ...
    'FontAngle', 'italic', 'Color', [0.6 0.6 0.6], ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
    'HandleVisibility', 'off', 'HitTest', 'off');
uistack(wm, 'bottom');
hold off;
