% Aaron Weinberg
% EVA Informatics
% Apollo 14 2m Slope Data

% https://pds.lroc.asu.edu/data/LRO-L-LROC-5-RDR-V1.0/LROLRC_2001/DATA/SDP/NAC_DTM/APOLLO14/NAC_DTM_APOLLO14.LBL

%% Housekeeping
clear; clc;% close all

%% Load .mat
t = Tiff("NAC_DTM_APOLLO14.tif",'r');
imageData = read(t);
imageData(imageData < -1000000000) = NaN; % out of bound data needs to be marked NaN



%% Constants
pixel_resolution = 2; %meters / pixel
minLat = -3.9130241;
maxLat = -2.9632609;
minLong = 342.4716194 ;
maxLong = 342.6140152 ;
LEMcoord = [360-17.47139,-3.64544]; % Using the Adjusted Coordinates https://history.nasa.gov/alsj/alsjcoords.html
ALSEPcoord = [360-17.47753,-3.64450]; % Using the Adjusted Coordinates https://history.nasa.gov/alsj/alsjcoords.html

% For dimensions centered around Apollo 14 LEM
Radius = 1000; %meters
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

[X,Y] = meshgrid(long(X_start_idx:X_end_idx), lat(Y_start_idx:Y_end_idx));
%% View
% Plotting Elevation
figure
hold on 
scatter(LEMcoord(1),LEMcoord(2),"filled","red")
scatter(ALSEPcoord(1),ALSEPcoord(2),"filled","blue")
legend("Apollo 14 Lunar Module", "Apollo 14 ALSEP")
h = surf(X, Y, Z_elevation);
set(h,'LineStyle','none')
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
title("Apollo 14 Landing Site")
xlabel("Longitude [deg]")
ylabel("Latitude [deg]")
axis equal
axis tight
c = colorbar;
c.Label.String = "Elevation [Meters]";
c.Label.Rotation = 270;
c.Label.VerticalAlignment = "bottom";
view(2)
hold off

% Plotting Slope
figure
hold on 
scatter(LEMcoord(1),LEMcoord(2),"filled","red")
scatter(ALSEPcoord(1),ALSEPcoord(2),"filled","blue")
legend("Apollo 14 Lunar Module", "Apollo 14 ALSEP")
h = surf(X, Y, Z_slope);
set(h,'LineStyle','none')
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
title("Apollo 14 Landing Site")
xlabel("Longitude [deg]")
ylabel("Latitude [deg]")
axis equal
axis tight
c = colorbar;
c.Label.String = "Slope [deg]";
c.Label.Rotation = 270;
c.Label.VerticalAlignment = "bottom";
view(2)
hold off
