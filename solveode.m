
close all
clear all


% Set resolution of optimization for incremental thickness
RES = 100;

% Set resolution of varying the design parameters for sensitivity analysis
RES_sensitivity = 10;

% Material properties
% Density of lining material [kg/m^3]
% Area of the suitcase face [m^2], 
% Young's Modulus of the lining material and shell [kPa]
% Thickness of shell [m]
AREA = 0.76*0.51;
DENSITY = 32.84;
YOUNGS_MOD_L = 27.578;
DAMPING_RATIO_L = 0.096;
YOUNGS_MOD_S = 2.39e6;
TH_S = 0.025;

% Constraints on thickness of material lining [m]
min_th = 0;
max_th = 0.014;
dth = (max_th - min_th)/RES;

% Starting value of lining thickness 
% Update function will systematically decrease the thickness
th = max_th; 
thmat = linspace(min_th,max_th,RES);

% %% Create some "experimental data"
% % not sure if this is necessary
% expTime = 0:0.01:10;
% expY = exp(-expTime) + 0.02*randn(size(expTime));
% plot(expTime, expY)

% Set up optimization

% ODE Information
t0 = 0;
tf = 10;
tspan = [t0 tf];
y0 = zeros(3,1);

% Starting values for the variables, corresponding to the lining
% All these values depend on the thickness of the lining
m_l = 0.17;
k_l = YOUNGS_MOD_S*(AREA/th);
b_l = DAMPING_RATIO_L*2*sqrt(k_l*m_l);

% Selected initial values of constants for the shell and contents
% These values will be varied during mathematical sensitivity analysis
m_s = 6;
m_c = 34.5-m_s-m_l;
k_s = YOUNGS_MOD_S*(AREA/TH_S);
b_s = 0; % Assume no damping in the shell material

% Input force on the system
F_i = (m_s + m_l + m_c)*9.81;

% Constants for the shell
qs = 0; % displacement of the shell
ps = 144; % momentum of the shell
%p(t) = exp(-10*t+4.9698);
%f = diff(p);

% pt = exp(-10*t+4.9698);
% F_i = diff(pt);

momentum = zeros(length(th),3);

for i=1:length(thmat)
    sol = ode15s(@(t,y) suitcase(t,y,m_s,k_s,b_s,m_l,k_l,b_l,m_c,F_i,qs,ps), tspan, y0);
    
	momentum(i,1) = max(sol.y(3,:)); % store max momentum
%     disp(th);
    momentum(i,2) = th; % store thickness
    momentum(i,3) = m_l; % mass
    momentum(i,4) = m_l/DENSITY; % volume
%     disp(m_l);
    
    [th,m_l,k_l,b_l] = updateParam(th,dth,DENSITY,YOUNGS_MOD_L,DAMPING_RATIO_L,AREA);
end

    
% sol = ode15s(@(t,y) suitcase(t,y,m_s,k_s,b_s,m_l,k_l,b_l,m_c,F_i,qs,ps), tspan, y0);
% zerofnd = fzero(@(r)deval(sol,r,3),[sol.x(2),sol.x(end)]);

% F = (400-50*(t-2.828).^2);
% figure
% plot(tspan,F)

% figure
% plot(sol.x,sol.y(1,:))
% title('Momentum of Lining')
% figure
% plot(sol.x,sol.y(2,:))
% title('Displacement of Lining')
% figure
% plot(sol.x,sol.y(3,:))
% title('Momentum of Contents')

figure
plot(momentum(:,2), momentum(:,3))
title('th vs mass')
figure
hold on
plot(momentum(:,2), (ps-momentum(:,1)/ps))
title('Thickness vs momentum of Contents')
plot(momentum(:,2), momentum(:,4))
hold off
title('th vs volume')
figure
plot(sol.x,sol.y(1))
