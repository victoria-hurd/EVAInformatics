%% get_path
% This function take in a set of ROIs, and outputs paths between them.
% Units should be in latitude longitude decimal formats the same as the
%% input map file.
%
% Inputs
%    ROIs = [X_coordinates, Y_Coordinates]
%    X = [X_coordinates, X_coordinates] created with meshgrid 
%    Y = [Y_coordinates, Y_coordinates] created with meshgrid  
%    Z_slope = matrix of slope (degrees)
%    cost_matrix = floating point values of the same dimensions as Z_slope
%
% Outputs
%    path = [X_coordinates, Y_Coordinates]

function path = create_path(ROIs, X, Y, Z_slope, cost_matrix)
%% Creating Cost Function
    % Normalize entire matrix
    cost_matrix = normalize(cost_matrix,'range');

    % Set cells with slopes above 20deg to Occupied
    cost_matrix(Z_slope > 20) = 0.999;

    X_ROI_idx = interp1(X(1,:),1:length(X(1,:)),ROIs(:,1),'nearest');    
    Y_ROI_idx = interp1(Y(:,1),1:length(Y(:,1)),ROIs(:,2),'nearest');
    
    ROI_idx = [X_ROI_idx, Y_ROI_idx];
    ROI_idx(:,3) = 0; % consider of RRT uses this as it may create extra turns at the beginning and end of each path
    
    startPoses = ROI_idx(1:end-1, :);
    goalPoses = ROI_idx(2:end, :);
%% Iterate over ROI
    paths = struct;
    for i=1:height(startPoses)
        [newPath,~] = pathPlanner(Z_slope, cost_matrix, startPoses(i,:), goalPoses(i,:));
        paths.(['Path' int2str(i)]) = newPath;
    end
    [~,planner] = pathPlanner(Z_slope, cost_matrix, startPoses(1,:), goalPoses(1,:));
    pathNames = fieldnames(paths);
    
    segments = length(pathNames);
    path_steps = zeros(segments,1);
    
    for i=1:segments
        path_steps(i) = length(paths.(pathNames{i}).PathSegments);
    end
        
    N= sum(path_steps);
    X_pos = zeros(N,1);
    Y_pos = zeros(N,1);

    step_idx = 1;
    for segment = 1:segments
        for i= 1:path_steps(segment)
            X_pos(step_idx) = paths.(pathNames{segment}).PathSegments(i).StartPose(1);
            Y_pos(step_idx) = paths.(pathNames{segment}).PathSegments(i).StartPose(2);
            step_idx = step_idx + 1;
        end
    end

    X_pos = interp1(1:length(X(1,:)), X(1,:), X_pos,'linear');
    Y_pos = interp1(1:length(Y(:,1)), Y(:,1), Y_pos,'linear');

    path = [X_pos, Y_pos];

end