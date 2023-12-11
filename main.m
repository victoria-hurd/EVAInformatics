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
    coord12055 = [336.573,-3.0115]; % Measured by hand from figure 1 - North Head Crater
    coord12052 = [336.571,-3.01384]; % Measured by hand from figure 1 - West Head Crater
    coord12040 = [336.570, -3.018]; % Measured by hand from figure 1 - NW Bench Crater
    coord12024 = [336.565,-3.0205]; % Measured by hand from figure 1 - E Sharp Crater
    coord12041 = [336.572,-3.02024]; % Measured by hand from figure 1 - E Bench Crater
    coordVec = [coord12055;coord12052;coord12040;coord12024;coord12041];
    % User input for selected points
%     coordVec = user_fed_POI();
    
    %% Get Map Data Centered on the POIs (Points of Interrest)
%     Get center and radius that encompasses all points automatically with 1.5 scale out   
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
    OGPOIs = POIs;
   
    
    %% Walkthrough.m

    % Set initial conditions for replanning
    replanFlag = 1; % When this is set = 0, our path doesnt exceed any thresholds and we are done
    penalty = 0.99; % This affects the cost associated with sloped cells, iteratively increase it if we need to penalize them more
    pathHistory = {}; % This is where we store all of the paths we generated
    endPoseHistory = []; % This is where we store the indices of where we end each path (where a threshold was exceeded)
    
    % While we are still walking the path and could need more replanning
    while replanFlag == 1

        % Create the Cost Matrix
        cost_matrix = create_cost_matrix(X, Y, Z_slope, penalty);

        % If we need to penalize slope more
        if penalty > 1

            % Update POI list - our next path only needs to hit the POIs we
            % haven't visited yet

            % Update path history
            pathHistory{end+1} = path; % the path we were on when we exceeded a threshold
            endPoseHistory = [endPoseHistory;endPoseIdx]; % the point we made it to on that path
    
            % Check what ROIs we've visited
            POIcounter = 1;
            while 1

                % Find index of POI i
                poiX = path(:,1) == POIs(POIcounter,1);
                poiY = path(:,2) == POIs(POIcounter,2);
                poiIdx = find(and(poiX,poiY));
                
                % Check if we had visited that POI yet
                % If we hadn't then retain that and all subsequent POIs for
                % next path
                if poiIdx > endPoseIdx
                    POIs = [endPose;POIs(POIcounter:end,:)]; 
                    break
                % If we had visited it, check the next POI in the list
                else
                    % add to counter
                    POIcounter = POIcounter+1;
                end
            end
        end

        % Get new path between POIs using updated POI list
        [path, pathIdx, updated_cost_matrix] = create_path(POIs, X, Y, Z_slope, cost_matrix);
        [replanFlag,goHomeFlag,endPose,endPoseIdx] = walkthrough(path, pathIdx,updated_cost_matrix);
        penalty = penalty + 0.01;
        if mean(goHomeFlag) ~= 0
            % If we have a go home flag (remember size(goHomeFlag) = [2,1]
            % then only plan from endPose to last POI
            POIs = [endPose;POIs(end,:)];
        end
    end

    % Update path history - add last path visited (that didn't require a
    % replan) to the path history plot
    pathHistory{end+1} = path;


    %% Path History Plot
    elev_matrix_color = gray;
    elev_matrix_color = elev_matrix_color*0.8; 
    plot_path_history(X, Y, Z_elevation, OGPOIs, pathHistory, endPoseHistory, elev_matrix_color, "Elevation [Meters]");

    % %% Plot Simple
    % cost_matrix_color = flip(gray,1) * 0.8;
    % cost_matrix_color(end, :) = [1, 0, 0];
    % plot_path_simple(X, Y, updated_cost_matrix, OGPOIs, path, cost_matrix_color, "Cost Map [Normalized with bounds]");
    % 
    % % Create custom colormap and Plot Elevation
    % elev_matrix_color = gray;
    % elev_matrix_color = elev_matrix_color*0.8;  
    % plot_path_simple(X, Y, Z_elevation, OGPOIs, path, elev_matrix_color, "Elevation [Meters]");
    % 
    % % Plot Slope
    % plot_path_simple(X, Y, Z_slope, OGPOIs, path, flip(gray,1), "Slope [Degrees]");
    % 
    % %% Plot Moving Along Path
    % % Plot Interactive Vizualization
    % plot_path_full_view(X, Y, Z_elevation, OGPOIs, path, elev_matrix_color, "Elevation [Meters]");
end