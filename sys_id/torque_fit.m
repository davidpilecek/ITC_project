%% Plot 1: Torque vs. time
figure;
plot(tUniform, torqueUniform);
xlabel('Time (s)');
ylabel('Thrust (kgf)');
grid on;

%%

% Fit a quadratic thrust model from optical RPM squared
rad_s_2 = omega .^ 2;
torque_N = torqueUniform;

t_clean = tUniform;
valid = isfinite(rad_s_2) & isfinite(torque_N);
torqueModel = polyfit(rad_s_2(valid), torque_N(valid), 1);
torquePredicted = polyval(torqueModel, rad_s_2);

km = torqueModel(1)

figure
plot(rad_s_2(valid), torque_N(valid), '.', 'DisplayName', 'Measured')
hold on
plot(rad_s_2(valid), torquePredicted(valid), 'LineWidth', 1.5, ...
    'DisplayName', 'Linear fit')
xlabel('Optical RPM^2')
ylabel('Thrust [N]')
legend('Location', 'best')
grid on

% Compare measured thrust with the fitted optical-RPM model
figure
plot(t_clean,  torque_N, 'DisplayName', 'Measured thrust')
hold on
plot(t_clean, torquePredicted, 'LineWidth', 1.5, ...
    'DisplayName', 'Model prediction')
xlabel('Time (s)')
ylabel('Torque (N)')
legend('Location', 'best')
grid on

%% make plots for report

makePlot(t_clean, [torque_N, torquePredicted], ...
    ["Measured torque", "Model prediction"], ...
    "torque_predicted", ...
    LegendLocation = "best",...
    XLabel="Time (s)", ...
    YLabel="Torque (N/m)");

%%
makePlot(rad_s_2(valid), [torque_N(valid), torquePredicted(valid)], ...
    ["Measured", "Linear fit"], ...
    "torque_vs_omega_predicted", ...
    XLabel="Angular velocity squared ((rad/s)^2)", ...
    YLabel="Torque (N/m))",...
    PlotTypes=["scatter", "line"], ...
    MarkerSize=5);