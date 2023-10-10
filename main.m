% Victoria Hurd & Aaron Weinberg
% EVA Informatics
% Main Script

%% Housekeeping
% clear; clc;% close all

%% Load .mat
% load("./data/DEMs.mat")

%% Constants
resolution = 0.001953125;
minLat = -30;
maxLat = 0;
minLong = 315;
maxLong = 360;
LEMcoord = [360-23.3856,-3.1975];

% For dimensions centered around Apollo 12 LEM
Height = 1000;
Width = 2000;

%% Generate Meshgrid
% Generate axes
lat = maxLat:-resolution:(minLat+resolution);
long = minLong:resolution:(maxLong-resolution);

%find the index on our axes for the LEM
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
Z_elevation = elev(Y_start_idx:Y_end_idx, X_start_idx:X_end_idx);
Z_slope = slope(Y_start_idx:Y_end_idx, X_start_idx:X_end_idx);
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
