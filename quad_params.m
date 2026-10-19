%% Vehicle parameters
clc;clear;

%%
h = 0.20;               % Hull height [m]

L = 0.20;               % Hull length [m]
Width = 0.08;           % Hull width [m]
Area = 2*L*Width;       % Total hull platform area

m = 1.30;               % Vehicle mass 
g = 9.81;               % Gravity 

rho_air   = 1.225;      % Air density 
rho_water = 1000;       % Water density

Fg = m*g;               % Gravity force

V_max = Area*h;            % Max displaced volume
Fb_max = rho_water*g*V_max;

c_float = m/(rho_water*Area);
z_float = h/2 - c_float;

Trot = 0.01;

m_prop = 0.05;
m_nom = m + 4*m_prop;
W = m_nom;

init_h = 0.03;
end_h = 0.03;

U_max = 4*17;

Ts = 0.01;

Ixx = 0.0118;
Iyy = 0.0118;
Izz = 0.0228;

inertia_mx = [Ixx; Iyy; Izz;];

% Altitude
wc_z = 5;          % rad/s
wo_z = 8*wc_z;    % rad/s
b0_z = 1;
beta1_z = 3*wo_z;
beta2_z = 3*wo_z^2;
beta3_z = wo_z^3;

% X Position
wc_x = 1.5;            % rad/s
wo_x = 5*wc_x;        % rad/s
b0_x = 1/W;
beta1_x = 3*wo_x;
beta2_x = 3*wo_x^2;
beta3_x = wo_x^3;

% Y Position
wc_y = 1.5;            % rad/s
wo_y = 5*wc_y;        % rad/s
b0_y = 1/W;
beta1_y = 3*wo_y;
beta2_y = 3*wo_y^2;
beta3_y = wo_y^3;

% Roll
wc_roll = 15;         % rad/s
wo_roll = 5*wc_roll;  % rad/s
b0_roll = 1/Ixx;
beta1_roll = 3*wo_roll;
beta2_roll = 3*wo_roll^2;
beta3_roll = wo_roll^3;

% Pitch
wc_pitch = 15;          % rad/s
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

r0_position = 1;
h0 = Ts*2;

r0_angle = 5;

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
jerkBC = nan(size(waypoints));
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

% Plot waypoints
figure;
plot3(waypoints(1,:), waypoints(2,:), ...
      waypoints(3,:), 'o-');
grid on;
axis equal;
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('3D Figure-Eight Waypoints');
