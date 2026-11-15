clc;clear;close all;

rc = readtable('d3/log2.csv','HeaderLines',0,'ReadVariableNames',true);
sd = readtable('d3/RL0020.csv','HeaderLines',0,'ReadVariableNames',true);

rc(1:225,:) = [];
rc(end - 439:end,:) = [];

sd(1:66,:) = [];
sd(end - 25:end,:) = [];

rpm = sd.rl_erpm / 7;
rpm = rpm * 2 * pi / 60;
eRPM_2 = rpm .^ 2;

time = rc.Time_s_;
T = -rc.Torque_N_m_(:);

% T = T - mean(T);

Fs = 20;                        % desired sample rate [Hz]
time = time(:);
T = T(:);

[time, idx] = sort(time);
T = T(idx);           % keep measurements paired with timestamps

t = time;

t_uniform = (t(1):1/Fs:t(end)).';
torq_uniform = interp1(t, T, t_uniform, 'linear');

plot(torq_uniform)
hold on

plot(rpm)

%%

% Fit a quadratic thrust model from optical RPM squared
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

%%
clc;clear;close all;

% only log4 has optical RPM 

rc = readtable('d2/log4.csv','HeaderLines',0,'ReadVariableNames',true);
sd = readtable('d2/RL0019.csv','HeaderLines',0,'ReadVariableNames',true);

rc(1:750,:) = [];
rc(end - 300:end,:) = [];

sd(end - 4:end,:) = [];

rpm = sd.rl_erpm / 7;
rpm = rpm * 2 * pi / 60;
eRPM_2 = rpm .^ 2;

thrust = -rc.Thrust_kgf_;

time = rc.Time_s_ - rc.Time_s_(1);

Fs = 20;                        % desired sample rate [Hz]
time = time(:);
thrust = thrust(:);

[time, idx] = sort(time);
thrust = thrust(idx);           % keep measurements paired with timestamps

t = time;
x = thrust;
y = rc.MotorOpticalSpeed_RPM_;

t_uniform = (t(1):1/Fs:t(end)).';
x_uniform = interp1(t, x, t_uniform, 'linear');
y_uniform = interp1(t, y, t_uniform, 'linear');

figure
plot(t_uniform, x_uniform)
hold on
plot(t_uniform, y_uniform)

figure
plot(t_uniform, rpm)
hold on
plot(t_uniform, y_uniform)

legend( "eRPM", "Optical RPM")

%%

% eRPM_2 = y_uniform .^ 2;

% Fit a quadratic thrust model from optical RPM squared
valid = isfinite(eRPM_2) & isfinite(x_uniform);
thrustModel = polyfit(eRPM_2(valid), x_uniform(valid), 1);
thrustPredicted = polyval(thrustModel, eRPM_2);

kf = thrustModel(1) * 9.80665

figure
plot(eRPM_2(valid), x_uniform(valid), '.', 'DisplayName', 'Measured')
hold on
plot(eRPM_2(valid), thrustPredicted(valid), 'LineWidth', 1.5, ...
    'DisplayName', 'Linear fit')
xlabel('Optical RPM^2')
ylabel('Thrust [kgf]')
legend('Location', 'best')
grid on

% Compare measured thrust with the fitted optical-RPM model
figure
plot(t_uniform, x_uniform, 'DisplayName', 'Measured thrust')
hold on
plot(t_uniform, thrustPredicted, 'LineWidth', 1.5, ...
    'DisplayName', 'Model prediction')
xlabel('Time [s]')
ylabel('Thrust [kgf]')
legend('Location', 'best')
grid on

%%

% Get thrust coefficient

% Estimate thrust coefficient for the quadratic RPM model
thrustCoefficient = thrustModel(1);
thrustOffset = thrustModel(2);
fprintf('Thrust coefficient: %.6g kgf/RPM^2\n', thrustCoefficient);
fprintf('Thrust offset: %.6g kgf\n', thrustOffset);

%%
clc;clear;close all;

rc = readtable('d2/log4.csv','HeaderLines',0,'ReadVariableNames',true);
sd = readtable('d2/RL0019.csv','HeaderLines',0,'ReadVariableNames',true);

%%
% bench 2 and 3 with RL0006
% bench 1 with RL0001

bench = readtable('bench3.csv','HeaderLines',0,'ReadVariableNames',true);
sd = readtable('RL0001.csv','HeaderLines',0,'ReadVariableNames',true);

bench(1:1000,:) = [];
bench(end-359:end,:) = [];

sd(1:190,:) = [];
% sd(end-350:end,:) = [];

thrust = bench.Thrust_kgf_;
thrust = lowpass(thrust, 0.3);

