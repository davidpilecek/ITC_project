%%
clc; clear; close all;

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

% Extract signals
% Tyto thrust stand
t = rc.Time_s_ - rc.Time_s_(1);
thrust = -rc.Thrust_kgf_;
rpmOptical = rc.MotorOpticalSpeed_RPM_;

% ESC telemetry
rpmESC = sd.rl_erpm / motorPoles;
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

fprintf('Total samples: %d\n', numel(rpm));
fprintf('Unique RPM values: %d\n', numel(unique(rpm)));
fprintf('Duplicate values: %d\n', numel(rpm) - numel(unique(rpm)));

% Gives rpm, thrustUniform, tUniform

%% Plot 2: ESC vs. optical RPM
% Assumes the ESC and Tyto logs have already been synchronized.

opt = rpmOpticalUniform;
esc = rpmESC;

% Keep only rows where the difference is <= 2000 RPM
valid = isfinite(opt) & isfinite(esc) & abs(opt - esc) <= 2000;

% Remove outliers from both signals
opt_clean = opt(valid);
esc_clean = esc(valid);

% If you have a corresponding time vector:
t_clean = t(valid);

figure;
plot(esc_clean);
hold on;
plot(opt_clean);
xlabel('Time (s)');
ylabel('Rotor speed (RPM)');
legend('ESC RPM', 'Optical RPM');
grid on;

makePlot(t_clean, [opt_clean, esc_clean], ...
    ["Optical RPM", "Electrical RPM"], ...
    "rpm_vs_time_both", ...
    XLabel="Time (s)", ...
    YLabel="Rotor speed (rpm)");

%%

figure
% plot(rpmESC, rpmOpticalUniform)
scatter(opt_clean, esc_clean)
xlabel('Electrical RPM');
ylabel('Optical RPM');

makePlot(opt_clean, esc_clean, ...
    [], ...
    "erpm_vs_optical", ...
    XLabel="Optical RPM", ...
    YLabel="Electrical RPM", ...
    PlotTypes="scatter");

e = rpmOpticalUniform - rpmESC;

RMSE = sqrt(mean(e.^2))

x = opt_clean(:);
y = esc_clean(:);

% Linear regression
p = polyfit(x, y, 1);
slope = p(1)
bias = mean(y-x)