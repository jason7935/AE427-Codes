% Author: Jason Scott
% Date: 3/3/2025
% Purpose: To determine the range and cruise speed of different design
% points for a ramjet missle.

clear
clc
%% Inputs and Definitions
h = 0; % Cruise Altitude [m]
Npoints = 100; % Number of diameter and temperature points to study
L_Ram = 4.25; % Length of Ramjet [m]

% Determine atmospheric conditions
[Ta,~,Pa,rhoa,~,~] = atmosisa(h);
gamma = 1.4;
R = 287; % [J/kgK]

% Define Diameter and Temperature Ranges
dmin = 4.25/7; % [m]
dmax = 4.25/4; % [m]
d = linspace(dmin,dmax,Npoints);

TL = 1700; % [K]
TH = 3000; % [K]
Tmax = linspace(TL,TH,Npoints);

% Fuel Properties
Qf = 45e6; % [J/kg]
rhof = 825; % [kg/m^3]

%% Determine Maximum and Minimum Mach Number for each combition(dia,Tmax)
% Initialize Variables
Mmin = zeros(Npoints);
Mmax = zeros(Npoints);
for i = 1:length(d)
    for j = 1:length(Tmax)
        [Mmin(i,j),Mmax(i,j)] = MD2MachNumbers(d(i),Tmax(j),Qf,gamma,R,Ta,Pa,rhoa);
    end
end
Mstart = 1.1 * Mmin; % Starting Mach Number for each combination

%% Determine Volume and Fuel Mass
% Rocket Volume
Volume = (pi*L_Ram*d.^2)./4;
% Fuel Volume
Vfuel = 0.3*Volume; % Fuel volume is 30%

% Mass of Fuel
mFuel = Vfuel*rhof; % [kg]
% Mass of Ramjet
mRam = mFuel/0.2; % From Problem Statement [kg]

%% Determine Ramjet Range
% Initialize
Range = zeros(Npoints);
for i = 1:length(d)
    for j = 1:length(Tmax)
        Range(i,j) = MD2RangeFunction(d(i),Tmax(j),Qf,Mstart(i,j),mFuel(i),mRam(i),gamma,R,Ta,Pa,rhoa);
    end
end

%% Plotting Range
figure(1);
Range = Range/1000;
imagesc(d, Tmax, Range');
colorbar;
xlabel('Diameter (m)');
ylabel('Temperature (K)');
title('Ramjet Range (km) Heatmap');
set(gca, 'YDir', 'normal'); % Ensure the y-axis is oriented correctly (bottom to top)
colormap jet; % Optional: Apply a color map
%% Plotting Cruise Speed
figure(2);
imagesc(d, Tmax, Mmax');
colorbar;
xlabel('Diameter (m)');
ylabel('Temperature (K)');
title('Cruise Mach Number Heatmap');
set(gca, 'YDir', 'normal'); % Ensure the y-axis is oriented correctly (bottom to top)
colormap jet; % Optional: Apply a color map
%% Plotting Weighted Design Study
Rangemax = max(max(Range));
Rangemin = min(min(Range));
Mmaxmax = max(max(Mmax));
Mmaxmin = min(min(Mmax));

b = (Range-Rangemin)/(Rangemax-Rangemin);
c = (Mmax-Mmaxmin)/(Mmaxmax-Mmaxmin);
k = 0.75*b + 0.25*c;
figure(3);
imagesc(d, Tmax, k');
colorbar;
xlabel('Diameter (m)');
ylabel('Temperature (K)');
title('Pareto Optimization Heatmap');
set(gca, 'YDir', 'normal'); % Ensure the y-axis is oriented correctly (bottom to top)
colormap jet; % Optional: Apply a color map

%% 
% figure(1);
% imagesc(d, Tmax, Mmin);
% colorbar;
% xlabel('Diameter (m)');
% ylabel('Temperature (K)');
% title('Ramjet Range (m) Heatmap');
% set(gca, 'YDir', 'normal'); % Ensure the y-axis is oriented correctly (bottom to top)
% colormap jet; % Optional: Apply a color map