% Aaron Weinberg
% EVA Informatics
% Apollo 12 2m Slope Data

% https://pds.lroc.asu.edu/data/LRO-L-LROC-5-RDR-V1.0/LROLRC_2001/DATA/SDP/NAC_DTM/APOLLO12/NAC_DTM_APOLLO12_README.TXT
% - Products are tied to LOLA elevations with RMS error of 1.31 m to 19.0 different LOLA orbit tracks.
%   The RMS error is the root-mean-square of the elevation difference between the LOLA points and the DTM. This value
%   is a combination of error from the LOLA points and the DTM, and may give a measure of the horizontal and vertical
%   accuracy of the DTM.
% - The reported precision error from SOCET SET is 0.8 m.
% - SOCET SET NGATE v5.5 was used to extract terrain.
% - Post spacing in DTM is 2.0 m.
% - DTM start time: 2010-02-05 10:34:26 and DTM stop time: 2010-02-05 12:28:05.
% - DTM extents:
%    Min. Lat.: -3.05226826
%    Min. Lon.: 336.45205417
%    Max. Lat.: -2.96217267
%    Max. Lon.: 336.61505963

%% Housekeeping
clear; clc;% close all

%% Load .mat
t = Tiff("./data_2m/NAC_DTM_APOLLO12.tiff",'r');
imageData = read(t);
imageData(imageData < -1000000000) = NaN; % out of bound data needs to be marked NaN



%% Constants
pixel_resolution = 2; %meters / pixel
minLat = -3.05226826;
maxLat = -2.96217267;
minLong = 336.45205417;
maxLong = 336.61505963;
LEMcoord = [360-23.41930,-3.01381]; % Using the Adjusted Coordinates https://history.nasa.gov/alsj/alsjcoords.html
ALSEPcoord = [360-23.42456,-3.01084]; % Using the Adjusted Coordinates https://history.nasa.gov/alsj/alsjcoords.html

% For dimensions centered around Apollo 12 LEM
Radius = 5000; %meters
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
legend("Apollo 12 Lunar Module", "Apollo 12 ALSEP")
h = surf(X, Y, Z_elevation);
set(h,'LineStyle','none')
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
title("Apollo 12 Landing Site")
xlabel("Longitude [deg]")
ylabel("Latitude [deg]")
axis equal
axis tight
c = colorbar;
c.Label.String = "Elevation [Meters]";
c.Label.Rotation = 270;
c.Label.VerticalAlignment = "bottom";
hold off

% Plotting Slope
figure
hold on 
scatter(LEMcoord(1),LEMcoord(2),"filled","red")
scatter(ALSEPcoord(1),ALSEPcoord(2),"filled","blue")
legend("Apollo 12 Lunar Module", "Apollo 12 ALSEP")
h = surf(X, Y, Z_slope);
set(h,'LineStyle','none')
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
title("Apollo 12 Landing Site")
xlabel("Longitude [deg]")
ylabel("Latitude [deg]")
axis equal
axis tight
c = colorbar;
c.Label.String = "Slope [deg]";
c.Label.Rotation = 270;
c.Label.VerticalAlignment = "bottom";
hold off
