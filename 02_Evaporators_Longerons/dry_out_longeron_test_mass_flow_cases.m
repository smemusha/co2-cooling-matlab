clc;
clear;

fld = 'CO2';
N_sensors = 36;
point_indices = 1:N_sensors;

% === Read Excel file ===
opts = detectImportOptions('Test_DIFF_FLOWS_420W_-15oC.xlsx', 'NumHeaderLines', 5, 'VariableNamingRule', 'preserve');
data = readtable('Test_DIFF_FLOWS_420W_-15oC.xlsx', opts);

% === Identify unique mass flow rates ===
unique_flows = unique(data.("Mass Flow [g/s]"));

dq_cols = data.Properties.VariableNames(93:128);

D = 0.0025; % m
A = pi*(D/2)^2;
P_heated = 0.5 * pi * D;

% === Ensure correct output folder exists ===
output_folder = 'C:\Users\smemusha\cernbox\WINDOWS\Desktop\DryOut_Test\Dryot_Test_DIFF_FLOWS_420W_-15oC';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% === First figure: VQ profiles ===
figure('Position',[0 0 1200 900]);
hold on;
legend_entries = {};

all_VQ_export = table();

% === Loop over all mass flows ===
for f = 1:length(unique_flows)
    flow_value = unique_flows(f);
    rows = data(data.("Mass Flow [g/s]") == flow_value, :);

    for row = 1:size(rows,1)
        Pin = rows.("Pin [bar]")(row);
        Pexh = rows.("Pexh [bar]")(row);
        P_avg = (Pin + Pexh) / 2;
        T_in = rows.("Tin [C]")(row);

        mass_flow = flow_value * 1e-3; % kg/s
        MFLX = mass_flow / A;

        H = refpropm('H', 'T', T_in + 273.15, 'P', P_avg * 1e2, fld);
        H_liq = refpropm('H', 'P', P_avg * 1e2, 'Q', 0, fld);
        H_vap = refpropm('H', 'P', P_avg * 1e2, 'Q', 1, fld);

        dq_blocks = rows{row, dq_cols};
        sum_dq = sum(dq_blocks);

        % Log message
        fprintf('Row %d | Flow = %.2f g/s | Real Power = %.1f W\n', row, flow_value, sum_dq);

        VQ_profile = NaN(1, N_sensors);

        for i = 1:N_sensors
            dq_i = dq_blocks(i);
            dh_i = dq_i / mass_flow;
            H = H + dh_i;
            VQ = (H - H_liq) / (H_vap - H_liq);
            VQ = min(max(VQ, 0), 0.999);
            VQ_profile(i) = VQ;
        end

        % Export row with real power
        vq_names = "VQ_Block" + (1:N_sensors);
        export_row = array2table([flow_value, sum_dq, row, VQ_profile], ...
            'VariableNames', ["MassFlow_gs", "RealPower_W", "Row_Index", vq_names]);
        all_VQ_export = [all_VQ_export; export_row];

        % Plot this row
        plot(point_indices, VQ_profile, '-o', 'LineWidth', 1.5);
        legend_entries{end+1} = sprintf('%.2f g/s | %.0f W', flow_value, sum_dq);
    end
end

xlabel('Heater Block ID');
ylabel('Vapor Quality');
title(sprintf(['VQ Profiles for Variable Mass Flows (Dry-out Testing Prototype)' ...
    '\n P = 420 W | T_{in_{evap}} = %.0f\\circC | P_{in_{evap}} = %.0f bar | I.D. = %.2f mm'], -15, 25, D*1e3));
grid on;
legend(legend_entries, 'Location', 'best');

xlim([1 36]);
xticks(1:1:36);
ylim([0 0.9]);
yticks(0:0.02:0.9);

% Watermark Text
text(0.99, 0.01, 'Sara Memushaj', 'Units', 'normalized', ...
    'HorizontalAlignment', 'right', 'FontSize', 8, 'FontAngle', 'italic', ...
    'Color', [0.5 0.5 0.5]);

% === Export consolidated file ===
output_filename = fullfile(output_folder, 'CUMULATIVE_VQ_ALL_FLOWS_420W_-15oC.csv');
writetable(all_VQ_export, output_filename);

fprintf('✅ All VQ profiles (per case, including 0 W) exported to: %s\n', output_filename);

%% === ΔT vs Mass Flow for Each Heater Block ===
% Heater block temperatures are in columns K–AT (11–46)
T_cols = data.Properties.VariableNames(11:46);  
heater_temps = data{:, T_cols};

