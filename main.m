% Victoria Hurd & Aaron Weinberg
% EVA Informatics
% Main Script

%% Housekeeping
clear; clc;% close all

% %% Load .mat
% 
% 
% %% Constants
% resolution = 0.001953125;
% minLat = -30;
% maxLat = 0;
% minLong = 315;
% maxLong = 360;
% LEMcoord = [360-23.41930,-3.01381]; % Using the Adjusted Coordinates https://history.nasa.gov/alsj/alsjcoords.html
% 
% % For dimensions centered around Apollo 12 LEM
% Height = 500;
% Width = 1000;
% 
% %% Generate Meshgrid
% % Generate axes
% lat = maxLat:-resolution:(minLat+resolution);
% long = minLong:resolution:(maxLong-resolution);
% 
% %find the index on our axes for the LEM
% long_LEM_idx = interp1(long,1:length(long),LEMcoord(1),'nearest');
% lat_LEM_idx = interp1(lat,1:length(lat),LEMcoord(2),'nearest');
% 
% X_start_idx = long_LEM_idx-Width;
% X_end_idx = long_LEM_idx+Width;
% Y_start_idx = lat_LEM_idx-Height;
% Y_end_idx = lat_LEM_idx+Height;
% 
% % Protect for the axes window going out of bounds of our input file
% if X_start_idx < 1
%     X_start_idx = 1;
% end
% if Y_start_idx < 1
%     Y_start_idx = 1;
% end
% if X_end_idx > length(long)
%     X_end_idx = length(long);
% end
% if Y_end_idx > length(lat)
%     Y_end_idx = length(lat);
% end
% 
% % Generate Meshgrid and Z axis window
% Z_elevation = elev(Y_start_idx:Y_end_idx, X_start_idx:X_end_idx);
% Z_slope = slope(Y_start_idx:Y_end_idx, X_start_idx:X_end_idx);
% [X,Y] = meshgrid(long(X_start_idx:X_end_idx),lat(Y_start_idx:Y_end_idx));

%% Load .mat
t = Tiff('./data_2m/NAC_DTM_APOLLO12.tiff','r');
imageData = read(t);
imageData(imageData < -1000000000) = NaN; % out of bound data needs to be marked NaN

%% Constants
pixel_resolution = 2; % meters / pixel
minLat = -3.05226826;
maxLat = -2.96217267;
minLong = 336.45205417;
maxLong = 336.61505963;
LEMcoord = [360-23.41930,-3.01381]; % Using the Adjusted Coordinates https://history.nasa.gov/alsj/alsjcoords.html
ALSEPcoord = [360-23.42456,-3.01084]; % Using the Adjusted Coordinates https://history.nasa.gov/alsj/alsjcoords.html
% Numbering for each POI is from https://an.rsl.wustl.edu/apollo/mainnavsp.aspx?tab=map&m=A12
%coord12004 = [336.569,-3.00706]; % Measured by hand from figure 1 - Middle Crescent Crater
coord12055 = [336.573,-3.01233]; % Measured by hand from figure 1 - North Head Crater
coord12052 = [336.572,-3.01384]; % Measured by hand from figure 1 - West Head Crater
coord12040 = [336.570, -3.01938]; % Measured by hand from figure 1 - NW Bench Crater
coord12024 = [336.565,-3.0205]; % Measured by hand from figure 1 - E Sharp Crater
coord12041 = [336.571,-3.02024]; % Measured by hand from figure 1 - E Bench Crater
coordVec = [coord12055;coord12052;coord12040;coord12024;coord12041];
%% Auto-Centering
% For dimensions centered around Apollo 12 LEM
Radius = 1000; % meters - (temporary fix: decreased this from 5000 to 1000 to avoid NaNs that were present along the outsides of the map)
Height = Radius / pixel_resolution;
Width = Radius / pixel_resolution;
LatDelta = maxLat - minLat;
LongDelta = maxLong - minLong;
% LatDelta / length(imageData)
numLats = length(imageData(:,1));
numLongs = length(imageData(1,:));
latResolution = LatDelta/numLats;
LongResolution = LongDelta/numLongs;
%% Generate Meshgrid
% Generate axes
lat = maxLat:-latResolution:(minLat + latResolution);
long = minLong:LongResolution:(maxLong - LongResolution);
% find the index on our axes for the LEM
long_LEM_idx = interp1(long,1:length(long),LEMcoord(1),'nearest');
lat_LEM_idx = interp1(lat,1:length(lat),LEMcoord(2),'nearest');
X_start_idx = long_LEM_idx-Width;
X_end_idx = long_LEM_idx+Width;
Y_start_idx = lat_LEM_idx-Height;
Y_end_idx = lat_LEM_idx+Height;
% Protect for the axes window going out of bounds of our input file
if X_start_idx < 1
    X_start_idx = 1;
end
if Y_start_idx < 1
    Y_start_idx = 1;
end
if X_end_idx > length(long)
    X_end_idx = length(long);
end
if Y_end_idx > length(lat)
    Y_end_idx = length(lat);
end
% Generate Meshgrid and Z axis window
Z_elevation = imageData(Y_start_idx:Y_end_idx, X_start_idx:X_end_idx);
[Z_slope_X, Z_slope_Y] = gradient(Z_elevation); %get the x and y components of the gradient
Z_slope = atand(sqrt(Z_slope_X.^2 + Z_slope_Y.^2)); % get the normalized gradient and take the arc tan to get degrees

[X,Y] = meshgrid(long(X_start_idx:X_end_idx),lat(Y_start_idx:Y_end_idx));

%% View
% Plotting Elevation
figure
hold on 
scatter(LEMcoord(1),LEMcoord(2),"filled","red")
legend("Apollo 12 Landing Site")
h = surf(X,Y,Z_elevation);
set(h,'LineStyle','none')
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
title("Lunar Elevation")
xlabel("Longitude [deg]")
ylabel("Latitude [deg]")
axis equal
axis tight
colorbar
hold off

% Plotting Slope
figure
hold on 
scatter(LEMcoord(1),LEMcoord(2),"filled","red")
legend("Apollo 12 Landing Site")
h = surf(X,Y,Z_slope);
set(h,'LineStyle','none')
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
title("Lunar Slope")
xlabel("Longitude [deg]")
ylabel("Latitude [deg]")
axis equal
axis tight
colorbar
hold off
