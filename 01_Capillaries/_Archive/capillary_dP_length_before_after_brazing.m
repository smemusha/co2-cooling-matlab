%% CAPILLARY TESTING RESULTS - MAPPING DP / LENGTH (B180)
% Quadratic (parabolic) ΔP–Length curves per capillary
% Trendlines include and are plotted from (0,0)
% Step-based mean ΔP per length
% ṁ = 4.14 g/s

%% Necessary paths for libraries

% Work PC ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% addpath('C:\Program Files\Matlab\R2023b')
% addpath(genpath('C:\Program Files (x86)\REFPROP'))
% addpath(genpath('C:\Users\smemusha\cernbox\WINDOWS\Desktop\CoBra Master'))
% addpath(genpath('C:\Users\smemusha\cernbox\WINDOWS\Desktop\ITk\Capilaries\Measurements'))

% Personal PC ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% addpath('C:\Program Files\Matlab\R2023b')
% addpath(genpath('C:\Program Files (x86)\REFPROP'))
% addpath(genpath('C:\Users\smemusha\cernbox\WINDOWS\Desktop\CoBra Master'))
% addpath(genpath('C:\Users\smemusha\cernbox\WINDOWS\Desktop\ITk\Capilaries\Measurements'))

%% CSV files (each data line coresponds to a capillary length)
data1 = readtable('15.12.2025_COS_SS_OB_4000mm_1.1_OD.csv','VariableNamingRule','preserve');
data2 = readtable('17.12.2025_COS_SS_OB_3900mm_1.1_OD.csv','VariableNamingRule','preserve');
data3 = readtable('18.12.2025_COS_SS_OB_3800mm__3700mm_1.1_OD.csv','VariableNamingRule','preserve');
data4 = readtable('19.12.2025_COS_SS_OB_3600mm_1.1_OD.csv','VariableNamingRule','preserve');

data5 = readtable('05.01.2026_COS_SS_OB_3500mm_1.1_OD.csv','VariableNamingRule','preserve');
data6 = readtable('07.01.2026_COS_SS_OB_3400mm_1.1_OD.csv','VariableNamingRule','preserve');
data7 = readtable('08.01.2026_COS_SS_OB_3300mm_1.1_OD.csv','VariableNamingRule','preserve');
data8 = readtable('09.01.2026_COS_SS_OB_3200mm_1.1_OD.csv','VariableNamingRule','preserve');

data9 = readtable('12.01.2026_COS_SS_OB_3300_3200mm_1.1_OD_CAP8.csv','VariableNamingRule','preserve');

%% CSV files - After brazing (3200 mm only)
% Kept as separate variables so the original before-brazing data1-data9 are not overwritten.
dataAfter1 = readtable('POB COS Data 11-06-2026 Capillary-01 Flow Scan.csv', 'VariableNamingRule', 'preserve');
dataAfter2 = readtable('POB COS Data 12-06-2026 Capillary-02 Flow Scan.csv', 'VariableNamingRule', 'preserve');
dataAfter3 = readtable('POB COS Data 12-06-2026 Capillary-03 Flow Scan.csv', 'VariableNamingRule', 'preserve');

%% Time ranges (each array = one capillary)

