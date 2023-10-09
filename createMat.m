% Create .mat File
% Commented out since DEMs.mat exists in git
elev = imread("SLDEM2015_512_30S_00S_315_360.JP2");
slope = imread("SLDEM2015_512_SL_30S_00S_315_360.JP2");
save("DEMs.mat");