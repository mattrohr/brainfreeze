%% Setup Workspace
clear all, close all, clc

format long
%% Import Data
inertialData = importdata('../data/raw/20210408-155327_sensor-orbit_100RPM/IMU_output.txt');
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
% Note: this is a guess, ideally we would want to change recording script or hardware to have a clock, so acuqisitions occur at set intervals
xq = (recordedTime(:,1):samplingPeriod:recordedTime(end))';
interpolatedAcceleration = interp1(recordedTime, recordedAcceleration, xq, 'spline'); % https://www.mathworks.com/help/matlab/ref/interp1.html
figure()
plot(xq, interpolatedAcceleration)
xlabel('time [seconds]')
ylabel('acceleration [m/s^2]')
legend('x', 'y', 'z')

%% Compute FFT
samplingFrequency = 1 / samplingPeriod;
signalLength = length(interpolatedAcceleration);
interpolatedTime = (0:signalLength-1) * samplingPeriod;

signal = interpolatedAcceleration(:,1)';

Y = fft(signal);

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
filteredSignal = filter(Hd.Hd, signal);
figure
plot(interpolatedTime, filteredSignal)
title('Filtered z-acceleration');
xlabel('t [seconds]');
ylabel('y acceleration [m/s^2]');

%% Plot Kinematics
% Camera and Stage
subplot(4,3,1)
title('camera feed')
subplot(4,3,2)
title('position from camera feed')
xlabel('y-position [meters]')
ylabel('z-position [meters]')
subplot(4,3,3)
title('stage simulation')

% X-axis
subplot(4,3,4)
plot(recordedTime, -recordedAcceleration(:,1), 'r')
title('x-axis acceleration')
xlabel('time [seconds]')
ylabel('acceleration [m/s^2]')
subplot(4,3,5)
plot(recordedTime, calculatedXVelocity, 'r')
title('x-axis velocity')
xlabel('time [seconds]')
ylabel('velocity [m/s]')
subplot(4,3,6)
plot(recordedTime, calculatedXDistance, 'r')
title('x-axis position')
xlabel('time [seconds]')
ylabel('distance [m]')

% Y-axis
subplot(4,3,7)
plot(recordedTime, recordedAcceleration(:,2), 'g')
title('y-axis acceleration')
xlabel('time [seconds]')
ylabel('acceleration [m/s^2]')
subplot(4,3,8)
plot(recordedTime, calculatedYVelocity, 'g')
title('y-axis velocity')
xlabel('time [seconds]')
ylabel('velocity [m/s]')
subplot(4,3,9)
plot(recordedTime, calculatedYDistance, 'g')
title('y-axis position')
xlabel('time [seconds]')
ylabel('distance [m]')

% Z-axis
subplot(4,3,10)
plot(recordedTime, recordedAcceleration(:,3), 'b')
title('z-axis velocity')
xlabel('time [seconds]')
ylabel('acceleration [m/s^2]')
subplot(4,3,11)
plot(recordedTime, calculatedZVelocity, 'b')
title('z-axis acceleration')
xlabel('time [seconds]')
ylabel('velocity [m/s]')
subplot(4,3,12)
plot(recordedTime, calculatedZDistance, 'b')
title('z-axis position')
xlabel('time [seconds]')
ylabel('distance [m]')