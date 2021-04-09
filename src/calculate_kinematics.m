%% Setup Workspace
clear all, close all, clc

format long
%% Import Data
inertialData = importdata('../data/raw/20210408-190706_sensor-orbit_100RPM/IMU_output.txt');
recordedTime = (inertialData(:,1) - inertialData(1,1));
recordedAcceleration = inertialData(:, [2:4]) - inertialData(1, [2:4]);
calculatedXVelocity = (cumtrapz(inertialData(:,1), recordedAcceleration(:,1)));
calculatedYVelocity = (cumtrapz(inertialData(:,1), recordedAcceleration(:,2)));
calculatedZVelocity = (cumtrapz(inertialData(:,1), recordedAcceleration(:,3)));
calculatedXDistance = (cumtrapz(inertialData(:,1), calculatedXVelocity));
calculatedYDistance = (cumtrapz(inertialData(:,1), calculatedYVelocity));
calculatedZDistance = (cumtrapz(inertialData(:,1), calculatedZVelocity));

%% Extract sampling period selected during acquisition
readScript = readlines('record_kinematics.py')';
extractLine = readScript(:,53);
extractValue = regexp(extractLine,'\d*','Match');
joinDigits = strjoin(extractValue(:, [1,2]));
replaceDelimiter = strrep(joinDigits, ' ', '.');
samplingPeriod = str2num(replaceDelimiter);

%% Interpolate kinematic data because FFT needs evenly spaced samples
xq = (recordedTime(:,1):samplingPeriod:recordedTime(end))';
interpolatedAcceleration = interp1(recordedTime, recordedAcceleration, xq, 'spline'); % https://www.mathworks.com/help/matlab/ref/interp1.html
figure()
plot(xq, interpolatedAcceleration(:,1), 'r')
hold on
plot(xq, interpolatedAcceleration(:,2), 'g')
plot(xq, interpolatedAcceleration(:,3), 'b')
xlabel('time [seconds]')
ylabel('acceleration [m/s^2]')
legend('x', 'y', 'z')

%% Compute FFT
samplingFrequency = 1 / samplingPeriod;
signalLength = length(interpolatedAcceleration);
interpolatedTime = (0:signalLength-1) * samplingPeriod;

unfilteredXAcceleration = interpolatedAcceleration(:,1)';

Y = fft(unfilteredXAcceleration);

P2 = abs(Y / signalLength);
P1 = P2(1:signalLength / 2 + 1);
P1(2:end-1) = 2 * P1(2:end-1);

frequency = samplingFrequency * (0:(signalLength / 2)) / signalLength;
figure()
plot(frequency,P1)
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

%% Design highpass filter
% minimumorder, FIR, density factor = 20, Fstop = 0.5, Fpass = 1

Hd = load('Hd.mat');
filteredXAcceleration = filter(Hd.Hd, unfilteredXAcceleration);
figure()
%plot(interpolatedTime, filteredAcceleration)
%title('Filtered z-acceleration');
%xlabel('t [seconds]');
%ylabel('y acceleration [m/s^2]');

%% Plot Raw Kinematics
figure()
sgtitle('Raw IMU Kinematics')
% X-axis
subplot(3,3,1)
plot(recordedTime, recordedAcceleration(:,1), 'r')
title('X-axis acceleration')
xlabel('time [seconds]')
ylabel('acceleration [m/s^2]')
subplot(3,3,2)
plot(recordedTime, calculatedXVelocity, 'r')
title('X-axis velocity')
xlabel('time [seconds]')
ylabel('velocity [m/s]')
subplot(3,3,3)
plot(recordedTime, calculatedXDistance, 'r')
title('X-axis position')
xlabel('time [seconds]')
ylabel('distance [m]')

% Y-axis
subplot(3,3,4)
plot(recordedTime, recordedAcceleration(:,2), 'g')
title('Y-axis acceleration')
xlabel('time [seconds]')
ylabel('acceleration [m/s^2]')
subplot(3,3,5)
plot(recordedTime, calculatedYVelocity, 'g')
title('Y-axis velocity')
xlabel('time [seconds]')
ylabel('velocity [m/s]')
subplot(3,3,6)
plot(recordedTime, calculatedYDistance, 'g')
title('Y-axis position')
xlabel('time [seconds]')
ylabel('distance [m]')

