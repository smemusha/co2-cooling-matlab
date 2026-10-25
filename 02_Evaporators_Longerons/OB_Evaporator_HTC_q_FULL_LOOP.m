%% PARAMETRIC STUDY: xLongLoop + Vapor Quality Profile along Longeron

%%
clear
clc

% REFPROP fluid
fld = 'CO2';

% Mass flow range [g/s]
mass_flows = 1.8:0.2:4.2;

% Capillary properties
L_total = 3400e-3;     % m
D_c_in = 1.10;         % mm
T_inlet_cap = -40;     % °C (capillary inlet)
P_cap_inlet = 30;      % bar (capillary inlet pressure)

% Longeron geometry & heat segments
segments = {
    struct('L', 735e-3, 'D', 2.5e-3, 'Q', 210);
    struct('L', 100e-3, 'D', 2.5e-3, 'Q', 0);
    struct('L', 735e-3, 'D', 2.5e-3, 'Q', 210);
    struct('L', 200e-3, 'D', 2.5e-3, 'Q', 0);
    struct('L', 2700e-3, 'D', 4.2e-3, 'Q', 10)
};

segment_labels = {
    {'Heated Section 1', '(210W)'};
    {'Turn'};
    {'Heated Section 2', '(210W)'};
    {'Connection'};
    {'Exhaust Line', '(10W)'}
};

Ep_Ti = 1.1e-6; % Titanium roughness

% Capillary outlet calculations
[deltaP_values, phase_states, T_cap_out] = FUNCTION_capillary_sizing_MF_dP(...
    L_total, D_c_in, T_inlet_cap, P_cap_inlet, mass_flows);

Pin_longeron = P_cap_inlet - deltaP_values;

% Segment x-positions
segment_starts = 0;
for s = 1:length(segments)
    segment_starts(end+1) = segment_starts(end) + segments{s}.L;
end

% Initialize
xLongLoop_values = zeros(size(mass_flows));
T_longeron_inlets = zeros(size(mass_flows));
P_out_longeron = zeros(size(mass_flows));
DP_longeron = zeros(size(mass_flows));
all_profiles = cell(size(mass_flows));
all_positions = cell(size(mass_flows));
labels = cell(size(mass_flows));

for k = 1:length(mass_flows)
    m_dot = mass_flows(k) * 1e-3;
    P = Pin_longeron(k);
    P_start = P;
    T_in = T_cap_out(k);
    H = refpropm('H', 'T', T_in + 273.15, 'P', P * 1e2, fld);
    T_longeron_inlets(k) = T_in;

    x_profile = [];
    position_profile = [];
    x_pos = 0;

    for s = 1:length(segments)
        seg = segments{s};
        D = seg.D;
        A = pi * (D/2)^2;
        P_e = pi * D;
        P_heated = 0.5 * P_e;
        MFLX = m_dot / A;
        HFLX = seg.Q / (seg.L * P_heated);
        N_steps = ceil(seg.L / 0.005);
        dx = seg.L / N_steps;

        for i = 1:N_steps
            dq_step = seg.Q * (dx / seg.L);
            dh = dq_step / m_dot;
            [dP, HTC, VQ, ~, ~, ~] = dPandHTC(fld, P, H, MFLX, HFLX, D, A, P_heated, Ep_Ti, 0, 0);
            VQ = min(max(VQ, 0), 0.999);
            H = H + dh;
            P = P - dP * dx;

            x_profile(end+1) = VQ;
            position_profile(end+1) = x_pos;
            x_pos = x_pos + dx;
        end
    end

    xLongLoop_values(k) = VQ;
    P_out_longeron(k) = P;
    DP_longeron(k) = P_start - P;
    all_profiles{k} = x_profile;
    all_positions{k} = position_profile;
    labels{k} = sprintf('%.2f g/s', mass_flows(k));

    fprintf('ṁ = %.2f g/s → T_in = %.5f °C → P_in = %.2f bar → ΔP_cap = %.4f → ΔP_longeron = %.4f → x_out = %.4f\n', ...
        mass_flows(k), T_in, Pin_longeron(k), deltaP_values(k), DP_longeron(k), VQ);
end

