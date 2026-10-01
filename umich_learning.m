clc;clear;

A = [ 0   1   0
     980  0  -2.8
      0   0  -100 ];

B = [ 0
      0
      100 ];

C = [ 1 0 0 ];

poles = eigs(A)

%%

t = 0:0.01:2;
u = zeros(size(t));
x0 = [0.01 0 0];

sys = ss(A,B,C,0);

p1 = -10 + 10i;
p2 = -10 - 10i;
p3 = -50;

K = place(A,B,[p1 p2 p3])
sys_cl = ss(A-B*K,B,C,0);

lsim(sys_cl,u,t,x0);
xlabel('Time (sec)')
ylabel('Ball Position (m)')

hold on;

p1 = -20 + 20i;
p2 = -20 - 20i;
p3 = -100;

K = place(A,B,[p1 p2 p3])
sys_cl = ss(A-B*K,B,C,0);

lsim(sys_cl,u,t,x0);

%%

t = 0:0.01:2;
u = 0.001*ones(size(t));

sys_cl = ss(A-B*K,B,C,0);

lsim(sys_cl,u,t);
xlabel('Time (sec)')
ylabel('Ball Position (m)')
axis([0 2 -4E-6 0])

%%
Nbar = rscale(sys,K)

op1 = -100;
op2 = -101;
op3 = -102;

L = place(A',C',[op1 op2 op3])';

At = [ A-B*K             B*K;
       zeros(size(A))    A-L*C ];

Bt = [    B*Nbar;   zeros(size(B)) ];

Ct = [ C    zeros(size(C)) ];

sys = ss(At,Bt,Ct,0);
lsim(sys,zeros(size(t)),t,[x0 x0]);

title('Linear Simulation Results (with observer)')
xlabel('Time (sec)')
ylabel('Ball Position (m)')

%%

t = 0:1E-6:0.1;
x0 = [0.01 0.5 -5];
[y,t,x] = lsim(sys,zeros(size(t)),t,[x0 x0]);

n = 3;
e = x(:,n+1:end);
x = x(:,1:n);
x_est = x - e;

% Save state variables explicitly to aid in plotting
h = x(:,1); h_dot = x(:,2); i = x(:,3);
h_est = x_est(:,1); h_dot_est = x_est(:,2); i_est = x_est(:,3);

plot(t,h,'-r',t,h_est,':r',t,h_dot,'-b',t,h_dot_est,':b',t,i,'-g',t,i_est,':g')
legend('h','h_{est}','hdot','hdot_{est}','i','i_{est}')
xlabel('Time (sec)')