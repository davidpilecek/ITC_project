%% Vehicle parameters
clc;clear;

%%
h = 0.20;               % Hull height [m]

L = 0.20;               % Hull length [m]
Width = 0.08;               % Hull width [m]
Area = 2*L*Width;              % Total hull platform area

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

m_prop = 0.01;
W = m + 4*m_prop;

init_h = 0.158;
end_h = 0.058;

%%
U_max = 70;

Ts = 0.01;

wc = 12;       % rad/s

wo = 8*wc;      % rad/s
b0 = 1/W;

beta1 = 3*wo;     
beta2 = 3*wo^2;    
beta3 = wo^3;       

kp = wc^2;          
kd = 2*wc;          

r0 = 0.9;
h0 = Ts;

%%

L = 0.1;
l = sqrt(2)*L;

KQ = 2e-7;
Kf = 1.072e-5;

K = KQ/Kf;
A = [ ...
     1,  1,  1,  1;
    -l/sqrt(2),  l/sqrt(2),  l/sqrt(2), -l/sqrt(2);
     l/sqrt(2),  l/sqrt(2), -l/sqrt(2), -l/sqrt(2);
    -K, K, -K, K];

Alloc = [ ...
    1/(4*Kf), -sqrt(2)/(4*Kf*l),  sqrt(2)/(4*Kf*l), -1/(4*K*Kf);
    1/(4*Kf),  sqrt(2)/(4*Kf*l),  sqrt(2)/(4*Kf*l),  1/(4*K*Kf);
    1/(4*Kf),  sqrt(2)/(4*Kf*l), -sqrt(2)/(4*Kf*l), -1/(4*K*Kf);
    1/(4*Kf), -sqrt(2)/(4*Kf*l), -sqrt(2)/(4*Kf*l),  1/(4*K*Kf)];