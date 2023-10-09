% AUTHOR: Victoria Hurd
% PROJECT: EVA Informatics
% PURPOSE: Data formatting script. This script will take the two DEM files
% and turn them into a Matlab-usable format. 

% Read in DEM files
elev = imread("SLDEM2015_512_30S_00S_315_360.JP2");
slope = imread("SLDEM2015_512_SL_30S_00S_315_360.JP2");
% Create .mat File
save("./data/DEMs.mat");