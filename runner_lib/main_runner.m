%% main_runner
%  Main Runner Script
%  Gathers input map data
%  determines POI order 
%  creates a predicted cost map
%  creates path between ROIs factoring in the cost map
%  Creates a vizualization for traversing the path with alerts displayed
%  from physiolical monitoring

function main_runner()
    %% Housekeeping
    clear; clc;
    all_fig = findall(0, 'type', 'figure');
    close(all_fig)
 
    %% Regions of Interest (ROIs)
    LEMcoord = [360-23.41930,-3.01381]; % Using the Adjusted Coordinates https://history.nasa.gov/alsj/alsjcoords.html
    ALSEPcoord = [360-23.42456,-3.01084]; % Using the Adjusted Coordinates https://history.nasa.gov/alsj/alsjcoords.html
    % Numbering for each POI is from https://an.rsl.wustl.edu/apollo/mainnavsp.aspx?tab=map&m=A12
    coord12004 = [336.569,-3.00706]; % Measured by hand from figure 1 - Middle Crescent Crater
    coord12055 = [336.573,-3.01233]; % Measured by hand from figure 1 - North Head Crater
    coord12052 = [336.572,-3.01384]; % Measured by hand from figure 1 - West Head Crater
    coord12040 = [336.570, -3.01938]; % Measured by hand from figure 1 - NW Bench Crater
    coord12024 = [336.565,-3.0205]; % Measured by hand from figure 1 - E Sharp Crater
    coord12041 = [336.571,-3.02024]; % Measured by hand from figure 1 - E Bench Crater
    coordVec = [coord12055;coord12052;coord12040;coord12024;coord12041];

    
    %% Get Map Data Centered on the POIs (Points of Interrest)
    %Get center and radius that encompasses all points automatically with 1.5 scale out   
    Scale_factor = 1.5;
    center_X = (min(coordVec(:,1)) + max(coordVec(:,1)))/2;
    center_Y = (min(coordVec(:,2)) + max(coordVec(:,2)))/2;    
    width_coords = abs(center_X - min(coordVec(:,1))) * Scale_factor;
    height_coords = abs(center_Y - min(coordVec(:,2))) * Scale_factor;

    [X, Y, Z_elevation, Z_slope] = get_map_data(center_X, center_Y,  width_coords, height_coords);

    %% Determining POI Order
    POIOrder = SolveTSP(coordVec);
    POIs = coordVec(POIOrder,:);
    
    %% Create the Cost Matric
    cost_matrix = create_cost_matrix(X, Y, Z_slope);
    
    %% Get Path between ROIs
    path = create_path(POIs, X, Y, Z_slope, cost_matrix);
    
    %% Plot Moving Along Path
    % TODO: integrate physio monitoring alerts.
    plot_evelation_path_full_view(X, Y, Z_elevation, POIs, path);
    
end