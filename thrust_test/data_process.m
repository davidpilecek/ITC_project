clc;clear;close all;

% only log4 has optical RPM 

rc = readtable('d2/log4.csv','HeaderLines',0,'ReadVariableNames',true);
sd = readtable('d2/RL0018.csv','HeaderLines',0,'ReadVariableNames',true);

rc(1:700,:) = [];

erpm = sd.rl_erpm/7;

plot(-rc.Thrust_kgf_)
% hold on
figure
plot(erpm)
hold on
plot(rc.MotorOpticalSpeed_RPM_)

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