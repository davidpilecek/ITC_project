%% Vehicle parameters

h = 0.20;               % Hull height [m]

L = 0.20;               % Hull length [m]
W = 0.08;               % Hull width [m]
A = 2*L*W;              % Total hull platform area

m = 1.30;               % Vehicle mass 
g = 9.81;               % Gravity 

rho_air   = 1.225;      % Air density 
rho_water = 1000;       % Water density

Fg = m*g;               % Gravity force

V_max = A*h;            % Max displaced volume
Fb_max = rho_water*g*V_max;

c_float = m/(rho_water*A);
z_float = h/2 - c_float;

wc = 4;       % rad/s
wo = 5*wc;      % rad/s
b0 = 1/1;

beta1 = 3*wo;       % 45
beta2 = 3*wo^2;     % 675
beta3 = wo^3;       % 3375

kp = wc^2;          % 9
kd = 2*wc;          % 6

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