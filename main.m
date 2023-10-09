% Victoria Hurd
% EVA Informatics
% Main Script

%% Housekeeping
clear; clc;% close all

%% Load .mat
load("./data/DEMs.mat")

%% Constants
resolution = 0.001953125;
minLat = -30;
maxLat = 0;
minLong = 315;
maxLong = 360;
LEMcoord = [360-23.3856,-3.1975];

%% Generate Meshgrid
% Generate axes
lat = minLat:resolution:maxLat;
long = minLong:resolution:maxLong;
% Generate plotting axes
% Eventualy these should be robust to different LEM locations - maybe we
% can interpolate to find the [m,n] index closest to LEMcoord and then add
% some latitude and longitude margin. For now though, we're plotting ~2000
% elements in the middle of lat that encompass the latitude of the LEM and
% ~5000 elements that encompass the longitude of the LEM. 
plotLat = lat(end-3000:end-1000);
plotLong = long(end-15000:end-10000);
plotDEM = double(DEM1(end-15000:end-10000,end-3000:end-1000));

%% View
% Plotting
figure
hold on 
scatter(LEMcoord(1),LEMcoord(2),"filled","red")
legend("Apollo 12 Landing Site")
h = surf(plotLong,plotLat,plotDEM);
set(h,'LineStyle','none')
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
title("Lunar Elevation")
xlabel("Longitude [deg]")
ylabel("Latitude [deg]")
axis equal
axis tight
colorbar
hold off
