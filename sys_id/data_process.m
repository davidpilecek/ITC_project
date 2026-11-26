%%
clc;clear;close all;

V0 = 0.304;
V200 = 0.431;

Vmax = -1.15;
Vmin = -0.24;

% kg_per_mV = 0.2/abs(V200 - V0);
g_per_mV = 0.965;

max_t =  abs(Vmax - Vmin) * g_per_mV

max_rpm = 157086/7;
max_rad_s = max_rpm * 2*pi /60;

max_t_calc = 1.5715e-06 * max_rad_s ^ 2 / 9.81

sd = readtable('d4/RL0028.CSV');
rc = readtable('d4/log42.csv');

figure
plot(rc.LeftLoadCell_mV_)
figure
rpm = sd.rl_erpm/7;

omega = rpm *2*pi /60;
omega_2 = omega .^2;

plot(omega)
kf = 1.5715e-06;

thrust = omega_2 * kf / 9.81;
figure
plot(thrust)

%% Thrust data prep
clc; clear; close all;
%%
% Configuration
Fs = 20;                   % Resampling frequency [Hz]
outlierWindow = 21;        % Moving median window [samples]
motorPoles = 7;            % ESC eRPM / mechanical RPM divisor

% Load data
rc = readtable('d2/log4.csv');
sd = readtable('d2/RL0019.csv');

% Trim measurements
rc = rc(751:end-301, :);
sd = sd(1:end-5, :);

t = rc.Time_s_ - rc.Time_s_(1);
thrust = -rc.Thrust_kgf_;
thrust = thrust - thrust(1);
rpmOptical = rc.MotorOpticalSpeed_RPM_;

time_sd = sd.time_ms - sd.time_ms(1);
time_sd = time_sd / 1000;
dshot = sd.rl_dshot;
% dshot = sd.rl_dshot / 3200;

figure
plot(time_sd, dshot)
hold on

plot(t, thrust)

% figure;
% scatter(rpmOptical, thrust, 5, 'filled');
% xlabel('Angular velocity (rad/s)');
% ylabel('Thrust (kgf)');
% grid on;

%% Sort and resample
% Ensure all signals remain aligned
[t, idx] = sort(t);

thrust = thrust(idx);
rpmOptical = rpmOptical(idx);

% Remove duplicate timestamps
[t, idx] = unique(t, 'stable');
thrust = thrust(idx);
rpmOptical = rpmOptical(idx);

% Uniform time vector
tUniform = (t(1):1/Fs:t(end)).';

% Interpolate signals
thrustUniform = interp1(t, thrust, tUniform, 'linear');
rpmOpticalUniform = interp1(t, rpmOptical, tUniform, 'linear');

rpm = rpmOpticalUniform;
omega = rpm * 2*pi / 60;

fprintf('Total samples: %d\n', numel(rpm));
fprintf('Unique RPM values: %d\n', numel(unique(rpm)));
fprintf('Duplicate values: %d\n', numel(rpm) - numel(unique(rpm)));


%% Torque data prep
clc; clear; close all;

% Configuration
Fs = 20;                   % Resampling frequency [Hz]
outlierWindow = 21;        % Moving median window [samples]
motorPoles = 7;            % ESC eRPM / mechanical RPM divisor

% Load data
rc = readtable('d3/log1.csv');
sd = readtable('d3/RL0020.csv');

plot(-rc.Torque_N_m_)
% figure
% 
% plot(sd.rl_erpm)


% Trim measurements
rc(1:307,:) = [];
rc(end - 365:end,:) = [];

sd(1:75,:) = [];
sd(end - 28:end,:) = [];

% Extract signals
torque = -rc.Torque_N_m_;
torque = torque - torque(1);

erpm = sd.rl_erpm / 7;
t = rc.Time_s_ - rc.Time_s_(1);

figure;
scatter(t, torque, 5, 'filled');
xlabel('Time');
ylabel('Torque');
grid on;

figure;
plot(erpm);
% xlabel('Angular velocity (rad/s)');
% ylabel('Thrust (kgf)');
grid on;

%

% [t, idx] = sort(t);
% 
% torque = torque(idx);

% erpm = erpm(idx);

% Remove duplicate timestamps
% [t, idx] = unique(t, 'stable');
% torque = torque(idx);
% rpm = erpm(idx);

% Uniform time vector
tUniform = (t(1):1/Fs:t(end)).';

% Interpolate signals
torqueUniform = interp1(t, torque, tUniform, 'linear');
% Interpolate RPM onto the same uniform time base as the torque signal
% rpmUniform = interp1(t, erpm, tUniform, 'linear');
omega = erpm * 2 * pi / 60;

fprintf('Total samples: %d\n', numel(erpm));
fprintf('Unique RPM values: %d\n', numel(unique(erpm)));
fprintf('Duplicate values: %d\n', numel(erpm) - numel(unique(erpm)));

figure
plot(erpm)

%%

valid = isfinite(eRPM_2) & isfinite(torq_uniform);
torqueModel = polyfit(eRPM_2(valid), torq_uniform(valid), 1)
torquePredicted = polyval(torqueModel, eRPM_2);

display(torqueModel(1))

figure
plot(eRPM_2(valid), torq_uniform(valid), '.', 'DisplayName', 'Measured')
hold on
plot(eRPM_2(valid), torquePredicted(valid), 'LineWidth', 1.5, ...
    'DisplayName', 'Linear fit')
xlabel('Optical RPM^2')
ylabel('Torque [-]')
legend('Location', 'best')
grid on

% Compare measured thrust with the fitted optical-RPM model
figure
plot(t_uniform, torq_uniform, 'DisplayName', 'Measured thrust')
hold on
plot(t_uniform, torquePredicted, 'LineWidth', 1.5, ...
    'DisplayName', 'Model prediction')
xlabel('Time [s]')
ylabel('Torque [-]')
legend('Location', 'best')
grid on

