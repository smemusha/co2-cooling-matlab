clc;
clear;

% === Read Excel file ===
opts = detectImportOptions('Test_DIFF_LOADS_4.2gs_-15oC.xlsx', 'NumHeaderLines', 5, 'VariableNamingRule', 'preserve');
data = readtable('Test_DIFF_LOADS_4.2gs_-15oC.xlsx', opts);

% === Filter for Mass Flow = 4.2 g/s ===
data_filtered = data(data.("Mass Flow [g/s]") == 4.2, :);

% === Identify unique power cases ===
unique_powers = unique(data_filtered.("Target Total Power [W]"));

% === Constants ===
fld = 'CO2';
mass_flow = 4.2e-3; % kg/s

N_sensors = 36;
point_indices = 1:N_sensors;

dq_cols = data.Properties.VariableNames(93:128);

D = 0.0025; % m
A = pi*(D/2)^2;

% === Output Folder ===
output_folder = 'C:\Users\smemusha\cernbox\WINDOWS\Desktop\DryOut_Test\Dryot_Test_DIFF_LOADS_4.2_gs_-15oC';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

figure('Position',[0 0 1200 900]);
hold on;
legend_entries = {};

all_VQ_export = table();

for p = 1:length(unique_powers)
    power_value = unique_powers(p);

    rows = data_filtered(data_filtered.("Target Total Power [W]") == power_value, :);
    real_power_per_row = zeros(size(rows,1), 1);

    for row = 1:size(rows,1)
        Pin = rows.("Pin [bar]")(row);
        Pexh = rows.("Pexh [bar]")(row);
        P_avg = (Pin + Pexh) / 2;
        T_in = rows.("Tin [C]")(row);

        H = refpropm('H', 'T', T_in + 273.15, 'P', P_avg * 1e2, fld);
        H_liq = refpropm('H', 'P', P_avg * 1e2, 'Q', 0, fld);
        H_vap = refpropm('H', 'P', P_avg * 1e2, 'Q', 1, fld);

        dq_blocks = rows{row, dq_cols};
        sum_dq = sum(dq_blocks);
        real_power_per_row(row) = sum_dq;

        fprintf('Row %d | Target Power = %.1f W | Real Power = %.1f W\n', row, power_value, sum_dq);

        VQ_profile = NaN(1, N_sensors);

        for i = 1:N_sensors
            dq_i = dq_blocks(i);
            dh_i = dq_i / mass_flow;

            H = H + dh_i;
            VQ = (H - H_liq) / (H_vap - H_liq);

            % === Clamp values between 0 and 1 ===
            VQ = max(0, min(1, VQ));

            VQ_profile(i) = VQ;
        end

        % === Plot this row separately ===
        plot(point_indices, VQ_profile, '-o', 'LineWidth', 1.5);
        legend_entries{end+1} = sprintf('Real Power = %.1f W', sum_dq);

        % === Export ===
        vq_names = "VQ_Block" + (1:N_sensors);
        export_row = array2table([sum_dq, row, VQ_profile], ...
            'VariableNames', ["RealPower_W", "Row_Index", vq_names]);
        all_VQ_export = [all_VQ_export; export_row];
    end
end

xlabel('Heater Block ID');
ylabel('Vapor Quality');
title(sprintf(['VQ Profiles for Variable Heat Loads at Nominal Flow (Dry-out Testing Prototype)' ...
    '\n m = 4.2 g/s | T_{in_{evap}} = %.0f\\circC | P_{in_{evap}} = %.0f bar | I.D. = %.2f mm'], -15, 24, D*1e3));
grid on;
legend(legend_entries, 'Location', 'best');

xlim([1 36]);
xticks(1:1:36);
yticks(0:0.02:1.0);

% === Watermark ===
text(0.99, 0.01, 'Sara Memushaj', 'Units', 'normalized', ...
    'HorizontalAlignment', 'right', 'FontSize', 8, 'FontAngle', 'italic', ...
    'Color', [0.5 0.5 0.5]);

% === Export File ===
output_filename = fullfile(output_folder, 'CUMULATIVE_VQ_ALL_POWERS_4.14gs_-15oC.csv');
writetable(all_VQ_export, output_filename);

fprintf('✅ All VQ profiles exported with Real Power to: %s\n', output_filename);