% Capillary No.6 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
timeRanges1 = [...
    datetime('2025/12/15 14:35:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/15 14:40:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/12/17 15:05:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/17 15:10:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/12/18 11:12:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/18 11:17:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/12/18 15:10:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/18 15:15:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/12/19 15:30:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/19 15:35:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');

    datetime('2026/01/05 15:06:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/01/05 15:11:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/01/07 14:21:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/01/07 14:26:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/01/08 14:31:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/01/08 14:36:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/01/09 14:52:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/01/09 14:57:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
];

% Capillary No.7 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
timeRanges2 = [...
    datetime('2025/12/15 15:10:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/15 15:15:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/12/17 15:45:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/17 15:50:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/12/18 11:30:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/18 11:35:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/12/18 15:40:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/18 15:45:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/12/19 15:45:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/19 15:50:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');

    datetime('2026/01/05 15:26:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/01/05 15:31:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/01/07 14:40:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/01/07 14:45:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/01/08 14:55:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/01/08 15:00:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/01/09 15:13:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/01/09 15:18:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
];

% Capillary No.8 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
timeRanges3 = [...
    datetime('2025/12/15 15:25:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/15 15:30:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/12/17 16:05:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/17 16:10:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/12/18 11:45:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/18 11:50:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/12/18 16:05:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/18 16:10:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2025/12/19 16:00:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/12/19 16:05:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');

    datetime('2026/01/05 15:40:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/01/05 15:45:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/01/07 15:05:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/01/07 15:10:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');

    datetime('2026/01/12 10:20:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/01/12 10:25:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
    datetime('2026/01/12 14:43:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/01/12 14:48:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
];

%% Time ranges - After brazing (3200 mm only)

% Capillary No.6 - After brazing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
timeRanges1_after = [...
    datetime('2026/06/11 16:08:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/11 16:13:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
];

% Capillary No.7 - After brazing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
timeRanges2_after = [...
    datetime('2026/06/12 10:14:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/12 10:19:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
];

% Capillary No.8 - After brazing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
timeRanges3_after = [...
    datetime('2026/06/12 14:41:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS'), datetime('2026/06/12 14:46:00.000','InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
];

%% Length mapping
L_start = 4000;   % mm
dL      = 100;    % mm per row (decrease)

%% Quadratic trendline order
polyOrder = 2;

%% SCADA tags
tagTime = 'Year/Month/Day Hour:Minute:Second.Millisecond';
tagDP   = 'CO2_COS_F:@CS0f_M0_DP1050.PosSt';

%% Time & DP extraction from all files
[t1,dp1] = extractTimeAndDP(data1,tagTime,tagDP);
[t2,dp2] = extractTimeAndDP(data2,tagTime,tagDP);
[t3,dp3] = extractTimeAndDP(data3,tagTime,tagDP);
[t4,dp4] = extractTimeAndDP(data4,tagTime,tagDP);
[t5,dp5] = extractTimeAndDP(data5,tagTime,tagDP);
[t6,dp6] = extractTimeAndDP(data6,tagTime,tagDP);
[t7,dp7] = extractTimeAndDP(data7,tagTime,tagDP);
[t8,dp8] = extractTimeAndDP(data8,tagTime,tagDP);
[t9,dp9] = extractTimeAndDP(data9,tagTime,tagDP);

tAll  = {t1,t2,t3,t4,t5,t6,t7,t8,t9};
dpAll = {dp1,dp2,dp3,dp4,dp5,dp6,dp7,dp8,dp9};

% After brazing data extraction
[tAfter1,dpAfter1] = extractTimeAndDP(dataAfter1,tagTime,tagDP);
[tAfter2,dpAfter2] = extractTimeAndDP(dataAfter2,tagTime,tagDP);
[tAfter3,dpAfter3] = extractTimeAndDP(dataAfter3,tagTime,tagDP);

tAfterAll  = {tAfter1,tAfter2,tAfter3};
dpAfterAll = {dpAfter1,dpAfter2,dpAfter3};

%% Average dP per length step per capillary
[L6s,dP6s] = processCapillarySteps(timeRanges1,tAll,dpAll,L_start,dL);
[L7s,dP7s] = processCapillarySteps(timeRanges2,tAll,dpAll,L_start,dL);
[L8s,dP8s] = processCapillarySteps(timeRanges3,tAll,dpAll,L_start,dL);

% Average dP after brazing at 3200 mm only
L_after = 3200;  % mm
[L6s_after,dP6s_after] = processCapillarySteps(timeRanges1_after,tAfterAll,dpAfterAll,L_after,dL);
[L7s_after,dP7s_after] = processCapillarySteps(timeRanges2_after,tAfterAll,dpAfterAll,L_after,dL);
[L8s_after,dP8s_after] = processCapillarySteps(timeRanges3_after,tAfterAll,dpAfterAll,L_after,dL);

%% ================= THEORETICAL ΔP vs LENGTH =================

% --- Theory parameters (match experiment) ---
fld = 'CO2';
T_inlet = -40;             % °C
P_inlet = 20;              % bar
m_dot   = 4.14;            % g/s
D_c_in  = 1.10;            % mm

Ep_Ti_micro = 3.3;         % μm
Ep_Ti = Ep_Ti_micro*1e-6;  % m

section_length = 0.5e-2;   % m  (same resolution as experiment)
L_total = 4.0;             % m

% --- Geometry & mass flux ---
A_cap = pi*((D_c_in*1e-3)^2)/4;
MFLX  = (m_dot*1e-3)/A_cap;

% --- Inlet enthalpy ---
H = refpropm('H','T',T_inlet+273.15,'P',P_inlet*1e2,fld);

% --- Discretization ---
num_sections = ceil(L_total/section_length);

% --- Allocate ---
P_th  = zeros(1,num_sections+1);
dP_th = zeros(1,num_sections);
x_th  = zeros(1,num_sections);
L_th  = zeros(1,num_sections);

P_th(1) = P_inlet;

% --- March along capillary ---
for i = 1:num_sections

    % Phase at section inlet
    [~,~,x_th(i)] = refpropm('TDQ','P',P_th(i)*1e2,'H',H,fld);

    % Pressure gradient (bar/m)
    if x_th(i)<=0 || x_th(i)>=1
        dP_per_m = DarcyWeisbach( ...
            fld, P_th(i), H, MFLX, D_c_in*1e-3, A_cap, Ep_Ti);
    else
        dP_per_m = FriedelCorrelation( ...
            fld, P_th(i), x_th(i), MFLX, D_c_in*1e-3, A_cap);
    end

    % Integrate
    dP_th(i) = dP_per_m * section_length;

    % Update pressure
    P_th(i+1) = P_th(i) - dP_th(i);

    % Length (mm)
    L_th(i) = i * section_length * 1e3;
end

% --- Cumulative ΔP ---
dP_th_cum = cumsum(dP_th);

%% ================= EXPORT: dP PER LENGTH (EXPERIMENT + THEORY) =================
% Exports experimental step-based dP per length for each capillary
% and theoretical cumulative dP on the same length grid.
% Output format: tab-delimited .txt

% ----- Output directory -----
outDir = 'C:\Users\smemusha\cernbox\WINDOWS\Desktop\ITk\Capilaries\Measurements\Interalloy batch\Mapping';
if ~exist(outDir,'dir')
    mkdir(outDir);
end

% ----- Common length grid (mm) -----
L_min = min([L6s(:); L7s(:); L8s(:)], [], 'omitnan');
L_max = max([L6s(:); L7s(:); L8s(:)], [], 'omitnan');
L_common = (L_max:-dL:L_min)';   % mm

% ----- Map experimental dP onto common grid -----
dP6_common = nan(size(L_common));
dP7_common = nan(size(L_common));
dP8_common = nan(size(L_common));

[tf,loc] = ismember(L6s(:), L_common);
dP6_common(loc(tf)) = dP6s(tf);

[tf,loc] = ismember(L7s(:), L_common);
dP7_common(loc(tf)) = dP7s(tf);

[tf,loc] = ismember(L8s(:), L_common);
dP8_common(loc(tf)) = dP8s(tf);

% ----- Interpolate theoretical cumulative dP onto same grid -----
% Theory vectors available:
%   L_th      [mm]
%   dP_th_cum [bar]
dP_th_common = interp1( ...
    [0; L_th(:)], ...
    [0; dP_th_cum(:)], ...
    L_common, ...
    'linear', 'extrap');

% ----- After-brazing projection onto same grid -----
% Only 3200 mm was measured after brazing, so the projection is a line
% passing through (0,0) and the measured 3200 mm point.
dP6_after_common = projectAfterBrazing(L6s_after,dP6s_after,L_common);
dP7_after_common = projectAfterBrazing(L7s_after,dP7s_after,L_common);
dP8_after_common = projectAfterBrazing(L8s_after,dP8s_after,L_common);

% ----- Build export table -----
dP_per_length_export = table( ...
    L_common, ...
    dP6_common, ...
    dP7_common, ...
    dP8_common, ...
    dP6_after_common, ...
    dP7_after_common, ...
    dP8_after_common, ...
    dP_th_common, ...
    'VariableNames', { ...
        'Length_mm', ...
        'CapillaryNo6_BeforeBrazing_dP_bar', ...
        'CapillaryNo7_BeforeBrazing_dP_bar', ...
        'CapillaryNo8_BeforeBrazing_dP_bar', ...
        'CapillaryNo6_AfterBrazing_projected_dP_bar', ...
        'CapillaryNo7_AfterBrazing_projected_dP_bar', ...
        'CapillaryNo8_AfterBrazing_projected_dP_bar', ...
        'Theory_dP_bar' });

% ----- Write .txt file -----
writetable( ...
    dP_per_length_export, ...
    fullfile(outDir, 'dP_per_length_experiment_before_after_brazing_and_theory.txt'), ...
    'Delimiter', '\t', ...
    'FileType', 'text');


%% Plot
figure; hold on; grid on;
colors = lines(3);

plotCapillary(L6s,dP6s,'Capillary No.6 - Before brazing',colors(1,:),polyOrder);
plotCapillary(L7s,dP7s,'Capillary No.7 - Before brazing',colors(2,:),polyOrder);
plotCapillary(L8s,dP8s,'Capillary No.8 - Before brazing',colors(3,:),polyOrder);

% --- After-brazing data and projected trendlines ---
plotCapillaryAfterProjection(L6s_after,dP6s_after,'Capillary No.6 - After brazing',colors(1,:));
plotCapillaryAfterProjection(L7s_after,dP7s_after,'Capillary No.7 - After brazing',colors(2,:));
plotCapillaryAfterProjection(L8s_after,dP8s_after,'Capillary No.8 - After brazing',colors(3,:));

% --- Theoretical curve ---
plot(L_th, dP_th_cum, 'k--', 'LineWidth', 2.2, ...
    'DisplayName','Theory (Darcy + Friedel)');

xlabel('Capillary Length (mm)');
ylabel('Pressure Drop (bar)');
title('Interalloy Capillaries 6, 7 and 8 (Before and After Brazing) - Pressure Drop vs Length, m = 4.14 g/s');
xlim([3200 4000]);
xticks(3200:100:4000);
ylim([6 10]);
yticks(6:0.5:10);
legend('Location','best');
hold off;

%% Watermark (author)
ax = gca;
text( ...
    ax.XLim(1) + 0.01*range(ax.XLim), ...
    ax.YLim(1) + 0.02*range(ax.YLim), ...
    'Sara Memushaj', ...
    'FontSize', 8, ...
    'Color', [0.4 0.4 0.4], ...
    'Interpreter', 'none');

%% Local Functions
function [t,dp] = extractTimeAndDP(data,tagTime,tagDP)
t  = datetime(data{:,tagTime},'InputFormat','yyyy/MM/dd HH:mm:ss.SSS');
dp = data{:,tagDP};
end

function [L_steps,dP_steps] = processCapillarySteps(timeRanges,tAll,dpAll,L_start,dL)
nSteps = size(timeRanges,1);
L_steps = nan(nSteps,1);
dP_steps = nan(nSteps,1);

for i = 1:nSteps
    Lc = L_start - dL*(i-1);
    dP_all = [];
    for f = 1:numel(tAll)
        m = tAll{f}>=timeRanges(i,1) & tAll{f}<=timeRanges(i,2);
        dP_all = [dP_all; dpAll{f}(m)];
    end
    L_steps(i) = Lc;
    dP_steps(i) = mean(dP_all,'omitnan');
end

ok = ~isnan(dP_steps);
L_steps = L_steps(ok);
dP_steps = dP_steps(ok);
end

function plotCapillary(Ls,dPs,name,col,polyOrder)
scatter(Ls,dPs,35,'filled','MarkerFaceColor',col,'MarkerEdgeColor',col,...
    'HandleVisibility','off');

L_fit = [0; Ls(:)];
dP_fit = [0; dPs(:)];
coeff = polyfit(L_fit,dP_fit,polyOrder);

xfit = linspace(0,max(Ls),300);
yfit = polyval(coeff,xfit);

plot(xfit,yfit,'Color',col,'LineWidth',1.8,...
    'DisplayName',[name ' (trendline)']);
end

function dP_projected = projectAfterBrazing(Ls,dPs,L_common)
dP_projected = nan(size(L_common));

ok = ~isnan(Ls) & ~isnan(dPs);
if ~any(ok)
    return
end

% One measured point is available after brazing, at 3200 mm.
% Projection assumes dP scales linearly with length and passes through (0,0).
slope = mean(dPs(ok)./Ls(ok),'omitnan');
dP_projected = slope .* L_common;
end

function plotCapillaryAfterProjection(Ls,dPs,name,col)
if isempty(Ls) || isempty(dPs)
    return
end

scatter(Ls,dPs,45,'d','filled','MarkerFaceColor',col,'MarkerEdgeColor',col,...
    'HandleVisibility','off');

ok = ~isnan(Ls) & ~isnan(dPs);
if ~any(ok)
    return
end

% One measured point is available after brazing, at 3200 mm.
% Projection assumes dP scales linearly with length and passes through (0,0).
slope = mean(dPs(ok)./Ls(ok),'omitnan');
xfit = linspace(0,4000,300);
yfit = slope .* xfit;

plot(xfit,yfit,'--','Color',col,'LineWidth',1.8,...
    'DisplayName',[name ' (projected trendline)']);
end

