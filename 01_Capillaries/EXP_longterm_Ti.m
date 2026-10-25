%% Longterm Ti Capillary Test - I.D. 1.1 mm
% Automatically scans ALL Raw_data_*.csv files in the folder
% RAW data only: chronological multi-day time axis + two plots:
% 1) dP [bar] vs time + mass flow on right axis
% 2) Inlet Pressure & Outlet Pressure [bar] vs time + mass flow on right axis

clc; clear; close all;

%% --- LIST OF ALL CSV FILES HERE ---
files = {
    'Raw_data_23.02.2026.0.csv'
    'Raw_data_02.03.2026.0.csv'
    'Raw_data_09.03.2026.0.csv'
    'Raw_data_18.03.2026.0.csv'
    'Raw_data_19.03.2026.0.csv'
    'Raw_data_backup_2.csv'
    'Raw_data_backup_2 (2).csv'
    
    % 'Raw_data_24.03.2026.0.csv'
    % 'Raw_data_26.03.2026.0.csv'
    % 'Raw_data_backup_1.csv'
    % 'Raw_data_31.03.2026.0.csv'
    % 'Raw_data_01.04.2026.0.csv'
    
    'Raw_data_08.04.2026.0.csv'
    'Raw_data_13.04.2026.0.csv'
};

%% --- FLOW FILE ---
flowFile = 'Plant_2_flow.csv';

%% --- Remove duplicate filenames if any ---
files = unique(files, 'stable');

%% --- Read flow data ---
optsFlow = detectImportOptions(flowFile, ...
    'NumHeaderLines', 0, ...
    'VariableNamingRule', 'preserve');

% Make sure first column is read as char/text
flowVarNames = optsFlow.VariableNames;
flowTimeColName = flowVarNames{1};
flowValueColName = flowVarNames{2};

optsFlow = setvartype(optsFlow, flowTimeColName, 'char');

TF = readtable(flowFile, optsFlow);

flowTimeRaw = string(TF.(flowTimeColName));
flowValRaw  = TF.(flowValueColName);

% Remove repeated header rows / blank rows
badFlowRows = strcmpi(strtrim(flowTimeRaw), 'Year/Month/Day Hour:Minute:Second.Millisecond') | ...
              strlength(strtrim(flowTimeRaw)) == 0;

flowTimeRaw = flowTimeRaw(~badFlowRows);
flowValRaw  = flowValRaw(~badFlowRows);

% Convert flow values to numeric if needed
if iscell(flowValRaw) || isstring(flowValRaw) || ischar(flowValRaw)
    flowAll = str2double(string(flowValRaw));
else
    flowAll = flowValRaw;
end

% Parse flow timestamps
% Current file format appears to be: dd/MM/yyyy HH:mm
flowTimeAll = datetime(flowTimeRaw, ...
    'InputFormat', 'dd/MM/yyyy HH:mm', ...
    'Format', 'dd-MMM HH:mm');

if any(isnat(flowTimeAll))
    error('Some flow datetime rows could not be parsed in file: %s', flowFile);
end

% Sort flow data
[flowTimeAll, idxFlow] = sort(flowTimeAll);
flowAll = flowAll(idxFlow);

%% --- Storage for concatenated data ---
timeAll = datetime.empty(0,1);
dPAll   = [];
PinAll  = [];
PoutAll = [];
hasP1_global = true;
hasP2_global = true;

