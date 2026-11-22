%% Plot 1: Thrust vs. time
figure;
plot(tUniform, thrustUniform);
xlabel('Time (s)');
ylabel('Thrust (kgf)');
grid on;

%%

% Fit a quadratic thrust model from optical RPM squared
rad_s_2 = omega .^ 2;
thrust_N = thrustUniform * 9.81;

t_clean = tUniform;
valid = isfinite(rad_s_2) & isfinite(thrust_N);
thrustModel = polyfit(rad_s_2(valid), thrust_N(valid), 1);
thrustPredicted = polyval(thrustModel, rad_s_2);

kf = thrustModel(1)

figure
plot(rad_s_2(valid), thrust_N(valid), '.', 'DisplayName', 'Measured')
hold on
plot(rad_s_2(valid), thrustPredicted(valid), 'LineWidth', 1.5, ...
    'DisplayName', 'Linear fit')
xlabel('Optical RPM^2')
ylabel('Thrust [N]')
legend('Location', 'best')
grid on

% Compare measured thrust with the fitted optical-RPM model
figure
plot(t_clean,  thrust_N, 'DisplayName', 'Measured thrust')
hold on
plot(t_clean, thrustPredicted, 'LineWidth', 1.5, ...
    'DisplayName', 'Model prediction')
xlabel('Time (s)')
ylabel('Thrust (N)')
legend('Location', 'best')
grid on

%% make plots for report

makePlot(t_clean, [thrust_N, thrustPredicted], ...
    ["Measured thrust", "Model prediction"], ...
    "thrust_predicted", ...
    LegendLocation = "best",...
    XLabel="Time (s)", ...
    YLabel="Thrust (N)");

%%
makePlot(rad_s_2(valid), [thrust_N(valid), thrustPredicted(valid)], ...
    ["Measured", "Linear fit"], ...
    "thrust_vs_omega_predicted", ...
    XLabel="Angular velocity squared ((rad/s)^2)", ...
    YLabel="Thrust (N)",...
    PlotTypes=["scatter", "line"], ...
    MarkerSize=5);
