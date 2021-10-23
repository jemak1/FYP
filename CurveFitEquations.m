%load('RSSIdata2.mat');
RSSI_A1 = zmesh1;
RSSI_A2 = zmesh2;
for i = 1:17
    for j = 1:29
        if RSSI_A1(i,j) == 0 
            RSSI_A1(i,j) = NaN; %does not account for zeros in equation fitting
        end
        if RSSI_A2(i,j) == 0 
            RSSI_A2(i,j) = NaN; %does not account for zeros in equation fitting
        end
    end
end

dmesh_edit = dmesh;
distance_A1 = dmesh1;
distance_A2 = dmesh2;

%Uses Curve Fitting Tool to calculate equations based on distance and RSSI
cftool(distance_A1, RSSI_A1)
cftool(distance_A2, RSSI_A2)
s1 = surf(x, y, zmesh1);
hold on
s2 = surf(x, y, zmesh2);
colormap hsv
view(30, 40);
shading flat
xlabel('Distance in the x-direction (cm)', 'FontSize', 12);
ylabel('Distance in the y-direction (cm)', 'FontSize', 12);
title('Received Signal Strength Indicator from Antenna', 'FontSize', 20)