%% Plot 1: Vapor Quality Profiles
figure('Position',[0 0 1200 900]);
hold on;
grid on;

for i = 1:length(all_profiles)
    plot(all_positions{i}, all_profiles{i}, 'LineWidth', 1.5);
end
for i = 2:length(segment_starts)-1
    xline(segment_starts(i), '--k', 'LineWidth', 1);
end
for i = 1:length(segments)
    xpos = (segment_starts(i) + segment_starts(i+1)) / 2;
    text(xpos, 0.365, segment_labels{i}, ...
        'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
end

xlabel('Axial Position [m]');
ylabel('Vapor Quality (x)');
title(sprintf('Vapor Quality Profiles Along Longeron Loop\n T_{in_{cap}} = %.0f\\circC | P_{in_{cap}} = %.0f bar | I.D. = %.2f mm | L_{cap} = %.0f mm | Ep_{Ti} = %.1f μm', T_inlet_cap, P_cap_inlet, D_c_in, L_total*1e3, Ep_Ti*1e6));
legend(labels, 'Location', 'best');
% ylim([0 0.38]); yticks(0:0.02:0.38);
% xlim([0 4.5]); xticks(0:0.25:4.5);
text(0.99, 0.03, 'Sara Memushaj', 'Units', 'normalized', ...
    'HorizontalAlignment', 'right', 'FontSize', 7, 'FontAngle', 'italic', ...
    'Color', [0.5 0.5 0.5]);

%% Plot 2: xLongLoop vs ΔP
figure('Position',[0 0 1200 900]);
hold on;

plot(deltaP_values, xLongLoop_values, '-o', 'LineWidth', 1.5);
grid on;
xlabel('ΔP across capillary [bar]');
ylabel('Vapor Quality at Longeron Outlet');
title(sprintf('Vapor Quality after Longeron Loop for Different Mass Flows\n T_{in_{cap}} = %.0f\\circC | P_{in_{cap}} = %.0f bar | I.D. = %.2f mm | L_{cap} = %.0f mm | Ep_{Ti} = %.1f μm', T_inlet_cap, P_cap_inlet, D_c_in, L_total*1e3, Ep_Ti*1e6));
% ylim([0.31 0.35]);
for i = 1:length(mass_flows)
    text(deltaP_values(i), xLongLoop_values(i) + 0.002, ...
        sprintf('ṁ = %.2f g/s', mass_flows(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 9);
end
text(0.99, 0.03, 'Sara Memushaj', 'Units', 'normalized', ...
    'HorizontalAlignment', 'right', 'FontSize', 7, 'FontAngle', 'italic', ...
    'Color', [0.5 0.5 0.5]);

%% Plot 3: ΔP_longeron vs ΔP_capillary
figure('Position',[0 0 1200 900]);
hold on;
plot(deltaP_values, DP_longeron, '-s', 'LineWidth', 1.5,'Color','r');
grid on;
xlabel('ΔP across capillary [bar]');
ylabel('ΔP across longeron [bar]');
title(sprintf('Pressure Drop across Longeron vs Capillary\n T_{in_{cap}} = %.0f\\circC | P_{in_{cap}} = %.0f bar | I.D. = %.2f mm | L_{cap} = %.0f mm | Ep_{Ti} = %.1f μm', T_inlet_cap, P_cap_inlet, D_c_in, L_total*1e3, Ep_Ti*1e6));
% ylim([0.36 0.50]);
for i = 1:length(mass_flows)
    text(deltaP_values(i), DP_longeron(i) + 0.002, ...
        sprintf('ṁ = %.2f g/s', mass_flows(i)), 'HorizontalAlignment', 'center', 'FontSize', 9);
    text(deltaP_values(i), DP_longeron(i) + 0.007, ...
        sprintf('T_{in_{long.}}%.4f\\circC', T_cap_out(i)), 'HorizontalAlignment', 'center', 'FontSize', 9);
end
text(0.99, 0.03, 'Sara Memushaj', 'Units', 'normalized', ...
    'HorizontalAlignment', 'right', 'FontSize', 7, 'FontAngle', 'italic', ...
    'Color', [0.5 0.5 0.5]);