%% --- Loop through each pressure data file ---
for f = 1:numel(files)
    filename = files{f};
    fprintf('\nReading file: %s\n', filename);

    % Import options: preserve names
    opts = detectImportOptions(filename, ...
        'NumHeaderLines', 0, ...
        'VariableNamingRule', 'preserve');

    % Make sure we know the names MATLAB sees
    varNames = opts.VariableNames;

    % Find Date and Time columns by name
    idxDate = find(strcmp(varNames, 'Date'), 1);
    idxTime = find(strcmp(varNames, 'Time'), 1);

    if isempty(idxDate) || isempty(idxTime)
        error('Could not find Date and/or Time columns in file: %s', filename);
    end

    dateColName = varNames{idxDate};
    timeColName = varNames{idxTime};

    % Force those two columns to char for safe parsing
    opts = setvartype(opts, {dateColName, timeColName}, 'char');

    % Read table
    T = readtable(filename, opts);

    %% --- Extract raw Date + Time text ---
    dateTxt = string(T.(dateColName));
    timeTxt = string(T.(timeColName));

    % Remove repeated header rows or invalid rows inside file
    badRows = strcmpi(strtrim(dateTxt), 'Date') | ...
              strcmpi(strtrim(timeTxt), 'Time') | ...
              strlength(strtrim(dateTxt)) == 0 | ...
              strlength(strtrim(timeTxt)) == 0;

    dateTxt = dateTxt(~badRows);
    timeTxt = timeTxt(~badRows);

    % Build one combined datetime string and parse it in one step
    dateTimeTxt = dateTxt + " " + timeTxt;
    timeLocal = datetime(dateTimeTxt, ...
        'InputFormat', 'dd/MM/yyyy HH:mm:ss', ...
        'Format', 'dd-MMM HH:mm');

    % If some rows have milliseconds, parse those too
    badTime = isnat(timeLocal);
    if any(badTime)
        timeLocal(badTime) = datetime(dateTimeTxt(badTime), ...
            'InputFormat', 'dd/MM/yyyy HH:mm:ss.SSS', ...
            'Format', 'dd-MMM HH:mm');
    end

    % If some rows are only HH:mm
    badTime = isnat(timeLocal);
    if any(badTime)
        timeLocal(badTime) = datetime(dateTimeTxt(badTime), ...
            'InputFormat', 'dd/MM/yyyy HH:mm', ...
            'Format', 'dd-MMM HH:mm');
    end

    if any(isnat(timeLocal))
        error('Some datetime rows could not be parsed in file: %s', filename);
    end

    fprintf('   Start: %s\n', string(min(timeLocal)));
    fprintf('   End  : %s\n', string(max(timeLocal)));

    %% --- Extract pressure columns ---
    names = T.Properties.VariableNames;

    % dP column
    if ismember('dP [bar]', names)
        dP = T.('dP [bar]');
    else
        error('Could not find "dP [bar]" column in file: %s', filename);
    end

    % Inlet pressure (Pin)
    if ismember('Inlet [bar]', names)
        Pin = T.('Inlet [bar]');
    else
        idxIn = find(contains(names, 'Inlet', 'IgnoreCase', true), 1);
        if ~isempty(idxIn)
            Pin = T.(names{idxIn});
            warning('Using column "%s" as Inlet in file: %s', names{idxIn}, filename);
        else
            Pin = nan(size(dP));
            hasP1_global = false;
            warning('No "Inlet [bar]" column found in %s → setting Pin = NaN.', filename);
        end
    end

    % Outlet pressure (Pout)
    if ismember('Outlet [bar]', names)
        Pout = T.('Outlet [bar]');
    else
        idxOut = find(contains(names, 'Outlet', 'IgnoreCase', true), 1);
        if ~isempty(idxOut)
            Pout = T.(names{idxOut});
            warning('Using column "%s" as Outlet in file: %s', names{idxOut}, filename);
        else
            Pout = nan(size(dP));
            hasP2_global = false;
            warning('No "Outlet [bar]" column found in %s → setting Pout = NaN.', filename);
        end
    end

    % Remove same bad rows from data
    dP   = dP(~badRows);
    Pin  = Pin(~badRows);
    Pout = Pout(~badRows);

    % Convert text columns to numeric if needed
    if iscell(dP) || isstring(dP) || ischar(dP)
        dP = str2double(string(dP));
    end
    if iscell(Pin) || isstring(Pin) || ischar(Pin)
        Pin = str2double(string(Pin));
    end
    if iscell(Pout) || isstring(Pout) || ischar(Pout)
        Pout = str2double(string(Pout));
    end

    %% --- Append to global arrays ---
    timeAll = [timeAll; timeLocal];
    dPAll   = [dPAll; dP];
    PinAll  = [PinAll; Pin];
    PoutAll = [PoutAll; Pout];
end

%% --- Sort chronologically ---
[timeAll, idx] = sort(timeAll);
dPAll   = dPAll(idx);
PinAll  = PinAll(idx);
PoutAll = PoutAll(idx);

%% --- Break lines across large time gaps in pressure data ---
dtHours = hours(diff(timeAll));
gapIdx = find(dtHours > 6);

