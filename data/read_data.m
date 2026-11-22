%% Thrust data prep
clc; clear; close all;

% Load data
imu = readtable('data/imu0.csv');
yaw_gyro = imu.gz_dps;

plot(yaw_gyro)