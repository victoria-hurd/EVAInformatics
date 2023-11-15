%% get_map_data_all
% This function returns the map data for NAC_DTM_APOLLO12 around a
% centerpoint and scale factors.
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
%
% Inputs
%    X_Center = Longitude center point of map to return 
%    Y_Center = Lattidue center point of map to return 
%    width_coords = Degres Longitude
%    height_coords = Degres Longitude

% Outputs

%    Z_elevation = floating point value for elevatoin in meters 
%    Z_slope = matrix of slope (degrees)
function [X, Y, Z_elevation, Z_slope] = get_map_data_all()
    %% Load .mat
    t = Tiff("data/NAC_DTM_APOLLO12.tiff",'r');
    imageData = read(t);
    imageData(imageData < -1000000000) = NaN; % out of bound data needs to be marked NaN

    %% Constants
%     pixel_resolution = 2; % meters / pixel
    min_lat = -3.05226826;
    max_lat = -2.96217267;
    min_long = 336.45205417;
    max_long = 336.61505963;
    
    lat_delta = max_lat - min_lat;
    long_delta = max_long - min_long;

    % LatDelta / length(imageData)
    num_lats = length(imageData(:,1));
    num_longs = length(imageData(1,:));
    lat_resolution = lat_delta/num_lats;
    long_resolution = long_delta/num_longs;
    
    lat = max_lat:-lat_resolution:(min_lat + lat_resolution);
    long = min_long:long_resolution:(max_long - long_resolution);       

    %% Generate Meshgrid aroudn center point and height and width    
    X_start_idx = 1;
    Y_start_idx = 1;
    X_end_idx = length(long);
    Y_end_idx = length(lat);

    % Generate Meshgrid and Z axis window
    Z_elevation = imageData(Y_start_idx:Y_end_idx, X_start_idx:X_end_idx);
    [Z_slope_X, Z_slope_Y] = gradient(Z_elevation); %get the x and y components of the gradient
    Z_slope = atand(sqrt(Z_slope_X.^2 + Z_slope_Y.^2)); % get the normalized gradient and take the arc tan to get degrees
    [X,Y] = meshgrid(long(X_start_idx:X_end_idx),lat(Y_start_idx:Y_end_idx));
    
%     Return Value
%     [X, Y, Z_elevation, Z_slope];
end