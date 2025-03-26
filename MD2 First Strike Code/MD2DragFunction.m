%Author: Jason Scott
%Date: 2/27/2025
%Purpose: To determine the drag force acting on the ramjet for MD2 in AE470
%as a function of the Mach number of the vehicle and the maximum diameter
%of the missile
%Inputs:Diameter, Mach Number, Gamma Air, R Air, T atmosphere, rho
%atmosphere

function [Drag] = MD2DragFunction(d,M,gamma,R,Ta,rhoa)

% Calculate Parameters
a = sqrt(gamma*R*Ta); % Speed of sound [m/s]
Va = M*a; % Air Velocity [m/s]
q = 0.5*rhoa*Va^2; % Dynamic Pressure

% Rocket Dimensions
L_Nose = 2*d; % Nose Length [m]
L = 4.25; % Rocket Length [m]

Sref = (pi*d^2)/4;

% Calculate Drag using provided model
Cd_wave = (1.75 + (1.93/M^2))*(atan(0.5/(L_Nose/d)))^1.69;
Cd_friction = 0.1*(L/d)^1.5*(M/(0.0685*q*L)^0.2);

Cd = Cd_wave + Cd_friction;

Drag = Cd * Sref * q;