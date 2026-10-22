function p = makeADRC(wc, kESO, b0)
%MAKEADRC Parameters for continuous-time second-order linear ADRC.

    p.wc   = wc;
    p.kESO = kESO;
    p.wo   = kESO * wc;
    p.b0   = b0;

    % Controller gains
    p.kp = wc^2;
    p.kd = 2 * wc;

    % Observer gains
    p.beta1 = 3 * p.wo;
    p.beta2 = 3 * p.wo^2;
    p.beta3 = p.wo^3;

end