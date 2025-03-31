function [Mmin,Mmax] = MD2MachNumbers(d,Tmax,Qf,gamma,R,Ta,Pa,rhoa)

% Minimum Mach Number
M = 1.5; % Initial Guess
dM = 0.005;
while true
    Drag = MD2DragFunction(d,M,gamma,R,Ta,rhoa);
    
    [Thrust,~,~] = MD2ThrustFunction(d,M,Tmax,Qf,gamma,R,Ta,Pa,rhoa);

    Drag1 = MD2DragFunction(d,M+dM,gamma,R,Ta,rhoa);
    Drag2 = MD2DragFunction(d,M-dM,gamma,R,Ta,rhoa);

    [Thrust1,~,~] = MD2ThrustFunction(d,M+dM,Tmax,Qf,gamma,R,Ta,Pa,rhoa);
    [Thrust2,~,~] = MD2ThrustFunction(d,M-dM,Tmax,Qf,gamma,R,Ta,Pa,rhoa);

    F = Thrust - Drag;

    dForce = ((Thrust1 - Drag1) - (Thrust2 - Drag2))/(2*dM);

    Mnew = M - (F/dForce);

    if abs(Mnew - M) < 0.01
        Mmin = Mnew;
        break
    else
        M = Mnew;
    end
end
% Mmax = 0;

M = 5; % Initial Guess
while true
    Drag = MD2DragFunction(d,M,gamma,R,Ta,rhoa);
    [Thrust,~,~] = MD2ThrustFunction(d,M,Tmax,Qf,gamma,R,Ta,Pa,rhoa);

    Drag1 = MD2DragFunction(d,M+dM,gamma,R,Ta,rhoa);
    Drag2 = MD2DragFunction(d,M-dM,gamma,R,Ta,rhoa);

    [Thrust1,~,~] = MD2ThrustFunction(d,M+dM,Tmax,Qf,gamma,R,Ta,Pa,rhoa);
    [Thrust2,~,~] = MD2ThrustFunction(d,M-dM,Tmax,Qf,gamma,R,Ta,Pa,rhoa);

    F = Thrust - Drag;

    dForce = ((Thrust1 - Drag1) - (Thrust2 - Drag2))/(2*dM);

    Mnew = M - (F/dForce);

    if abs(Mnew - M) < 0.01
        Mmax = Mnew;
        break
    else
        M = Mnew;
    end
end