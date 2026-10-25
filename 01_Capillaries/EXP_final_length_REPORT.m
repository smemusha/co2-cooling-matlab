%% Required capillary lengths from experimental dP data (B180)

% Reads SCADA recordings of the COS test stand (DP1050 pressure drop [bar],
% FT1030 mass flow [g/s]) and the stable time windows of each flow step,
% taken from the colleagues' "Timestamps" Excel files (or from the manual
% backup list). For every capillary it computes mean, STD and CV per step,
% fits dP = a*m^2 + b*m through the origin (dP = a*m^2 for a single point),
% evaluates dP at the target mass flow and scales the tested length to the
% target dP: L_required = L_test * dP_target / dP_at_target_flow.

% Inputs : one campaign folder holding the SCADA csv files, the "Timestamps"
%          xlsx files and lengths.xlsx (Capillary | Test length | Current length);
%          capillary IDs are read from the timestamp files.
% Outputs: final-length bar chart, compact summary in the Command Window,
%          a formatted Excel report (value +/- STD in the same cell) and the
%          cut lengths (final + STD + 150 mm) written to the lengths.xlsx files.
clear; clc;

% ================================================================
%  INPUTS
% ================================================================

% Campaign folder: SCADA csv files, "Timestamps" xlsx files and lengths.xlsx
campaignFolder = 'C:\Users\smemusha\cernbox\WINDOWS\Desktop\ITk\Capilaries\Measurements\Interalloy batch\PRODUCTION\I.D_0.76\No.13-16';
lengthsFile    = fullfile(campaignFolder, 'lengths.xlsx');   % Capillary | Test length (mm) | Current length (mm)
reportFile     = '';   % '' = automatic name, saved in the campaign folder
sfpFolder      = fullfile(campaignFolder, 'Single_flow_point');   % next test, at the cut lengths
cutMargin      = 150;  % [mm] cut length = final + STD + cutMargin (at most the tested length)

% BACKUP - manual windows, one row per flow step.
% timeRanges = {
%     % P.O.B-D076-013
%     ["2026/10/23 08:09:00", "2026/10/23 08:14:00"
%      "2026/10/23 10:28:00", "2026/10/23 10:33:00"
%      "2026/10/22 18:56:00", "2026/10/22 19:01:00"
%      "2026/10/22 16:22:00", "2026/10/22 16:27:00"]
%     % P.O.B-D076-014
%     ["2026/10/23 08:29:00", "2026/10/23 08:34:00"
%      "2026/10/23 10:04:00", "2026/10/23 10:09:00"
%      "2026/10/22 18:42:00", "2026/10/22 18:47:00"
%      "2026/10/22 16:36:00", "2026/10/22 16:41:00"]
%     % P.O.B-D076-015
%     ["2026/10/23 08:57:00", "2026/10/23 09:02:00"
%      "2026/10/23 09:47:00", "2026/10/23 09:52:00"
%      "2026/10/22 18:28:00", "2026/10/22 18:33:00"
%      "2026/10/22 16:48:00", "2026/10/22 16:53:00"]
%     % P.O.B-D076-016
%     ["2026/10/23 09:19:00", "2026/10/23 09:24:00"
%      "2026/10/23 09:30:00", "2026/10/23 09:35:00"
%      "2026/10/22 17:59:00", "2026/10/22 18:04:00"
%      "2026/10/22 17:01:00", "2026/10/22 17:06:00"]
% };
% capillaryIDs = ["P.O.B-D076-013"; "P.O.B-D076-014"; "P.O.B-D076-015"; "P.O.B-D076-016"];   % only with the manual windows


% Target
targetPressureDrop = 8.75;   % [bar]
targetMassFlow     = 1.89;   % [g/s]

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
[allTime, allPressure, allFlow] = cap_read_scada(files, timeColumn, pressureColumn, flowColumn, 'rows');

