%% VALVE TEST SETUP RESULTS
% 2023-04-27

clc
clear
close all

dir = pwd;
% cd 'G:\Departments\PH\Groups\DT\PO\Cooling activities\PROJECTS\DEMO\Commissioning\MatlabDataAnalyses\DataAnalysesScripts\';
cd '\\eosproject-smb\eos\project\c\co2-cooling-activities\PROJECTS\DEMO\Commissioning\MatlabDataAnalyses\DataAnalysesScripts'

fld = 'CO2';

RELOAD = 0;
TRIG_BANDWIDTH = 0.5; % Min. % change to account as a valve step
TRIGCHECK_BANDWIDTH = 150; % Min number of data points to prevent double triggers

TimeStamps = {...
    '13-Jul-2023 18:30:00', '13-Jul-2023 19:30:00';...
    '07-Jun-2023 10:35:00', '07-Jun-2023 12:10:00';... % Refrigera 0.1 bar gas
    '07-Jun-2023 14:15:00', '07-Jun-2023 15:25:00';... % Refrigera 0.1 bar liquid
    '13-Jul-2023 16:50:00', '13-Jul-2023 18:20:00';... % Refrigera 0.3 bar transfer line
    '13-Jul-2023 17:17:00', '13-Jul-2023 17:25:00';... % Refrigera 0.3 bar transfer line zoomed
    '08-Jun-2023 15:00:00', '08-Jun-2023 15:30:00';
    };

fld = 'CO2';

x = 5;
Tmin = TimeStamps{x,1};
Tmax = TimeStamps{x,2};

System = 'V1';
label = {'T1PT'; 'T1TT'};
data = DemoRetrieve(System,Tmin,Tmax,label,0,1,1,RELOAD);
Separate

n = length(Time.datetime);

cd(dir);

%% DATA ANALYSIS
rho1 = zeros(n,1);
rho2 = zeros(n,1);

for i = 1:n
    rho1(i) = refpropm('D','T',T1TT2T62.POSST(i)+273.15,'P',T1PT2T62.POSST(i)*100,fld);
    rho2(i) = refpropm('D','T',T1TT2T68.POSST(i)+273.15,'P',T1PT2T68.POSST(i)*100,fld);
end

V1 = 1.2e-3;
V2 = 0.5e-3;

M1 = rho1.*V1.*1000;
M2 = rho2.*V2.*1000;

%% PLOTS
close all

plotdefaults('TextFontSize',14,'AxisFontSize',14,'Font','IBM Plex Sans Text','LineThickness',2.5);

figure
set(gcf,'Units','centimeters','Position',[0 00 29.7 21]);

subplot(3,1,1);
title('(a) Pressures');
hold on
plot(Time.datetime,T1PT2T62.POSST,'DisplayName','Inlet (PT2t62)');
plot(Time.datetime,T1PT2T68.POSST,'DisplayName','Outlet (PT2t68)');
legend('location','best');
grid on 
xlabel('Time');
ylabel('Pressure (bar)');

subplot(3,1,2);
title('(b) Temperatures');
hold on
plot(Time.datetime,T1TT2T62.POSST,'DisplayName','Inlet (TT2t62)');
plot(Time.datetime,T1TT2T68.POSST,'DisplayName','Outlet (TT2t68)');
legend('location','best');
grid on
xlabel('Time');
ylabel('Temperature (°C)');

subplot(3,1,3);
title('(c) Mass');
hold on
plot(Time.datetime,M1,'DisplayName','Inlet (TT2t62)');
plot(Time.datetime,M2,'DisplayName','Outlet (TT2t68)');
legend('location','best');
grid on
xlabel('Time');
ylabel('kg');