clear all

% Define Fuel Cell
fc.OpT = 180; %C, dependent on FC type %Decreasing T increases power?!
fc.Ncells = 1080; % FC input
fc.A = 0.0446; %m^2, FC input
fc.r = 6.2e-6; % ohm/m^2, FC input % main tuning parameter
fc.alpha = 0.5; % FC input, constant?
fc.xpara = 0.05; % parasitic loss factor, FC input
fc.Comp_eff = 0.9 ; %compressor efficiency
fc.Pfuel = 5; %bar, input
fc.mu =  .96; % Fuel utilization
fc.c0 = 1.125; % Stack pressurization coeff.
fc.c1 = 0.175; % Stack pressurization coeff.
fc.k = 60e-7; % 
fc.m = 8e-5;
fc.n = 2e-4;

% Loop for graphs of flight conditions
for kk = 1:2
    
% Flight conditions
if kk == 1
    altitude = 0;
    M = .25;
elseif kk == 2
    altitude = 37000;
    M = .773;
end


% Initialize sweep
h = altitude;
L_sweep = 101;
Pnet = zeros(L_sweep,1);
Eff_net = zeros(L_sweep,1);
Qdot = zeros(L_sweep,1);
Pcompressor = zeros(L_sweep,1);
mdot_air = zeros(L_sweep,1);
FC_eff = zeros(L_sweep,1);
Vcell = zeros(L_sweep,1);
Id = zeros(L_sweep,1);
Pgross = zeros(L_sweep,1);
P_data = zeros(L_sweep,1);
fuel_sweep = linspace(0.0001,0.02,L_sweep); % Fuel flow rate in kg/sec


% Iterate over fuel flow rates
for i = 1:101
    mdot_fuel = fuel_sweep(i);
    [Pnet(i),Eff_net(i),Qdot(i),Pcompressor(i),mdot_air(i),FC_eff(i),Vcell(i),Id(i),Pgross(i),P_data(i)] = FC_calc(fc,altitude, mdot_fuel,M);

end


figure(kk)
plot(Pgross,FC_eff,Pnet,Eff_net)
legend('Internal Model, Gross Power','Internal Model, Net Power','Boeing Model')



xlabel('Power, Watts')
ylabel('Total Efficiency')

xlim([0 1e6])
if M < 0.3
title('Take-Off')
elseif M > 0.4
title('Cruise')
end

end


% Example of how to create fuel cell files for interpolation later
fc.weight = 363*2.2; % Pounds of fuel cell per stack
FC_File_Creator(fc)