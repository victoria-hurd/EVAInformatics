%% main_runner
%  Main Runner Script
%  Gathers input map data
%  determines POI order 
%  creates a predicted cost map
%  creates path between ROIs factoring in the cost map
%  Creates a vizualization for traversing the path with alerts displayed
%  from physiolical monitoring

function main()
    %% Housekeeping
    addpath('lib/');

    clear; clc;
    all_fig = findall(0, 'type', 'figure');
    close(all_fig)
 
    %% Regions of Interest (ROIs)
    LEMcoord = [360-23.41930,-3.01381]; % Using the Adjusted Coordinates https://history.nasa.gov/alsj/alsjcoords.html
    ALSEPcoord = [360-23.42456,-3.01084]; % Using the Adjusted Coordinates https://history.nasa.gov/alsj/alsjcoords.html
    % Numbering for each POI is from https://an.rsl.wustl.edu/apollo/mainnavsp.aspx?tab=map&m=A12
%     coord12004 = [336.569,-3.00706]; % Measured by hand from figure 1 - Middle Crescent Crater
    % Note these have been re hand measured    
    coord12055 = [336.573,-3.0115]; % Measured by hand from figure 1 - North Head Crater
    coord12052 = [336.571,-3.01384]; % Measured by hand from figure 1 - West Head Crater
    coord12040 = [336.570, -3.018]; % Measured by hand from figure 1 - NW Bench Crater
    coord12024 = [336.565,-3.0205]; % Measured by hand from figure 1 - E Sharp Crater
    coord12041 = [336.572,-3.02024]; % Measured by hand from figure 1 - E Bench Crater
    coordVec = [coord12055;coord12052;coord12040;coord12024;coord12041];
    

    %% Get Map Data Centered on the POIs (Points of Interrest)
    %Get center and radius that encompasses all points automatically with 1.5 scale out   
    Scale_factor = 1.8;
    center_X = (min(coordVec(:,1)) + max(coordVec(:,1)))/2;
    center_Y = (min(coordVec(:,2)) + max(coordVec(:,2)))/2;    
    width_coords = abs(center_X - min(coordVec(:,1))) * Scale_factor;
    height_coords = abs(center_Y - min(coordVec(:,2))) * Scale_factor;

    [X, Y, Z_elevation, Z_slope] = get_map_data(center_X, center_Y,  width_coords, height_coords);
    
    %% Determining POI Order
    %Normalize coordinats to the 2m input grid so that the path is on POIs
    X_POI = interp1(X(1,:),X(1,:),coordVec(:,1),'nearest');
    Y_POI = interp1(Y(:,1),Y(:,1),coordVec(:,2),'nearest');
    coordVec = [X_POI, Y_POI];
       
    % Solve Traveling Salesman Problem
    POIOrder = solve_TSP(coordVec);
    POIs = coordVec(POIOrder,:);
    
    %% Create the Cost Matrix
    cost_matrix = create_cost_matrix(X, Y, Z_slope);
    
    %% Get Path between ROIs
    [path, updated_cost_matrix] = create_path(POIs, X, Y, Z_slope, cost_matrix);
    
    %% Plot Moving Along Path
    % TODO: integrate physio monitoring alerts.  show one or the other
    % Blood pressure, Heart Rate, O2 Concentration
    % O2 levels, suit pressure, suit temp, suit battery (if available)
    % alert should have 2-4 lines of info per window. Left justified. Is
    % there text included or a criticality indication? 

    % Create custom colormap and Plot Elevation
    elev_matrix_color = gray;
    elev_matrix_color = elev_matrix_color*0.8;  
%     plot_path_full_view(X, Y, Z_elevation, POIs, path, elev_matrix_color, "Elevation [Meters]");


    % Create custom colormap and Plot Cost Matrix
    cost_matrix_color = flip(gray,1) * 0.8;
    cost_matrix_color(end, :) = [1, 0, 0];
    plot_path_full_view(X, Y, updated_cost_matrix, POIs, path, cost_matrix_color, "Cost Map [Normalized with bounds]");
    
    % Plot Slope
    plot_path_full_view(X, Y, Z_slope, POIs, path, flip(gray,1), "Slope [Degrees]");
    
end