fprintf('==== Required capillary lengths ====\n');
fprintf('Target: dP = %.2f bar at %.2f g/s\n', targetPressureDrop, targetMassFlow);
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
assert(numel(timeRanges) == nCap, 'timeRanges: one group per capillary');
fprintf('\nCapillaries and lengths\n  %-16s %6s\n', 'Capillary', 'L [mm]');
fprintf('  %-16s %6s\n', [capillaryIDs, string(testLength(:))].');

%% Mean / STD per step, fit and required length
stats = cell(nCap,1);
fitA = NaN(nCap,1); fitB = NaN(nCap,1); rSquared = NaN(nCap,1);
dpTarget = NaN(nCap,1); dpTargetStd = NaN(nCap,1);
requiredLength = NaN(nCap,1); requiredLengthStd = NaN(nCap,1);

for c = 1:nCap
    win = datetime(timeRanges{c}, 'InputFormat', 'yyyy/MM/dd HH:mm:ss');
    nSteps = size(win,1);
    S = NaN(nSteps,4);   % meanF stdF meanP stdP
    N = zeros(nSteps,1);
    for k = 1:nSteps
        sel = allTime >= win(k,1) & allTime <= win(k,2);
        F = allFlow(sel); P = allPressure(sel);
        S(k,:) = [mean(F,'omitnan') std(F,0,'omitnan') mean(P,'omitnan') std(P,0,'omitnan')];
        N(k) = sum(~isnan(F) & ~isnan(P));
        if isnan(S(k,1)) || isnan(S(k,3))
            warning('%s step %d: no SCADA data between %s and %s', capillaryIDs(c), k, ...
                char(win(k,1), [fmtDay ' ' fmtMin]), char(win(k,2), fmtMin));
        end
    end
    valid = ~isnan(S(:,1)) & ~isnan(S(:,3));
    S = S(valid,:); N = N(valid);
    if isempty(N)
        warning('No valid experimental data for %s', capillaryIDs(c));
        stats{c} = table(zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), ...
            'VariableNames', {'Step','N','mF','sF','dP','sP'});
        continue
    end
    [~, o] = sort(S(:,1));                      % steps by increasing flow
    S = S(o,:); N = N(o);
    stats{c} = table((1:numel(N))', N, S(:,1), S(:,2), S(:,3), S(:,4), ...
        'VariableNames', {'Step','N','mF','sF','dP','sP'});
    x = S(:,1); y = S(:,3); sy = S(:,4);

    if isscalar(x)
        % single point: dP = a*m^2, STD scaled with the same m^2 law
        fitA(c) = y/x^2; fitB(c) = 0;
        dpTarget(c) = fitA(c)*targetMassFlow^2;
        dpTargetStd(c) = sy*(targetMassFlow/x)^2;
        if targetMassFlow > x
            warning('%s: target %.2f g/s above measured %.3f g/s (extrapolation)', ...
                capillaryIDs(c), targetMassFlow, x);
        end
    else
        % several points: dP = a*m^2 + b*m through the origin
        if targetMassFlow < min(x) || targetMassFlow > max(x)
            warning('%s: target %.2f g/s outside measured range [%.3f, %.3f] g/s (extrapolation)', ...
                capillaryIDs(c), targetMassFlow, min(x), max(x));
        end
        A = [x.^2, x];
        coeff = A\y;
        fitA(c) = coeff(1); fitB(c) = coeff(2);
        rSquared(c) = 1 - sum((y - A*coeff).^2)/sum((y - mean(y)).^2);
        dpTarget(c) = fitA(c)*targetMassFlow^2 + fitB(c)*targetMassFlow;
        dpTargetStd(c) = interp1(x, sy, targetMassFlow, 'linear', 'extrap');
    end

    % dP proportional to L at constant flow; sigma_L/L = sigma_dP/dP
    requiredLength(c) = testLength(c)*targetPressureDrop/dpTarget(c);
    requiredLengthStd(c) = requiredLength(c)*dpTargetStd(c)/dpTarget(c);
end

nRows = cellfun(@height, stats);
assert(any(nRows > 0), 'No valid capillary steps found. Check csv files and time windows.');

%% Command Window summary
R = vertcat(stats{:});
rep = @(v) repelem(v, nRows);
capR = rep(capillaryIDs); lenR = rep(testLength);
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

