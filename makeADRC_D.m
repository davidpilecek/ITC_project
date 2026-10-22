function p = makeADRC_D(wc, kESO, b0, Ts)
%MAKEADRC_D Second-order discrete-time ADRC coefficients.
%   Dual-feedback transfer-function form, Table A.7.3.
%
%   wc   : Controller tuning frequency [rad/s]
%   kESO : Observer-to-controller tuning frequency ratio
%   b0   : Nominal plant input gain
%   Ts   : Sampling period [s]

    p.wc   = wc;
    p.kESO = kESO;
    p.wo   = kESO * wc;
    p.b0   = b0;
    p.Ts   = Ts;

    % Discrete pole locations
    p.zCL  = exp(-p.wc * Ts);
    p.zESO = exp(-p.wo * Ts);

    % Local aliases and common expressions
    zCL  = p.zCL;
    zESO = p.zESO;


    % Discrete state-feedback gains
    p.k1 = (1 - p.zCL)^2 / Ts^2;
    
    p.k2 = (4 - (1 + p.zCL)^2) / (2*Ts);
    
    common = (1 + zCL)^2 * (1 + zESO)^3;
    scale  = 1 / (b0 * Ts^2);

    % Alpha coefficients
    p.alpha1 = -3 * zESO;
    p.alpha2 =  3 * zESO^2;
    p.alpha3 = -zESO^3;

    % Beta coefficients
    p.beta0 = scale * ( ...
        common/4 ...
        - 2 * (zCL^2*zESO^3 + 2*zCL + 3*zESO - 2));

    p.beta1 = scale * ( ...
        -common ...
        + 2*(1 + zCL)^2 ...
        + 6 * (zCL^2*zESO^3 + 2*zCL*zESO ...
               + zESO^2 + zESO - 1));

    p.beta2 = scale * ( ...
        -common/4 ...
        + 2 * (-2*zCL^2*zESO^3 + 3*zCL^2*zESO^2 ...
               + 2*zCL*zESO^3 + 1));

    % Gamma coefficients
    p.gamma0 = common/8 - zESO*(zCL^2*zESO^2 + 3);

    p.gamma1 = -common/8 + 3*zESO^2 + 1;

    p.gamma2 = zESO^3 * (zCL^2 - 1);

    % Final gain listed in the table
    p.k1_over_b0 = (1 - zCL)^2 / (b0 * Ts^2);

end