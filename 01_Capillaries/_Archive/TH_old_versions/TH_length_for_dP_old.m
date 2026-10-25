%% CAPILLARY LENGTH FOR TARGET ΔP — based on example style

clear; clc;

%----------------------------------------------------------------------
% Constants
fld = 'CO2';
T_inlet = -45;                                              % °C
P_inlet = 50;                                               % bar
H = refpropm('H','T',T_inlet+273.15,'P',P_inlet*1e2,fld);   % J/kg (REFPROP P in kPa)
m_dot = 1.89;                                               % g/s
dP_dis = 8.75;                                              % target pressure drop (bar)
D_c_in = 0.76;                                              % mm

%----------------------------------------------------------------------
% Material properties
Ep_Ti_micro = 3.3;                % μm
Ep_Ti = Ep_Ti_micro * 1e-6;       % m

% Section parameters
section_length = 0.5e-2;          % m
max_sections   = 20000;           % safety limit

% Geometry
A_cap = pi*((D_c_in*1e-3)^2)/4;   % m^2
MFLX  = (m_dot*1e-3)/A_cap;       % kg/m^2/s

%----------------------------------------------------------------------
% Preallocate
T   = zeros(1, max_sections);
rho = zeros(1, max_sections);
x   = zeros(1, max_sections);
dP_per_m = zeros(1, max_sections);          % bar/m from correlation
dP_sec   = zeros(1, max_sections);          % bar per section
P_inlet_section = zeros(1, max_sections+1);
pipe_lengths = zeros(1, max_sections);

% Initial conditions
P_inlet_section(1) = P_inlet;
cumulative_dP = 0;
i = 1;

%----------------------------------------------------------------------
% March along sections until target ΔP reached
while cumulative_dP < dP_dis && i <= max_sections
    % State at start of section
    [T(i), rho(i), x(i)] = refpropm('TDQ','P',P_inlet_section(i)*1e2,'H',H,fld);

    % Get dP/m from correlations
    if x(i) <= 0 || x(i) >= 1
        [dP_per_m(i), ~, ~] = DarcyWeisbach(...
            fld, P_inlet_section(i), H, MFLX, D_c_in*1e-3, A_cap, Ep_Ti);   % bar/m
    else
        [dP_per_m(i), ~] = FriedelCorrelation(...
            fld, P_inlet_section(i), x(i), MFLX, D_c_in*1e-3, A_cap);       % bar/m
    end

    % Convert to bar for this section
    dP_sec(i) = dP_per_m(i) * section_length;
    cumulative_dP = cumulative_dP + dP_sec(i);

    % Update pressure for next section start
    if i < max_sections
        P_inlet_section(i+1) = P_inlet_section(i) - dP_sec(i);
    end

    % Length at this section end
    pipe_lengths(i) = i * section_length;
    i = i + 1;
end

if i == 1
    error('No sections computed.');
end

last_idx = i - 1;

%----------------------------------------------------------------------
% Interpolation in final section
cum_before_last = sum(dP_sec(1:last_idx-1));                % bar
dP_per_m_last   = dP_per_m(last_idx);                       % bar/m
P_before_last   = P_inlet_section(last_idx);                % bar
L_before_last   = (last_idx>1) * pipe_lengths(last_idx-1);  % m

if cumulative_dP > dP_dis && dP_per_m_last > 0
    dP_needed  = dP_dis - cum_before_last;                  % bar
    L_extra    = dP_needed / dP_per_m_last;                 % m
    L_required = L_before_last + L_extra;                   % m
    P_outlet   = P_before_last - dP_needed;                 % bar

    % Build plotting vectors: (0,P_inlet) → ... → (L_required, P_outlet)
    pipe_lengths_plot = [0, pipe_lengths(1:last_idx-1), L_required];
    P_plot            = [P_inlet, P_inlet_section(2:last_idx), P_outlet];
else
    % Exact section boundary or not reached
    L_required = pipe_lengths(last_idx);
    P_outlet   = P_inlet_section(last_idx+1);
    pipe_lengths_plot = [0, pipe_lengths(1:last_idx)];
    P_plot = [P_inlet, P_inlet_section(2:last_idx+1)];
end

%----------------------------------------------------------------------
% Reporting
fprintf('== Capillary Length for Target ΔP ==\n');
fprintf('D_in = %.2f mm | m_dot = %.2f g/s | T_in = %.1f °C | P_in = %.2f bar | Target ΔP = %.2f bar\n', ...
    D_c_in, m_dot, T_inlet, P_inlet, dP_dis);
fprintf('Required length: %.3f m\n', L_required);
fprintf('Outlet pressure at target: %.2f bar\n', P_outlet);

%----------------------------------------------------------------------
% % Plot: Pressure vs Length
% figure; hold on;
% plot(pipe_lengths_plot, P_plot, 'LineWidth', 1.6);
% 
% Psat = refpropm('P','T',T_inlet+273.15,'Q',0,fld)*1e-2; % bar
% yline(Psat, '--', sprintf('P_{sat} = %.2f bar', Psat), 'LineWidth', 1.5);
% 
% xlabel('Length (m)');
% ylabel('Pressure (bar)');
% title(sprintf('Capillary Sizing to Reach ΔP=%.2f bar (D_{in}=%.2f mm, m=%.2f g/s)', ...
%     dP_dis, D_c_in, m_dot));
% grid on;
% xlim([0, pipe_lengths_plot(end)*1.05]);
% ylim([min([P_plot(:); Psat])-0.5, max([P_plot(:); Psat])+0.5]);
