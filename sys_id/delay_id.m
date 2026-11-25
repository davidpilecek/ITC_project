%%
clc;clear;close all;

sd = readtable('d4/RL0037.CSV');

% Fs = 200;
Ts = 0.05;

sd(1:200,:) = [];
sd(end-500:end,:) = [];
t = (sd.time_ms - sd.time_ms(1)) / 1000;

command = sd.rl_dshot - sd.rl_dshot(1);
erpm = abs(sd.rl_erpm - sd.rl_erpm(1) );

%%
data = iddata(erpm(:), command(:), Ts);
sys = tfest(data, 1, 0)

compare(data, sys);

figure
yyaxis left
plot(command)
ylim([0 210])

yyaxis right
plot(erpm)
ylim([0 25000])

%%

[fig, ax] = makePlot(t, [command, erpm], ...
    ["Command", "Motor speed"], ...
    "motor_step_response", ...
    XLabel="Time (s)", ...
    YLabel="Command", ...
    YLabelRight="Motor speed (rpm)", ...
    YAxis=["left", "right"], ...
    PlotTypes=["line", "line"], ...
    YLim=[-10 210], ...
    YLimRight=[-1000 25000]);