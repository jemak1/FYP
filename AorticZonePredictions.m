load('RSSIdata2.mat');

syms d x y

%Equation 1 coefficients
p1 = -0.0001378;
p2 = 0.014;
p3 = -0.7892;
p4 =  84.86;

%Equation 2 coefficients
p1_2 =  -0.0002682;
p2_2 = 0.02724;
p3_2 = -1.091;
p4_2 =  84.28;

%Allocates zone numbers to the grid of coordinates {0,1,2,3,4} where 4
%represents below zone 3
zonecheck = zeros(17,29);
zonecheck(:,1:11) = 4;
zonecheck(:,12:14) = 3;
zonecheck(:,15:16) = 2;
zonecheck(:,17:20) = 1;
zonecheck(9:17,21:29) = 1;
zonecheck(1:8,21:29) = 0;
match = zeros(17,29); %

zones = zeros(17, 29);
[nrows, ncols] = size(zmesh1);

%Iterates through each position on the grid
for i = 1:nrows
    for j = 1: ncols
        RSSI1 = zmesh1(i,j);
        RSSI2 = zmesh2(i,j);
        %Solves for distance given RSSI reading of antenna 0
        eq1 = p1*d^3+p2*d^2+p3*d+p4 == RSSI1;
        d1 = vpasolve(eq1, d, [-100 100]);
        %Solves for distance given RSSI reading of antenna 1
        eq2 = p1_2*d^3+p2_2*d^2+p3_2*d+p4_2 == RSSI2;
        d2 = vpasolve(eq2, d, [-100 100]);
        %Solves simultaneous equations given distances from both antennas for x and y coordinates
        ad1 = sqrt((x-(21.5))^2+(y-(0))^2) - d1 == 0;
        ad2 = sqrt((x+(21.5))^2+(y-(0))^2) - d2 == 0;
        coord = solve([ad1, ad2], [x, y]);
        xsol = double(subs(coord.x));
        ysol = double(subs(abs(coord.y)));
        %Determines the aortic zone given x and y coordinates
        if xsol(1) < -10.5
            %fprintf('WARNING: BELOW ZONE 3, MOVE FORWARD');
            zones(i, j) = 4;
        elseif (0 > xsol(1)) && (xsol(1) >= -10.5)
            %fprintf('ZONE 3');
            zones(i, j) = 3;
        elseif (4.7 > xsol(1)) && (xsol(1) >= 0)
            %fprintf('ZONE 2');
            zones(i, j) = 2;
        elseif (17 > xsol(1)) && (xsol(1) >= 4.7)
                %fprintf('ZONE 1');
                zones(i, j) = 1;
        else
            if ysol > 25
                %fprintf('ZONE 1');
                zones(i, j) = 1;
            else
                %fprintf('WARNING: ZONE 0, MOVE BACKWARD');
                zones(i, j) = 0;
            end
        end
        if zones(i,j) == zonecheck(i,j)
            match(i,j) = 1; %Correct prediction is allocated '1' for the position
        else
            match(i,j) = 0; %Inorrect prediction is allocated '0' for the position
        end
    end
end
%Converts accuracies to percentage of each zone and displays them
accuracy = sum(match(match==1))/(17*29);
fprintf('Overall accuracy is %.2f%%\n', accuracy*100);
accuracy4 = sum(match(match(:,1:11)==1))/(17*11);
fprintf('Accuracy for below Zone 3 is %.2f%%\n', accuracy4*100);
accuracy3 = sum(match(match(:,12:14)==1))/(17*3);
fprintf('Accuracy for Zone 3 is %.2f%%\n', accuracy3*100);
accuracy2 = sum(match(match(:,15:16)==1))/(17*2);
fprintf('Accuracy for Zone 2 is %.2f%%\n', accuracy2*100);
accuracy1 = (sum(match(match(:,17:20)==1))+sum(match(match(9:17,21:29)==1)))/(17*4+9*9);
fprintf('Accuracy for Zone 1 is %.2f%%\n', accuracy1*100);
accuracy0 = sum(match(match(1:8,21:29)==1))/(8*9);
fprintf('Accuracy for Zone 0 is %.2f%%\n', accuracy0*100);
