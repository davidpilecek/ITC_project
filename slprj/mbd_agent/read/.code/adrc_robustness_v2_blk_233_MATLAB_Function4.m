function [psidot, rdot] = yaw_dynamics( ...
    phi, theta, p, q, r, U, inertia_mx)

Ix = inertia_mx(1);
Iy = inertia_mx(2);
Iz = inertia_mx(3);

psidot = 0;
rdot = 0;

tau_yaw = U(4);

psidot = (sin(phi)*q + cos(phi)*r)/cos(theta);

rdot = (tau_yaw + (Ix-Iy)*p*q)/Iz;

end