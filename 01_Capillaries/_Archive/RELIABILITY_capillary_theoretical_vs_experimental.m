% Load your data tables
dataTable1 = readtable('2025.05.07_POB_1.1mm_Repitition_No1.csv');
dataTable2 = readtable('2025.05.07_POB_1.1mm_Repitition_No1.csv');
dataTable3 = readtable('2025.05.07_POB_1.1mm_Repitition_No1.csv');
dataTable4 = readtable('2025.05.07_POB_1.1mm_Repitition_No1.csv');
dataTable5 = readtable('2025.05.07_POB_1.1mm_Repitition_No1.csv');

% Define your time ranges as n×2 datetime arrays
timeRanges1 = [... 
    datetime('2025/05/07 14:55:00.000'), datetime('2025/05/07 15:00:00.000');
    datetime('2025/05/07 15:19:00.000'), datetime('2025/05/07 15:24:00.000');
    datetime('2025/05/07 15:42:00.000'), datetime('2025/05/07 15:47:00.000');
    datetime('2025/05/07 16:12:00.000'), datetime('2025/05/07 16:17:00.000')
];
timeRanges2 = [... % same format as timeRanges1
    datetime('2025/05/07 14:55:00.000'), datetime('2025/05/07 15:00:00.000');
    datetime('2025/05/07 15:19:00.000'), datetime('2025/05/07 15:24:00.000');
    datetime('2025/05/07 15:42:00.000'), datetime('2025/05/07 15:47:00.000');
    datetime('2025/05/07 16:12:00.000'), datetime('2025/05/07 16:17:00.000')
];
timeRanges3 = [... % same format
    datetime('2025/05/07 14:55:00.000'), datetime('2025/05/07 15:00:00.000');
    datetime('2025/05/07 15:19:00.000'), datetime('2025/05/07 15:24:00.000');
    datetime('2025/05/07 15:42:00.000'), datetime('2025/05/07 15:47:00.000');
    datetime('2025/05/07 16:12:00.000'), datetime('2025/05/07 16:17:00.000')
];
timeRanges4 = [... % same format
    datetime('2025/05/07 14:55:00.000'), datetime('2025/05/07 15:00:00.000');
    datetime('2025/05/07 15:19:00.000'), datetime('2025/05/07 15:24:00.000');
    datetime('2025/05/07 15:42:00.000'), datetime('2025/05/07 15:47:00.000');
    datetime('2025/05/07 16:12:00.000'), datetime('2025/05/07 16:17:00.000')
];
timeRanges5 = [... % same format
    datetime('2025/05/07 14:55:00.000'), datetime('2025/05/07 15:00:00.000');
    datetime('2025/05/07 15:19:00.000'), datetime('2025/05/07 15:24:00.000');
    datetime('2025/05/07 15:42:00.000'), datetime('2025/05/07 15:47:00.000');
    datetime('2025/05/07 16:12:00.000'), datetime('2025/05/07 16:17:00.000')
];
% Check that all time range arrays have the same number of rows
n = size(timeRanges1, 1);
if any([size(timeRanges2, 1), size(timeRanges3, 1), size(timeRanges4, 1), size(timeRanges5, 1)] ~= n)
    error('All time range arrays must have the same number of rows.');
end

for i = 1:n
    % Extract the i-th time range for each dataset
    t1 = timeRanges1(i, :);
    t2 = timeRanges2(i, :);
    t3 = timeRanges3(i, :);
    t4 = timeRanges4(i, :);
    t5 = timeRanges5(i, :);

    % Extract subset of data within each time range
    subset1 = dataTable1(dataTable1.Time >= t1(1) & dataTable1.Time <= t1(2), :);
    subset2 = dataTable2(dataTable2.Time >= t2(1) & dataTable2.Time <= t2(2), :);
    subset3 = dataTable3(dataTable3.Time >= t3(1) & dataTable3.Time <= t3(2), :);
    subset4 = dataTable4(dataTable4.Time >= t4(1) & dataTable4.Time <= t4(2), :);
    subset5 = dataTable5(dataTable5.Time >= t5(1) & dataTable5.Time <= t5(2), :);

    % Plot all five subsets in one figure
    figure;
    hold on;
    plot(subset1.Time, subset1.Value, 'r', 'DisplayName', 'Set 1');
    plot(subset2.Time, subset2.Value, 'g', 'DisplayName', 'Set 2');
    plot(subset3.Time, subset3.Value, 'b', 'DisplayName', 'Set 3');
    plot(subset4.Time, subset4.Value, 'm', 'DisplayName', 'Set 4');
    plot(subset5.Time, subset5.Value, 'k', 'DisplayName', 'Set 5');

    title(sprintf('Combined Plot for Time Range Row %d', i));
    xlabel('Time');
    ylabel('Value');
    legend show;
    hold off;
end
