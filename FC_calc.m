	function [Pnet,Eff_net,Qdot,Pcompressor,mdot_air,FC_eff,Vcell,Id,Pgross, eo] = FC_calc_v3(fc,altitude, mdot_fuel,M)	
% Constants
R = 8.314; %J/mol-K, const
F = 96485.33; %C/mol, const
cO2 = 0.21; %const, atmospheric
h_lh2 = 1.1993e8; %LHV of LH2. Update with more accurate num. Const
Cp = 1006; %j/kg-k, const.
gamma = 1.4;

% Transmissibility values, unsure of what kind of constant these are. Little effect.
m = fc.m;
n = fc.n;

% stack current paremters for stack pressure
c0 = fc.c0;
c1 = fc.c1;

% Air pressure calc, convert to bar
P0 = airpressure(0);
P_ambient = airpressure(altitude);
P_bar = P_ambient/P0;

% isentropic stagnation of air
isen_P = (1+(gamma-1)/2*M^2)^(gamma/(gamma-1))*P_bar;

% Needs to be updated w/ indigenous formula
[T, ~, ~, ~] = atmosisa(altitude/3.3);

% Total temperature
Tt_inf =  T*(1+(gamma-1)/2*M^2);

T_operating = fc.OpT+273.15;

%% Calculation

%Gibbs FE
eo = 1.229;

I_int = 2*F*mdot_fuel/fc.Ncells*1000/(2*1.0079); %amps, internal current

%Ideal Cell Currents
I = I_int*fc.mu;
Id = I/fc.A;

% Find stack pressure by this relationship
P_comp = c0 + c1*(I/(fc.A*10000))^2;
P_stack = P_comp + isen_P;

% Nernst Voltage
eNern = eo + R*T_operating/2/F*log(fc.Pfuel*sqrt(cO2)/sqrt(P_stack*0.9));

%Ohmic losses
deltaVohm = Id*fc.r; %ohmic voltage loss

% Activation Losses
fc.Ido  = 2*F*fc.k*cO2*P_stack/fc.A;
deltaVact = R*T_operating/(2*fc.alpha*F)*log(Id/fc.Ido);

% Mass Transport Losses
deltaVtrans = m*exp(Id*n);

% Cell level voltage
Vcell = eNern - deltaVohm - deltaVact - deltaVtrans - fc.deg;

% Stack level calculations
Vstack = Vcell*fc.Ncells;

%Gross power, watts
Pgross = I*Vstack; 

% Fuel cell (gross) efficiency
FC_eff = Pgross/h_lh2/mdot_fuel; 

% Heat Estimation
QFC = Pgross*(1-FC_eff);
Qact = deltaVact*fc.Ncells*Id*fc.A;
Qohm = Id^2*fc.A*fc.r*fc.Ncells;

% Maximum heat source
Qdot = max(Qact+Qohm,QFC);

%% Balance of plant

% Mass flow rate of air required
mdot_air = I*fc.Ncells/F*28.97/4/1000/.21*1.5; % 1.5 50% more than stoic-needed

% Parasitic power, constant % to run balance of plant systems
Pparasite = fc.xpara*Pgross;

% Power to run compressor
Pcompressor = mdot_air*Cp*Tt_inf*((P_stack/isen_P)^((0.4/1.4))-1)/fc.Comp_eff; % Compressor power

%% Summation
Plosses = Pcompressor + Pparasite; 
Pnet = Pgross - Plosses;

Eff_net = Pnet/h_lh2/mdot_fuel;

end