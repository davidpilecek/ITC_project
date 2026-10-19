%% Vehicle parameters
clc;clear;

%%
h = 0.20;               % Hull height [m]

L = 0.20;               % Hull length [m]
Width = 0.08;           % Hull width [m]
Area = 2*L*Width;       % Total hull platform area

g = 9.81;               % Gravity 

rho_air   = 1.225;      % Air density 
rho_water = 1000;       % Water density

V_max = Area*h;            % Max displaced volume
Fb_max = rho_water*g*V_max;


Trot = 0.01;

m_prop = 0.01;
m_nom = 1.30 + 4*m_prop;
W = m_nom;

Fg = W*g;               % Gravity force

c_float = W/(rho_water*Area);
z_float = h/2 - c_float;

init_h = 0.03;
end_h = 0.03;

U_max = 4*17;

Ts = 0.01;

Ixx = 0.0118;
Iyy = 0.0118;
Izz = 0.0228;

inertia_mx = [Ixx; Iyy; Izz;];

% Altitude
wc_z = 3;          % rad/s
wo_z = 5*wc_z;    % rad/s
b0_z = 1;
beta1_z = 3*wo_z;
beta2_z = 3*wo_z^2;
beta3_z = wo_z^3;

% X Position
wc_x = 2;            % rad/s
wo_x = 10*wc_x;        % rad/s
b0_x = 1/W;
beta1_x = 3*wo_x;
beta2_x = 3*wo_x^2;
beta3_x = wo_x^3;

% Y Position
wc_y = 2;            % rad/s
wo_y = 10*wc_y;        % rad/s
b0_y = 1/W;
beta1_y = 3*wo_y;
beta2_y = 3*wo_y^2;
beta3_y = wo_y^3;

% Roll
wc_roll = 20;         % rad/s
wo_roll = 5*wc_roll;  % rad/s
b0_roll = 1/Ixx;
beta1_roll = 3*wo_roll;
beta2_roll = 3*wo_roll^2;
beta3_roll = wo_roll^3;

% Pitch
wc_pitch = 20;          % rad/s
wo_pitch = 5*wc_pitch;  % rad/s
b0_pitch = 1/Iyy;
beta1_pitch = 3*wo_pitch;
beta2_pitch = 3*wo_pitch^2;
beta3_pitch = wo_pitch^3;

% Yaw
wc_yaw = 5;          % rad/s
wo_yaw = 8*wc_yaw;    % rad/s
b0_yaw = 1/Izz;
beta1_yaw = 3*wo_yaw;
beta2_yaw = 3*wo_yaw^2;
beta3_yaw = wo_yaw^3;

r0_position = 3;
h0 = Ts;

r0_angle = 10;

arm_L = 0.3;

km = 2e-7;
kf = 1.072e-5;

Alloc = [ kf,     kf,     kf,     kf;
          0,  -kf*arm_L,      0,   kf*arm_L;
        -kf*arm_L,      0,   kf*arm_L,      0;
          km,    -km,     km,    -km ]

K_alloc = Alloc \ diag([W, 1, 1, 1])

Alloc_2 = inv(K_alloc);

%%
% Trajectory parameters
altitude = 3;       % m
Ax = 2;             % X amplitude (m)
Ay = 1;             % Y amplitude (m)

tTakeoff = 6;       % Takeoff duration (s)
tLoop = 20;         % Duration of one figure-eight (s)
nLoops = 2;         % Number of figure-eights
nPerLoop = 16;      % Segments per figure-eight

% Parametric figure-eight
theta = linspace(0, 2*pi*nLoops, ...
                 nPerLoop*nLoops + 1);

x = Ax*sin(theta);
y = Ay*sin(2*theta);
z = altitude*ones(size(theta));

% Waypoints: 3 x N matrix
% Rows correspond to X, Y, Z
waypoints = [0, x;
             0, y;
             0, z];

% TimePoints: 1 x N row vector
timePoints = [0, tTakeoff + ...
    (0:nPerLoop*nLoops)*(tLoop/nPerLoop)];

% Boundary conditions
velBC = nan(size(waypoints));
accelBC = nan(size(waypoints));

% Start, takeoff completion and final hover
velBC(:,[1 2 end]) = 0;
accelBC(:,[1 2 end]) = 0;

% Keep altitude constant during figure-eights
velBC(3,2:end) = 0;
accelBC(3,2:end) = 0;

jerkBC = nan(size(waypoints));



% Include takeoff position at the origin
markerPos = waypoints.';     % N x 3

N = size(markerPos, 1);

% Marker size and color
markerSize = 0.1 * ones(N, 1);
markerColor = repmat([0 1 0], N, 1);

% N x 7 matrix
markers = [markerPos, markerSize, markerColor];

% Plot waypoints
% figure;
% plot3(waypoints(1,:), waypoints(2,:), ...
%        waypoints(3,:), 'o-');
% grid on;
% axis equal;
% % xlabel('X (m)');
% % ylabel('Y (m)');
% % zlabel('Z (m)');
% % title('3D Figure-Eight Waypoints');

%%


% Extract positions
ref = squeeze(out.xyz_reference.Data);
actual = squeeze(out.xyz_recorded.Data);

% Ensure N x 3 matrices
if size(ref,2) ~= 3
    ref = ref.';
end

if size(actual,2) ~= 3
    actual = actual.';
end

% Create figure
figure('Color', 'w');
hold on;
grid on;
box on;

% Reference trajectory
plot3(ref(:,1), ref(:,2), ref(:,3), ...
    'b--', 'LineWidth', 2);

% Actual trajectory (ADRC)
plot3(actual(:,1), actual(:,2), actual(:,3), ...
    'r-', 'LineWidth', 1.8);

% Start position
plot3(actual(1,1), actual(1,2), actual(1,3), ...
    'gs', 'MarkerSize', 8, ...
    'MarkerFaceColor', 'g');

% End position
plot3(actual(end,1), actual(end,2), actual(end,3), ...
    'r^', 'MarkerSize', 8, ...
    'MarkerFaceColor', 'r');

% Labels and title
xlabel('x (m)');
ylabel('y (m)');
zlabel('z (m)');
title('3D Trajectory: Figure-Eight with ADRC');

legend('Reference', 'ADRC', 'Start', 'End', ...
    'Location', 'best');

% Appearance
axis equal;
view(35, 25);
set(gca, 'FontSize', 11);