% Z-axis
subplot(3,3,7)
plot(recordedTime, recordedAcceleration(:,3), 'b')
title('Z-axis velocity')
xlabel('time [seconds]')
ylabel('acceleration [m/s^2]')
subplot(3,3,8)
plot(recordedTime, calculatedZVelocity, 'b')
title('Z-axis acceleration')
xlabel('time [seconds]')
ylabel('velocity [m/s]')
subplot(3,3,9)
plot(recordedTime, calculatedZDistance, 'b')
title('Z-axis position')
xlabel('time [seconds]')
ylabel('distance [m]')

%% Plot Interpolated Kinematics
figure()
sgtitle('Filtered IMU Kinematics')

% X-Axis
subplot(3,3,1)
unfilteredXAcceleration = interpolatedAcceleration(:,1)';
filteredXAcceleration = filter(Hd.Hd, unfilteredXAcceleration);
filteredXVelocity = -cumtrapz(interpolatedTime', filteredXAcceleration);
filteredXDistance = detrend(cumtrapz(interpolatedTime', filteredXVelocity),2);
plot(interpolatedTime, filteredXAcceleration, 'r')
title('X-axis acceleration')
xlabel('time [seconds]')
ylabel('acceleration [m/s^2]')
subplot(3,3,2)
plot(interpolatedTime, filteredXVelocity, 'r')
title('X-axis velocity')
xlabel('time [seconds]')
ylabel('velocity [m/s]')
subplot(3,3,3)
plot(interpolatedTime, filteredXDistance, 'r')
title('X-axis position')
xlabel('time [seconds]')
ylabel('distance [m]')

% Y-Axis
subplot(3,3,4)
unfilteredYAcceleration = interpolatedAcceleration(:,2)';
filteredYAcceleration = filter(Hd.Hd, unfilteredYAcceleration);
filteredYVelocity = -cumtrapz(interpolatedTime', filteredYAcceleration);
filteredYDistance = detrend(cumtrapz(interpolatedTime', filteredYVelocity),2);
plot(interpolatedTime, filteredYAcceleration, 'g')
title('Y-axis acceleration')
xlabel('time [seconds]')
ylabel('acceleration [m/s^2]')
subplot(3,3,5)
plot(interpolatedTime, filteredYVelocity, 'g')
title('Y-axis velocity')
xlabel('time [seconds]')
ylabel('velocity [m/s]')
subplot(3,3,6)
plot(interpolatedTime, filteredYDistance, 'g')
title('Y-axis position')
xlabel('time [seconds]')
ylabel('distance [m]')

% Z-Axis
subplot(3,3,7)
unfilteredZAcceleration = interpolatedAcceleration(:,3)';
filteredZAcceleration = filter(Hd.Hd, unfilteredZAcceleration);
filteredZVelocity = cumtrapz(interpolatedTime', filteredZAcceleration);
filteredZDistance = detrend(cumtrapz(interpolatedTime', filteredZVelocity),2);
plot(interpolatedTime, filteredXAcceleration, 'b')
title('Z-axis acceleration')
xlabel('time [seconds]')
ylabel('acceleration [m/s^2]')
subplot(3,3,8)
plot(interpolatedTime, filteredZVelocity, 'b')
title('Z-axis velocity')
xlabel('time [seconds]')
ylabel('velocity [m/s]')
subplot(3,3,9)
plot(interpolatedTime, filteredZDistance, 'b')
title('Z-axis position')
xlabel('time [seconds]')
ylabel('distance [m]')

countedPeaks = numel(findpeaks(filteredXDistance(:,30001:end)))
oscillationTime = length(interpolatedTime(:,30001:end))*samplingPeriod;
oscillationFrequency = 1.69688; % from FFT
expectedPeaks = oscillationTime * oscillationFrequency