for k = 1:numel(gapIdx)
    insertPos = gapIdx(k) + (k-1);
    timeAll = [timeAll(1:insertPos); NaT; timeAll(insertPos+1:end)];
    dPAll   = [dPAll(1:insertPos); NaN; dPAll(insertPos+1:end)];
    PinAll  = [PinAll(1:insertPos); NaN; PinAll(insertPos+1:end)];
    PoutAll = [PoutAll(1:insertPos); NaN; PoutAll(insertPos+1:end)];
end

%% --- Break lines across large time gaps in flow data ---
dtHoursFlow = hours(diff(flowTimeAll));
gapIdxFlow = find(dtHoursFlow > 6);

for k = 1:numel(gapIdxFlow)
    insertPos = gapIdxFlow(k) + (k-1);
    flowTimeAll = [flowTimeAll(1:insertPos); NaT; flowTimeAll(insertPos+1:end)];
    flowAll     = [flowAll(1:insertPos); NaN; flowAll(insertPos+1:end)];
end

%% --- Calculate averages ---
avg_dP = mean(dPAll, 'omitnan');
avg_flow = round(mean(flowAll, 'omitnan'), 1);

fprintf('\nOverall mean dP = %.3f bar\n', avg_dP);
fprintf('Overall mean mass flow = %.1f g/s\n', avg_flow);

%% --- Plot 1: dP vs time + Mass Flow ---
figure('Color','w');

yyaxis left
plot(timeAll, dPAll, 'LineWidth', 1.1); hold on;
ylim([0 max(dPAll, [], 'omitnan')*1.05])

yline(avg_dP, '--', sprintf('Avg dP = %.3f bar', avg_dP), ...
    'LabelHorizontalAlignment','right');

ylabel('Pressure Drop [bar]');

yyaxis right
plot(flowTimeAll, flowAll, 'LineWidth', 1.0); hold on;
ylim([0 5])

yline(avg_flow, '--', sprintf('Avg flow = %.1f g/s', avg_flow), ...
    'LabelHorizontalAlignment','right');

ylabel('Mass Flow Rate [g/s]');

xlabel('Time');
title(sprintf(['Pressure Drop vs Time of Ti Capillary Longterm Test'...
    '\n m = 4.2 g/s | T_{in} = %.0f\\circC | P_{in} = %.1f bar | I.D. = %.2f mm | L ≈ 3800 mm | No.02'], ...
    -35, 42.6, 1.10));

grid on; box on;
legend('dP','Avg dP','Mass Flow','Avg flow','Location','best');

% Watermark
text(0.99, 0.01, 'Sara Memushaj', 'Units', 'normalized', ...
    'HorizontalAlignment', 'right', 'FontSize', 8, 'FontAngle', 'italic', ...
    'Color', [0.5 0.5 0.5]);

%% --- Plot 2: Pin & Pout vs time + Mass Flow ---
if hasP1_global && hasP2_global
    figure('Color','w');

    yyaxis left
    plot(timeAll, PinAll,  'LineWidth', 1.0); hold on;
    plot(timeAll, PoutAll, 'LineWidth', 1.0);
    ylabel('Pressure [bar]');
    ylim([0 max([PinAll; PoutAll], [], 'omitnan')*1.05])

    yyaxis right
    plot(flowTimeAll, flowAll, 'LineWidth', 1.0); hold on;
    ylabel('Mass Flow Rate [g/s]');
    ylim([0 5])

    yline(avg_flow, '--', sprintf('Avg flow = %.1f g/s', avg_flow), ...
        'LabelHorizontalAlignment','right');

    xlabel('Time');
    title(sprintf(['Inlet & Outlet Pressure vs Time'...
        '\n m = 4.2 g/s | T_{in} = %.0f\\circC | P_{in} = %.1f bar | I.D. = %.2f mm | L ≈ 3800 mm | No.02'], ...
        -35, 42.6, 1.10));

    legend('Inlet','Outlet','Mass Flow','Avg flow','Location','best');
    grid on; box on;
else
    warning('Not all files contain Inlet/Outlet pressure → skipping Pin/Pout plot.');
end

% Watermark
text(0.99, 0.01, 'Sara Memushaj', 'Units', 'normalized', ...
    'HorizontalAlignment', 'right', 'FontSize', 8, 'FontAngle', 'italic', ...
    'Color', [0.5 0.5 0.5]);