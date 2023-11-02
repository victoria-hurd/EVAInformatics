% Aaron Weinberg, Erin Richardson, Victoria Hurd
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

% the below are based on element numbers, not degrees
coord12055 = [384,530]; % Measured by hand from figure 1 - North Head Crater
coord12052 = [353,490]; % Measured by hand from figure 1 - West Head Crater
coord12040 = [341, 427]; % Measured by hand from figure 1 - NW Bench Crater
coord12024 = [275,387]; % Measured by hand from figure 1 - E Sharp Crater
coord12041 = [365,402]; % Measured by hand from figure 1 - E Bench Crater
coordVec = [coord12055;coord12024;coord12040;coord12052;coord12041];


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

%% Determining ROI Order

% Use SolveTSP to solve traveling salesman problem
% Provide SolveTSP coordinates of multiple ROI as well as your start and end
% points
% Ensure your starting point is the first coordinate pair
% Ensure your ending point is the last coordinate pair
% The ROI (in between) doesn't matter
[ROIOrder] = SolveTSP(coordVec);

% Make entire angle column zero since we don't care about astronaut
% orientation
coordVec(:,3) = 0;
% Change coordVec to include the indices
% Change this output to be the element numbers in X and Y instead of coords
[N,M] = size(Z_slope);
% Index into longitudes
%coordVecInd(:,1) = round(N*(coordVec(:,1)-long(X_start_idx))/(long(X_end_idx)-long(X_start_idx)));
% Index into latitudes
%coordVecInd(:,2) = round(M*(coordVec(:,2)-lat(Y_start_idx))/(lat(Y_end_idx)-lat(Y_start_idx)));
% Make entire angle column zero since we don't care about astronaut
% orientation
coordVec(:,3) = 0;
% Use output to define the start and goal poses
startPosesInd = coordVec(ROIOrder(1:end-1),:);
goalPosesInd = coordVec(ROIOrder(2:end),:);
startPoses = coordVec(ROIOrder(1:end-1),:);
goalPoses = coordVec(ROIOrder(2:end),:);

%% Creating Cost Function
% Assign cost values to a cost matrix

% Load and normalize metabolic rate costs
load('MR.mat');
% MR = normalize(MR,'range');

% Add MR costs to Z_slope costs
%costMatrix = MR + normalize(Z_slope,'range');
costMatrix = MR;

% Normalize entire matrix
costMatrix = normalize(costMatrix,'range');

% Set cells with slopes above 20deg to Occupied
costMatrix(Z_slope > 20) = 0.999;

%% Iterate over ROI
paths = struct;
for i=1:height(startPoses)
    [newPath,~] = pathPlanner(Z_slope, costMatrix, startPoses(i,:), goalPoses(i,:));
    paths.(['Path' int2str(i)]) = newPath;
end
[~,planner] = pathPlanner(Z_slope, costMatrix, startPoses(1,:), goalPoses(1,:));
pathNames = fieldnames(paths);

%% Plot results
figure;
plot(planner);
hold on;
for i=1:length(pathNames)
    plot(paths.(pathNames{i})); hold on;
end

% Improving plot
title('Planned Paths for Apollo 12 EVA #2','FontSize',16);
xlabel('Longitude','FontSize',16);
ylabel('Latitude','FontSize',16);

% Fix axes
longlabel = long(X_start_idx:X_end_idx);
latlabel = lat(Y_start_idx:Y_end_idx);

 longlabel = longlabel(20:20:end);
 latlabel = latlabel(20:20:end);
 xticks(1:20:1000)
 xticklabels(longlabel);
 yticks(1:20:1000)
 yticklabels(latlabel);

 xlim([225 525]);
 ylim([300 600]);

 % Fix legend
 % This is a quick way to do this for CDR? Plot nans with the same colors?
qw{1} = plot(nan, 'Color', [0 0.4470 0.7410],'LineWidth',3);
qw{2} = plot(nan, 'Color', [0.9290 0.6940 0.1250],'LineWidth',3);
qw{3} = plot(nan, 'Color', [0.4940 0.1840 0.5560],'LineWidth',3);
qw{4} = plot(nan, 'Color', [0.4660 0.6740 0.1880],'LineWidth',3); % You can add an extra element too
legend("Slope >20\circ","Path 1","Path 2","Path 3","Path 4", "location", "northeast")
hold off


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
view(2)
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
colormap turbo
c = colorbar;
c.Label.String = "Slope [deg]";
c.Label.Rotation = 270;
c.Label.VerticalAlignment = "bottom";
view(2)
hold off
