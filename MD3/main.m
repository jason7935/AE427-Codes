clear
clc

bypass_ratio = linspace(0,20,40);
compression_ratio = linspace(1,5,20);
combustion_temp = linspace(1600,2300,50);

tsfc = zeros(length(bypass_ratio),length(compression_ratio),length(combustion_temp));
areaIn = zeros(size(tsfc));
fuelFlow = zeros(size(tsfc));

for x = 1:length(bypass_ratio)
    for y = 1:length(compression_ratio)
        for z = 1:length(combustion_temp)
            [tsfc(x,y,z), areaIn(x,y,z), fuelFlow(x,y,z)] = calc(bypass_ratio(x), compression_ratio(y), combustion_temp(z));
            if imag(tsfc(x,y,z)) ~= 0 || isnan(tsfc(x,y,z))
                tsfc(x,y,z) = NaN;
            end
            if imag(areaIn(x,y,z)) ~= 0 || isnan(areaIn(x,y,z))
                areaIn(x,y,z) = NaN;
            end
            if imag(fuelFlow(x,y,z)) ~= 0 || isnan(fuelFlow(x,y,z))
                fuelFlow(x,y,z) = NaN;
            end
        end
    end 
end

diameter = sqrt(4 * areaIn / pi);

while(true)
    disp("Searching...")

    minDiameter = min(diameter(:));
    maxDiameter = max(diameter(:));
    
    minFuelFlow = min(fuelFlow(:));
    maxFuelFlow = max(fuelFlow(:));
    
    normDiameter = 1 - (diameter - minDiameter) ./ (maxDiameter - minDiameter);
    normFuelFlow = 1 - (fuelFlow - minFuelFlow) ./ (maxFuelFlow - minFuelFlow);

    weighted = (normFuelFlow * 0.75) + (normDiameter .* 0.25);
    
    [~, linearIndex] = max(weighted(:));
    [x, y, z] = ind2sub(size(weighted), linearIndex);

    discard = false;

    for idx = 1:length(combustion_temp)
        if isnan(diameter(x,y,idx))
            discard = true;
            break
        end
    end
    
    if(~discard)
        disp("Found Solution")
        fprintf("Idx: %d, %d, %d\n", x, y, z)
        fprintf("Best Diameter: %d\n", diameter(x,y,z))
        fprintf("Best Fuel Flow: %d\n", fuelFlow(x,y,z))
        fprintf("Ideal Bypass Ratio: %d\n", bypass_ratio(x))
        fprintf("Ideal Compression Ratio: %d\n", compression_ratio(y))
        fprintf("Ideal Combustion Temp: %d\n", combustion_temp(z))
        break
    else
        for idx = 1:length(combustion_temp)
            diameter(x,y,idx) = NaN;
        end
    end
end