dpTStr = compose("%.2f " + pm + " %.2f", [dpTarget dpTargetStd]);
lenStr = compose("%.0f " + pm + " %.0f", [requiredLength requiredLengthStd]);

fprintf('\nFinal length for dP = %.2f bar at %.2f g/s   (fit: dP = a%cm%c + b%cm)\n', ...
    targetPressureDrop, targetMassFlow, char(183), char(178), char(183));
fprintf('  %-16s %6s %15s %13s %6s  %-14s %-14s\n', 'Capillary', 'L [mm]', ...
    ['a [bar' char(183) 's' char(178) '/g' char(178) ']'], ['b [bar' char(183) 's/g]'], ...
    ['R' char(178)], 'dP@m [bar]', 'L final [mm]');
for c = 1:nCap
    r2 = "-"; if isfinite(rSquared(c)), r2 = sprintf('%.2f', rSquared(c)); end
    fprintf('  %-16s %6g %15.2f %13.2f %6s  %-14s %-14s\n', capillaryIDs(c), testLength(c), ...
        fitA(c), fitB(c), r2, dpTStr(c), lenStr(c));
end

%% Excel report (one file, value ± STD in the same cell)
% final length only once per capillary (cells merged in Excel)
finalR = rep(lenStr);
firstRow = [true; capR(2:end) ~= capR(1:end-1)];
finalR(~firstRow) = "";
report = table(capR, lenR, R.Step, R.N, mStr, round(cvF, 2), dpStr, round(cvP, 2), ...
    round(rep(fitA), 2), round(rep(fitB), 2), round(rep(rSquared), 2), ...
    rep(dpTStr), rep(repmat(targetPressureDrop, nCap, 1)), finalR, ...
    'VariableNames', {'Capillary No.','Test length (mm)','Step','Samples', ...
    'Mass flow (g/s)','CV mass flow (%)','dP (bar)','CV dP (%)', ...
    ['Fit a (bar' char(183) 's' char(178) '/g' char(178) ')'], ...
    ['Fit b (bar' char(183) 's/g)'], ['Fit R' char(178)], ...
    sprintf('dP at %.2f g/s (bar)', targetMassFlow), 'Required dP (bar)', ...
    'Final length (mm)'});

if isempty(reportFile), reportFile = cap_report_name(capillaryIDs, 'final_lengths_report'); end
outputFile = fullfile(campaignFolder, reportFile);
if isfile(outputFile), delete(outputFile); end   % start clean, no old formatting
writetable(report, outputFile, 'Sheet', 'Report');
cap_format_report(outputFile, height(report), width(report), nRows, 14, [6 8 9 10 11 13], true);   % 14 = final length
fprintf('\nReport saved: %s\n', outputFile);

%% Cut lengths for the single flow point test
cap_write_cut_lengths(lengthsFile, sfpFolder, capillaryIDs, requiredLength, requiredLengthStd, cutMargin, testLength);

%% Plot required lengths
figure; hold on; grid on;
bar(1:nCap, requiredLength);
errorbar(1:nCap, requiredLength, requiredLengthStd, 'k', 'LineStyle', 'none', ...
    'LineWidth', 1.2, 'CapSize', 10, 'HandleVisibility', 'off');
xticks(1:nCap); xticklabels(capillaryIDs); xtickangle(20);
ylabel('Final Capillary Length [mm]');
title('Final Length for Each Capillary');
subtitle(sprintf('Target: dP = %.2f bar at %.2f g/s', targetPressureDrop, targetMassFlow));
ylim([0 1.12*max(requiredLength + requiredLengthStd, [], 'omitnan')]);   % room for labels
yl = ylim;
text(1:nCap, requiredLength + 0.02*diff(yl), lenStr + " mm", 'HorizontalAlignment', 'center');

% watermark
wm = text(0.98, 0.03, 'Sara Memushaj', 'Units', 'normalized', 'FontSize', 10, ...
    'FontAngle', 'italic', 'Color', [0.6 0.6 0.6], ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
    'HandleVisibility', 'off', 'HitTest', 'off');
uistack(wm, 'bottom');
hold off;