% Find the reference temperatures at 420 W and 4.2 g/s
ref_row_idx = find(data.("Target Total Power [W]") == 420 & ...
                   data.("Mass Flow [g/s]") == 4.2, 1, 'first');
if isempty(ref_row_idx)
    error('Reference case (420 W, 4.2 g/s) not found.');
end
T_ref = heater_temps(ref_row_idx, :);

% Prepare plot
figure('Position',[0 0 1200 900]);
hold on;

% Store ΔT for each mass flow
unique_flows = unique(data.("Mass Flow [g/s]"));
colors = lines(N_sensors);  % For visual distinction

for i = 1:N_sensors
    deltaTs = [];
    flows = [];

    for f = 1:length(unique_flows)
        flow_value = unique_flows(f);
        % Find row with current flow and 420 W
        match = find(data.("Mass Flow [g/s]") == flow_value & ...
                     data.("Target Total Power [W]") == 420, 1, 'first');
        if isempty(match)
            continue;
        end
        T_i = heater_temps(match, i);
        DT = T_i - T_ref(i);   % ΔT relative to reference case
        deltaTs(end+1) = DT;
        flows(end+1) = flow_value;
    end

    plot(flows, deltaTs, '-o', 'Color', colors(i,:), ...
         'DisplayName', sprintf('Heater %d', i));
end

xlabel('Mass Flow [g/s]');
ylabel('\DeltaT [^\circC] (vs 4.2 g/s @ 420 W)');
title(sprintf(['ΔT of Each Heater Block per Mass Flow Case (case 4.2 g/s @ 420 W as reference)' ...
    '\n P = 420 W | T_{in_{evap}} = %.0f\\circC | P_{in_{evap}} = %.0f bar | I.D. = %.2f mm'], ...
    -15, 25, D*1e3));
legend('Location', 'eastoutside');
grid on;

xlim([1.5 4.5]);
xticks(1.5:0.1:4.5)

% Watermark
text(0.99, 0.01, 'Sara Memushaj', 'Units', 'normalized', ...
    'HorizontalAlignment', 'right', 'FontSize', 8, 'FontAngle', 'italic', ...
    'Color', [0.5 0.5 0.5]);

%% ===ΔT Profiles (Heater Block T - Inlet Fluid T) ===

% % Heater block temperatures are in columns K–AT (11–46)
% heater_temps = data{:, 11:46};
% 
% % Inlet fluid temperature is in column AU (47)
% Tin_all = data{:, 47};
% 
% % Prepare plot
% figure('Position',[0 0 1200 800]);  % square window
% hold on;
% legend_entries = {};
% 
% % Loop over all mass flows
% for f = 1:length(unique_flows)
%     flow_value = unique_flows(f);
% 
%     % get indices of all rows matching this flow & 420 W case
%     row_idx = find(data.("Mass Flow [g/s]") == flow_value & ...
%                    data.("Target Total Power [W]") == 420);
% 
%     for r = 1:length(row_idx)
%         irow = row_idx(r);
% 
%         Tin = Tin_all(irow);                  % inlet fluid temperature
%         T_blocks = heater_temps(irow, :);     % heater block temps for this row
%         DT_profile = T_blocks - Tin;          % ΔT = block temp - inlet fluid temp
% 
%         % Plot ΔT profile
%         plot(point_indices, DT_profile, '-o', 'LineWidth', 1.5);
%         legend_entries{end+1} = sprintf('%.2f g/s | %.0f W', ...
%             flow_value, data.("Target Total Power [W]")(irow));
%     end
% end
% 
% xlabel('Heater Block ID');
% ylabel('\DeltaT [^\circC] (Block Temp - Inlet Temp)');
% title(sprintf(['ΔT Profiles for Variable Mass Flows (Dry-out Testing Prototype)' ...
%     '\n P = 420 W | T_{in_{evap}} = %.0f\\circC | P_{in_{evap}} = %.0f bar | I.D. = %.2f mm'], ...
%     -15, 24, D*1e3));
% grid on;
% legend(legend_entries, 'Location', 'bestoutside');
% 
% xlim([1 36]);
% xticks(1:36);
% 
% % Watermark
% text(0.99, 0.01, 'Sara Memushaj', 'Units', 'normalized', ...
%     'HorizontalAlignment', 'right', 'FontSize', 8, 'FontAngle', 'italic', ...
%     'Color', [0.5 0.5 0.5]);
