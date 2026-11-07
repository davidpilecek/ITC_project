T = readtable('RUN0005.csv','HeaderLines',0,'ReadVariableNames',true);

throttle = T.dshot_command;
rpm = T.shaft_rpm;
time = T.time_s;

throttle = rescale(throttle, 0, max(rpm));

figure
plot(time, throttle);
hold on
plot(time, rpm);
grid on;


%%
T = readtable("RUN0005.csv");

% Input and output as column vectors
u = double(T.dshot_command);
y = double(T.shaft_rpm);

% Preserve missing measurements as NaN—do not delete those rows
y(T.rpm_valid == 0) = NaN;

% Check for missing sample rows
assert(all(diff(T.sequence) == 1), ...
    "Missing sample rows detected; restore the time grid before identification.");

% Inspect actual timing
t = (double(T.time_us) - double(T.time_us(1))) * 1e-6;
Ts = 0.002;

fprintf("Sample interval: min %.3f, median %.3f, max %.3f ms\n", ...
    1000*min(diff(t)), 1000*median(diff(t)), 1000*max(diff(t)));

% Create identification dataset
data = iddata(y, u, Ts);
data.InputName  = {'DShot command'};
data.InputUnit  = {'counts'};
data.OutputName = {'Motor speed'};
data.OutputUnit = {'rpm'};
data.TimeUnit   = 'seconds';
data.InterSample = 'zoh';  % Commands are held constant between updates


t = data.SamplingInstants;
idx = find(t >= 14.7 & t <= 49.5);

data_cut = data(idx);
data_cut.Tstart = 0;  % Reset the cropped time axis

plot(data_cut);

plot(data);