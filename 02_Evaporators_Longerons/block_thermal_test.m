%% THERMAL BLOCK TEST: Longerons & IHRs in 'Aquarium' environment

%% Step 1: Raw data from CSV files
rawData = readtable('raw_data.csv');
calibrationData = readtable('calibration_data.csv');

%% Step 2: Preperatory calculations

% Extract relevant columns from raw data
blockNumber = rawData.BlockNumber;
leadRes = rawData.LeadRes;
heaterRes = rawData.HeaterRes;
timeStart = rawData.TimeStart;
timeStop = rawData.TimeStop;
environT1 = rawData.EnvironT1;
environT2 = rawData.EnvironT2;
environRH1 = rawData.EnvironRH1;
environRH2 = rawData.EnvironRH2;
compressedAirFlow = rawData.CompressedAirFlow;
voltageOhm = rawData.VoltageOhm;
currentmA = rawData.CurrentmA;
probeT1 = rawData.ProbeT1;
probeT2 = rawData.ProbeT2;
probeT3 = rawData.ProbeT3;
probeT4 = rawData.ProbeT4;
tInletCooling = rawData.TInletCooling;
tOutletCooling = rawData.TOutletCooling;
pressureInlet = rawData.PressureInlet;
pressureOutlet = rawData.PressureOutlet;
massFlow = rawData.MassFlow;

% Calculate average environmental temperature and relative humidity
avgEnvT = (environT1 + environT2) / 2;
avgRH = (environRH1 + environRH2) / 2;

% Calculate dew point
avgRH(avgRH == 0) = 1e-6; % Prevent log(0) error
dewPoint = 243.5 * (log(avgRH / 100) + ((17.67 * avgEnvT) / (243.5 + avgEnvT))) / (17.67 - log(avgRH / 100));

% Calculate power
currentA = currentmA / 1000;
power = (voltageOhm - currentA .* heaterRes) .* currentA;

% Calculate average probe temperatures
avgProbeT = (probeT1 + probeT2 + probeT3 + probeT4) / 4;

% Calculate standard deviation of probe temperatures
probeMatrix = [probeT1, probeT2, probeT3, probeT4];
stdProbeT = std(probeMatrix, 0, 2);

% Calculate T_block
totalBlocks = max(blockNumber);
tBlock = tInletCooling + ((tOutletCooling - tInletCooling) / totalBlocks) .* (blockNumber - 1);

% Calculate Delta T
deltaT = avgProbeT - tBlock;

% Calculate Apparent TFM (handling division by zero)
apparentTFM = deltaT ./ (max(power, 1e-6) ./ (pi * 1^2));

%% Step 3: Corrected data based on calibration file

% Extract relevant columns from calibration data
calibrationT1 = calibrationData.T1;
calibrationT2 = calibrationData.T2;
calibrationT3 = calibrationData.T3;
calibrationT4 = calibrationData.T4;
equalizationTemp = calibrationData.EqualizationTemp;

% Ensure blockNumber values are within the correction factor range
blockIndex = min(blockNumber, height(calibrationData));

% Apply correction factors to probe temperatures
correctedT1 = probeT1 - (calibrationT1(blockIndex) - equalizationTemp(blockIndex));
correctedT2 = probeT2 - (calibrationT2(blockIndex) - equalizationTemp(blockIndex));
correctedT3 = probeT3 - (calibrationT3(blockIndex) - equalizationTemp(blockIndex));
correctedT4 = probeT4 - (calibrationT4(blockIndex) - equalizationTemp(blockIndex));

% Calculate corrected average probe temperatures
correctedAvgProbeT = (correctedT1 + correctedT2 + correctedT3 + correctedT4) / 4;

% Calculate corrected standard deviation of probe temperatures
correctedStdProbeT = std([correctedT1, correctedT2, correctedT3, correctedT4], 0, 2);

%% Step 4: Output results in a structured format
% Create results table
results = table(blockNumber, leadRes, heaterRes, timeStart, timeStop, avgEnvT, avgRH, dewPoint, ...
    compressedAirFlow, voltageOhm, currentmA, power, probeT1, probeT2, probeT3, probeT4, ...
    avgProbeT, stdProbeT, tInletCooling, tOutletCooling, tBlock, pressureInlet, ...
    pressureOutlet, massFlow, deltaT, apparentTFM, correctedT1, correctedT2, ...
    correctedT3, correctedT4, correctedAvgProbeT, correctedStdProbeT);

% Display the results
disp(results);

% Optionally, write the results to a CSV file
% writetable(results, 'corrected_data.csv', 'Precision', 6);

%% Step 5: Plot Apparent TFM

figure;
bar(blockNumber, apparentTFM, 'FaceColor', [0.2 0.6 1]); % Blue color
xlabel('Block Number');
ylabel('Apparent TFM');
title('Apparent TFM per Block');
grid on;
