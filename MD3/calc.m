function [tsfc, area_in, fuel_flow, area_out] = calc(BR,pfr,T04)

% Atmospheric Conditions
[Tatm, ~, Patm, rhoAtm] = atmosisa(8500);

% Other
pcr = 25;
Ma = 0.55;
R = 287;
Qr = 45e6;

% Gammas
gammaa=1.4;
gammad=1.4;
gammac=1.37;
gammab=1.35;
gammat=1.33;
gammaab=1.35;
gamman=1.36;
gammaf=1.4;
gammafn=1.36;

% Efficiency
nd=0.97;
nc=0.85;
nb=1.0;
nt=0.90;
nab=0.92;
nn=0.98;
nf=0.85;
nfn=0.97;

%If you want to add an afterburner the code is in here
ABon=false;
Tab=T04;

% Calculate flight conditions
c=sqrt(gammaa*R*Tatm);

V=Ma*c;
T02=Tatm*(1.0+(gammaa-1.0)*(Ma^2.0)/2.0);
cpD=R*gammad/(gammad-1);
P02=Patm*(1+nd*((T02/Tatm)-1.0))^(gammad/(gammad-1.0));
P03=P02*pcr;
T03=T02*(1+(pcr^((gammac-1.0)/gammac)-1.0)/nc);
cpc=R*gammac/(gammac-1); %specific heat in compressor
P04=nb*P03;
cpb=R*gammab/(gammab-1);
f=(T04-T03)/(Qr/cpb-T04);

% Add in the turbo fan calculations
P08=P02*pfr;
T08=T02*(1+(pfr^((gammaf-1.0)/gammaf)-1.0)/nf);
cpf=R*gammaf/(gammaf-1);  %specific heat through fan
uef=sqrt(2.0*nfn*(gammafn/(gammafn-1.0))*R*T08*(1-(Patm/P08)^((gammafn-1.0)/gammafn)));
T8=T08*(1-nfn*(1-(Patm/P08)^((gammafn-1.0)/gammafn)));
cef=sqrt(gammafn*R*T8);
Mef=uef/cef;

% Now back to the turbine   
cpt=gammat*R/(gammat-1.0);
T05=T04-(cpc/cpt)*(T03-T02)-BR*(cpf/cpt)*(T08-T02);
if (T05 <= 0.0)
   T05 = 0.0;
end
P05=P04*(1-(1-T05/T04)/nt)^(gammat/(gammat-1.0));
if ABon
   h05=cp5*T05;
   T06=Tab;
   cpAB=gammaab*R/(gammaab-1.0);   %specific heat afert burner
   fab=(1+f)*(T06-T05)/(Qr/cpab-T06);
else
   T06=T05;
   fab=0;
end
P06=nab*P05;
T07=T06;
P07=P06;
P06_Pc=(1-(1/nn)*(gamman-1)/(gamman+1))^(gamman/(gamman-1));
P06_Pc=1/P06_Pc;
P06_Pa=P06/Patm;
P7=Patm;
T7=T06*(1-nn*(1-(Patm/P06)^((gamman-1.0)/gamman)));
ce=sqrt(gamman*R*T7);
ue=sqrt(2.0*nn*(gamman/(gamman-1.0))*R*T06*(1-(Patm/P06)^((gamman-1.0)/gamman)));
Me=ue/ce;

%Calculate Performance Metrics
st=(1+f+fab)*(ue)-V+BR*(uef-V)+(1+f)*(P7-Patm)/(ue*P7/(R*T7)); %specfic thrust
tsfc=(f+fab)/st;	%Trust Specific Fuel Consumption
KEMA=0.5*(1+f+fab)*ue^2-0.5*V^2+0.5*BR*(uef^2-V^2); %KEMA
ettap=st*V/KEMA;	%Propulsive efficiency
ettath=KEMA/((f+fab)*Qr);	%Thermal Efficiency
ettao=ettap*ettath;	%Overall Efficiency
Thrust = 8000;
area_in = Thrust/(st*rhoAtm*V);

fuel_flow = f * (rhoAtm * V * area_in);

rho_exit = P06 / (R * T7);
area_out = (fuel_flow + (rhoAtm * V * area_in)) / (rho_exit * ue); % check this
end