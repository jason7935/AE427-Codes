clear
clc

bypass_ratio = linspace(0,20,40);
compression_ratio = linspace(1,5,20);
combustion_temp = linspace(1600,2300,100);

tsfc = zeros(length(bypass_ratio),length(compression_ratio),length(combustion_temp));
areaIn = zeros(size(tsfc));
areaOut = zeros(size(tsfc));
fuelFlow = zeros(size(tsfc));

for x = 1:length(bypass_ratio)
    for y = 1:length(compression_ratio)
        for z = 1:length(combustion_temp)
            [tsfc(x,y,z), areaIn(x,y,z), fuelFlow(x,y,z), areaOut(x,y,z)] = calc(bypass_ratio(x), compression_ratio(y), combustion_temp(z));
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
%% Search
while(true)
    disp("Searching...")

    minDiameter = min(diameter(:));
    maxDiameter = max(diameter(:));
    
    minFuelFlow = min(fuelFlow(:));
    maxFuelFlow = max(fuelFlow(:));
    
    normDiameter = 1 - (diameter - minDiameter) ./ (maxDiameter - minDiameter);
    normFuelFlow = 1 - (fuelFlow - minFuelFlow) ./ (maxFuelFlow - minFuelFlow);

    weighted = (normFuelFlow * 0.60) + (normDiameter .* 0.40);
    
    [~, linearIndex] = max(weighted(:));
    [x, y, z] = ind2sub(size(weighted), linearIndex);

    discard = false;

    % Check for pesky imaginary solutions or NaN values over the corresponding combustion range
    for idx = 1:length(combustion_temp)
        if isnan(diameter(x,y,idx))
            discard = true;
            break
        end
    end

    areaInIdeal = pi * diameter(x,y,z)^2 / 4;

    alts = linspace(0,13000,27);
    thrustAtAlt = zeros(length(alts), length(combustion_temp));
    fuelFlowAtAlt = zeros(length(alts), length(combustion_temp));
    for k = 1 : length(alts)
        [thrustAtAlt(k, :), fuelFlowAtAlt(k, :)] = calc2(bypass_ratio(x), compression_ratio(y), combustion_temp, areaInIdeal, alts(k));
        for idx = 1 : length(combustion_temp)
            if isnan(thrustAtAlt(k, idx)) || imag(thrustAtAlt(k, idx))
                discard = true;
                break
            end
        end
        if discard
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
        

        figure(1)        
        subplot(1,2,1)
        cmap = jet(length(alts));
        %altitude_labels = cell(1, 3);
        %legend_handles = [];
        for k = 1 : length(alts)
            if ismember(alts(k), [0, 7500, 13000])
                h = plot(thrustAtAlt(k, :)./1000, combustion_temp, 'Color', cmap(k, :), 'LineWidth', 3);
                %legend_handles = [legend_handles, h];
                %altitude_labels{find([0, 7500, 13000] == alts(k))} = sprintf('Altitude %dm', alts(k));
            else
                %plot(combustion_temp, thrustAtAlt(k, :), 'Color', cmap(k, :), 'LineWidth', 1);
                plot(thrustAtAlt(k, :)./1000, combustion_temp, 'Color', cmap(k, :), 'LineWidth', 1, 'LineStyle', '--');
            end
            
            hold on;
        end
        h_operating_point = plot(8, combustion_temp(z), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
        %legend_handles = [legend_handles, h_operating_point];
        %altitude_labels = [altitude_labels, {'Design Point'}];
        %legend(legend_handles, altitude_labels);
        %xlabel('Combustion Temperature (K)');
        xlabel('Thrust (kN)', 'FontSize', 16);
        %title('Thrust vs. Combustion Temperature at Different Altitudes');
        grid on;
        ylabel('Combustion Temperature (K)', 'FontSize', 16);

        subplot(1, 2, 2);      
        cmap = jet(length(alts));
        altitude_labels = cell(1, 3);
        legend_handles = [];
        for k = 1 : length(alts)
            if ismember(alts(k), [0, 7500, 13000])
                h = plot(fuelFlowAtAlt(k, :), combustion_temp, 'Color', cmap(k, :), 'LineWidth', 3);
                legend_handles = [legend_handles, h];
                altitude_labels{find([0, 7500, 13000] == alts(k))} = sprintf('%.1f km', alts(k) ./ 1000);
            else
                plot(fuelFlowAtAlt(k, :), combustion_temp, 'Color', cmap(k, :), 'LineWidth', 1, 'LineStyle', '--');
            end
            
            hold on;
        end
        h_operating_point = plot(fuelFlow(x,y,z), combustion_temp(z), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
        legend_handles = [legend_handles, h_operating_point];
        altitude_labels = [altitude_labels, {'Design Point'}];
        legend(legend_handles, altitude_labels);
        %xlabel('Combustion Temperature (K)');
        xlabel('Fuel Mass Flow Rate (kg/s)', 'FontSize', 16);
        %title('Fuel Mass Flow Rate vs. Combustion Temperature at Different Altitudes');
        grid on;

        sgtitle('Thrust and Fuel Mass Flow Rate vs. Combustion Temperature at Different Altitudes', 'FontSize', 16, 'FontWeight', 'bold');

        break
    else
        for idx = 1:length(combustion_temp)
            diameter(x,y,idx) = NaN;
        end
    end
end