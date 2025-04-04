%Author: Jason Scott
%Date: 3/2/2025
%Purpose: To determine the thrust force acting on a ramjet of a given
%diameter and maximum internal temperature at a specified Mach number


function[Thrust,f,mdota] = MD2ThrustFunction(d,M,Tmax,Qf,gamma,R,Ta,Pa,rhoa)

% Calculate Parameters
a = sqrt(gamma*R*Ta);
Va = M*a;
Cp = gamma*R/(gamma-1); % Assume constant

% Rocket Dimensions
Ainlet = (0.55*pi*d^2)/4; % Inlet Area 55% of frontal area
mdota = rhoa*Va*Ainlet; % Mass flow rate in [kg/s]

% Define loss coefficients
if M < 1
    rd = 1;
else
    rd = 1 - 0.1*(M-1)^1.5; % Diffuser stagnation pressure drop
end
rc = 0.9; % Combustion chamber stagnation pressure drop
rn = 0.93; % Nozzle stagnation pressure drop
etacomb = 0.95; % Combustion efficiency

% Stagnation Properties Before Diffuser
T0a = Ta *(1+((gamma-1)*M^2)/2);
P0a = Pa*(T0a/Ta)^(gamma/(gamma-1));

% Stagnation Properties After Diffuser
P02 = rd*P0a;
T02 = T0a;

% Stagnation Properties After Combustion
P04 = rc * P02;
T04 = Tmax; % Air assumed stagnant in compressor and this is max temperature

% Determine fuel percentage by weight
f = (T04 - T02)/((etacomb*Qf/Cp)-T04);

% Stagnation Properties After Nozzle aka Exit (6 is same as e)
P0e = rn * P04;
T0e = T04;

% Flow Properties at Exit
Pe = Pa; % Assumption
Te = T0e/((P0e/Pe)^((gamma-1)/gamma));

% Other Exit Properties
Msquared = (2/(gamma-1))*((T0e/Te)-1); % Mach Exit
Me = sqrt(Msquared);

% fprintf("test")
if imag(Me) ~= 0
    fprintf('fail')
end

%A = 1 + (gamma-1)/2*M^2;
%B = rd*rc*rn^((gamma-1)/gamma);

%Me = sqrt(2/(gamma-1)*(A*B-1));
%a1 = 2/(gamma-1);
%a2 = 1 + M^2/a1;

%Me = 

ae = sqrt(gamma*R*Te); % Speed Sound Exit
Ve = Me*ae; % Velocity Exit

% Calculate Thrust
Thrust = ((1+f)*Ve - Va)*mdota; % Thrust [N]
Thrust = real(Thrust);








