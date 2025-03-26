function [Range] = MD2RangeFunction(d,Tmax,Qf,Mstart,mFuel,mRam,gamma,R,Ta,Pa,rhoa)
i = 1;
M(1) = Mstart;
a = sqrt(gamma*R*Ta); % Speed of Sound
dt = 0.5; % Seconds
Range = 0;
while true
    Drag = MD2DragFunction(d,M(i),gamma,R,Ta,rhoa);
    [Thrust,f,mdota] = MD2ThrustFunction(d,M(i),Tmax,Qf,gamma,R,Ta,Pa,rhoa);

    dF = Thrust - Drag; % Force Acting on Missile

    M(i+1) = M(i) + ((dF/mRam)*dt)/a; % New Mach Number
    Range = Range + (M(i+1) + M(i))/2*a*dt;

    dm = f*mdota*dt;
    mFuel = mFuel - dm;
    mRam = mRam - dm;

    if mFuel < 0
        break
    else
     i = i + 1;
    end
end