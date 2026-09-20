%%

h = 0.2;     % m
A = 0.2*0.08*2;        % m^2
m = 1;       % kg
g = 9.81; 
rho = 1000;   % water density [kg/m^3]

%% Quadrotor parameters

m = 1.5;              % mass [kg]
g = 9.81;             % gravity [m/s^2]

% Moments of inertia
Jx = 0.02;            % [kg m^2]
Jy = 0.02;            % [kg m^2]
Jz = 0.04;            % [kg m^2]

J = diag([Jx Jy Jz]);

rho_water = 1000;       % water density [kg/m^3]

hull_width  = 0.30;     % hull width [m]
hull_length = 0.40;     % hull length [m]
hull_height = 0.20;     % hull height [m]

V_hull = hull_width*hull_length*hull_height;

z_water = 0;            % water surface [m]

x0 = [ ...
    0;  % x
    0;  % y
    2;  % z

    0;  % vx
    0;  % vy
    0;  % vz

    0;  % phi
    0;  % theta
    0;  % psi

    0;  % p
    0;  % q
    0]; % r