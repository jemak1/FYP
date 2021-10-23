clear all; close all; clc;


%Sets up the directory
D = 'C:\Users\jakem\Documents\CSLReader\exp6';
S = dir(fullfile(D,'*'));
N = setdiff({S([S.isdir]).name},{'.','..'}); % list of subfolders
N = sort_nat(N, 'ascend');
N = [sort_nat(N(1:14), 'descend') N(15:29)];
a = linspace(-42,42,29); %initialises x values
%Initialisation of grids
zmesh1 = zeros(17, 29);
zmesh2 = zeros(17, 29);
dmesh = zeros(17,29);
dmesh1 = zeros(17,29);
dmesh2 = zeros(17,29);
%Initialisation of figures
f = figure;
f2 = figure;

for ii = 1:numel(N)
T = dir(fullfile(D,N{ii},'*'));
fPath = T(1).folder; % filepath
cd(fPath) % points to the directory
fNames = dir('*.csv'); % extracts the .csv files
fileNamesArray = cell(1,numel(fNames)); % get the excel file names 
j = 1; % counter for inner for loop 

for i = 1:numel(fNames)
   fileNamesArray{i} = fNames(i).name; % gets the file names in the directory
   [excelStatus,excelSheets] = xlsfinfo(fNames(i).name); % provides list of .csv file names
   
   for k = 1:numel(excelSheets)
   [num,txt,raw] = xlsread(fNames(i).name,excelSheets{k}); % reads each .csv 
   size(raw);

   if size(raw) <= [1 1]
       myStoredData{i,1} = 0; % assigns RSSI = 0 to undetectable measurements
   else
        myStoredData{i,1} = raw(:,5); % stores the RSSI values
        myStoredData{i,2} = raw(:,7); % stores the antenna port reference
        j = j+1;
   end
   end   
end 

last = length(myStoredData);
RSSI_means = zeros(2, last); %starts from the second column, excludes title

for i = 1:last
    count = 1;
    count2 = 1;
    sd = myStoredData(i, :);
    %if less than four readings in the measurement, the point is defaulted
    %to zero RSSI
    if size(cell2mat(sd{1}(2:length(sd{1}),1))) <= [4 1]
        RSSI_means(i) = 0;
    else
        for n = 2:length(sd{2})
            if (cell2mat(sd{2}(n,1))) == 0
                %Sums the RSSIs for antenna 0
                RSSI_means(1,i) = ((cell2mat(sd{1}(n,1)))+RSSI_means(1,i));
                count = count+1;
            elseif (cell2mat(sd{2}(n,1))) == 1
                %Sums the RSSIs for antenna 1
                RSSI_means(2,i) = ((cell2mat(sd{1}(n,1)))+RSSI_means(2,i));
                count2 = count2+1;
            end
        end
        %Take the average of the sum of RSSIs
        RSSI_means(1,i) = RSSI_means(1,i)/count;
        RSSI_means(2,i) = RSSI_means(2,i)/count2;
    end
end

if (contains(fPath, string(a(ii))))
    %set up the allocated x and y coordinates for the RSSI readings
    figure(f);
    view(-37.5,50);
    title('Range', 'FontSize', 24);
    origin = [a(ii) 49];
    x = linspace(origin(1), origin(1), length(RSSI_means));
    y = linspace(origin(2), 1, length(RSSI_means));
end

%Assigns RSSI to the z axis for each antenna
z = RSSI_means;
zmesh1(:, ii) = z(1,:);
zmesh2(:, ii) = z(2,:);

%Creates a mesh grid for the x and y coordinates
[x, y] = meshgrid(a, y);

%Displays results for antenna 0
figure(f);
s1 = surf(x, y, zmesh1);
colormap summer
shading flat
xlabel('Distance in the x-direction (cm)', 'FontSize', 14);
ylabel('Distance in the y-direction (cm)', 'FontSize', 14);
zlabel('RSSI (dB)');
title('Antenna 1: RSSI v distance', 'FontSize', 20)
hold on

%Displays results for antenna 1
figure(f2);
s2 = surf(x, y, zmesh2);
colormap summer
shading flat
xlabel('Distance in the x-direction (cm)', 'FontSize', 14);
ylabel('Distance in the y-direction (cm)', 'FontSize', 14);
zlabel('RSSI (dB)');
title('Antenna 2: RSSI v distance', 'FontSize', 20)
hold on

%Calculates distance values for each coordinate from the origin
for i = 1:17
    dmesh(i, ii) = sqrt((x(1,ii)^2)+(49-3*(i-1))^2);
end
%Calculates distance values for each coordinate from antenna 0
for i = 1:17
    dmesh1(i, ii) = sqrt(((x(1,ii)-21.5)^2)+(49-3*(i-1))^2);
end
%Calculates distance values for each coordinate from the antenna 1
for i = 1:17
    dmesh2(i, ii) = sqrt(((x(1,ii)+21.5)^2)+(49-3*(i-1))^2);
end

%Clears the RSSI values for this iteration
clear myStoredData;

end