torque = bench.Torque_N_m_;
time = bench.Time_s_;
time = time - time(1);

Fs = 20;                        % desired sample rate [Hz]
time = time(:);
thrust = thrust(:);

[time, idx] = sort(time);
thrust = thrust(idx);           % keep measurements paired with timestamps

t = time;
x = thrust;

t_uniform = (t(1):1/Fs:t(end)).';
x_uniform = interp1(t, x, t_uniform, 'linear');

teensy_time = sd.time_ms - sd.time_ms(1);
teensy_time = teensy_time / 1000;

rl_erpm_tru = sd.rl_erpm / 7;
teensy_eRPM2 = rl_erpm_tru .^ 2;

teensy_eRPM_scaled = teensy_eRPM2 / 6.32^11;
teensy_optical = sd.optical_rpm;

teensy_dshot = sd.rl_dshot .^ 2;
teensy_dshot = teensy_dshot / 1000000;

% figure
% plot(t_uniform, x_uniform);
% hold on
% plot(t_uniform, teensy_eRPM_scaled);
% legend("thrust", "eRPM")

% t = t_uniform(:);
% a = double(x_uniform(:));
% b = double(teensy_eRPM2(:));
% assert(numel(t) == numel(a) && numel(a) == numel(b), ...
%     'Both signals must match the shared time vector.');
% inWindow = t >= 5 & t <= 18;
% valid = inWindow & isfinite(a) & isfinite(b) & b ~= 0;
% assert(any(valid), 'No valid signal pairs between 5 and 18 seconds.');
% meanRatio = mean(a(valid) ./ b(valid));
% fprintf('Mean signal1/signal2 = %.6g (%d of %d samples used)\n', ...
%     meanRatio, nnz(valid), nnz(inWindow));

max(thrust)
%%

clc;clear;close all;

% bench 2 and 3 with RL0006
% bench 1 with RL0001

rc = readtable('RL0002.csv','HeaderLines',0,'ReadVariableNames',true);
sd = readtable('RL0002.csv','HeaderLines',0,'ReadVariableNames',true);

clc;
% teensy_optical = teensy_optical * 3;
erpm = sd.rl_erpm / 7;
opt_rpm = sd.optical_rpm / 1;

figure
plot(sd.time_ms, erpm);
hold on
plot(sd.time_ms, opt_rpm);

legend("eRPM", "optical")

%%

clc;clear;close all;

% bench 2 and 3 with RL0006
% bench 1 with RL0001

bench = readtable('bench3.csv','HeaderLines',0,'ReadVariableNames',true);
sd = readtable('RL0001.csv','HeaderLines',0,'ReadVariableNames',true);

bench(1:1000,:) = [];
bench(end-359:end,:) = [];

sd(1:190,:) = [];
% sd(end-350:end,:) = [];

thrust = bench.Thrust_kgf_;
thrust = lowpass(thrust, 0.3);

torque = bench.Torque_N_m_;
time = bench.Time_s_;
time = time - time(1);

Fs = 20;                        % desired sample rate [Hz]
time = time(:);
thrust = thrust(:);

[time, idx] = sort(time);
thrust = thrust(idx);           % keep measurements paired with timestamps

t = time;
x = thrust;

t_uniform = (t(1):1/Fs:t(end)).';
x_uniform = interp1(t, x, t_uniform, 'linear');

teensy_time = sd.time_ms - sd.time_ms(1);
teensy_time = teensy_time / 1000;

rl_erpm_tru = sd.rl_erpm / 7;
teensy_eRPM2 = rl_erpm_tru .^ 2;

teensy_eRPM_scaled = teensy_eRPM2 / 6.32^11;
teensy_optical = sd.optical_rpm;

teensy_dshot = sd.rl_dshot .^ 2;
teensy_dshot = teensy_dshot / 1000000;

% figure
% plot(t_uniform, x_uniform);
% hold on
% plot(t_uniform, teensy_eRPM_scaled);
% legend("thrust", "eRPM")

% t = t_uniform(:);
% a = double(x_uniform(:));
% b = double(teensy_eRPM2(:));
% assert(numel(t) == numel(a) && numel(a) == numel(b), ...
%     'Both signals must match the shared time vector.');
% inWindow = t >= 5 & t <= 18;
% valid = inWindow & isfinite(a) & isfinite(b) & b ~= 0;
% assert(any(valid), 'No valid signal pairs between 5 and 18 seconds.');
% meanRatio = mean(a(valid) ./ b(valid));
% fprintf('Mean signal1/signal2 = %.6g (%d of %d samples used)\n', ...
%     meanRatio, nnz(valid), nnz(inWindow));

max(thrust)