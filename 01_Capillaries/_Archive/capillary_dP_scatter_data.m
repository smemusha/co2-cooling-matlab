% Data file
fileNames = {'2025.02.05_OB_1.1mm_4160mm_Straight.csv'}; 

% Time ranges of data collected
timeRanges = {... 
    [datetime('2025/02/05 10:39:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/02/05 10:44:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'); 
     datetime('2025/02/05 10:51:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/02/05 10:56:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
     datetime('2025/02/05 11:05:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/02/05 11:10:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
     datetime('2025/02/05 11:18:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS'), datetime('2025/02/05 11:23:00.000', 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS')]
};

% Selected time range to plot
selectedRangeIndex = 2;

% Depending on the index above we adjust the mass flow rate
m_dot = 3.5; % mass flow rate of CO2 (g/s)
% m_1 = 4.5
% m_2 = 3.5
% m_3 = 2.5
% m_4 = 1.8

% Desired dP and allowable deviation
referencePressure = 6.9; % bar
pressureLower = referencePressure * 0.98;
pressureUpper = referencePressure * 1.02;

% Capillary information
No_cap = 1; % capillary index
ID_cap = 1.10; %mm
L_cap = 4160; %mm

% Loop over file names
for i = 1:length(fileNames)
   
    data = readtable(fileNames{i}, 'VariableNamingRule', 'preserve');
    
    % Extraction of necessary columns
    timestamps = datetime(data{:, 'Year/Month/Day Hour:Minute:Second.Millisecond'}, 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
    pressure_diff = data{:, 'CO2_COS_F:@CS0f_M0_DP1050.PosSt'};
    
    % Filtering data
    validIndices = (timestamps >= timeRanges{i}(selectedRangeIndex,1) & timestamps <= timeRanges{i}(selectedRangeIndex,2));
    
    if any(validIndices)
        figure; hold on; grid on;
        
        % Plot of dP
        plot(timestamps(validIndices), pressure_diff(validIndices), 'o', 'DisplayName', sprintf('Capillary #%.0f Experimental Data', No_cap));
        
        % Plot desired dP
        yline(referencePressure, '--r', sprintf('%.2f bar', referencePressure), 'LineWidth', 2, 'LabelVerticalAlignment', 'middle', 'LabelHorizontalAlignment', 'right', 'DisplayName', 'Target dP');
        
        % Plot of allowable deviation
        xLimits = xlim;
        fill([xLimits fliplr(xLimits)], [pressureLower pressureLower pressureUpper pressureUpper], 'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none', 'DisplayName', 'Acceptable Fluctuation Range');
        
        xlabel('Time');
        ylabel('Pressure Difference (dP)');
        title(sprintf('Pressure Difference Data over Time - Capillary #%.0f \nID = %.2f mm | L = %.0f mm | MF = %.2f g/s', No_cap, ID_cap, L_cap, m_dot));
        legend('show', 'Location', 'best');
    end
end
