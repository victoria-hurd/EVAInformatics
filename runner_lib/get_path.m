%% get_path
% This function take in a set of ROIs, and outputs paths between them.
% Units should be in latitude longitude decimal formats the same as the
% input map file.
%
% Inputs
%    ROIs = [X_coordinates, Y_Coordinates]
%
% Outputs
%    path = [X_coordinates, Y_Coordinates]

function path = get_path(ROIs)
%% Replace The Temporary Solution Below With The output of the real path planning algorithm 
%   .
%   .
%   .
%   .

%% Temporary Solution: Straight line paths between ROIs for vizualization demo
    num_ROIs = length(ROIs);
    segments = num_ROIs - 1;
    steps = zeros(segments,1);
    resolution = 6.6e-5; % 6.6e-5 is about than 2m or the pixel resolution of the map in coordinates
    
    % Vary this to move faster or slower along the path
    step_speed = 2;
    step_length = resolution*step_speed; 
    
    for segment = 1:segments
        d = norm(ROIs(segment, :) - ROIs(segment+1, :));
        steps(segment) = round(d / step_length);
    end
    
    N = sum(steps);    
    X_pos = zeros(N,1);
    Y_pos = zeros(N,1);
    
    step_idx = 1;
    for segment = 1:segments
        X_pos(step_idx: step_idx+steps(segment) -1) = linspace(ROIs(segment, 1),ROIs(segment+1, 1),steps(segment))';
        Y_pos(step_idx: step_idx+steps(segment) -1) = linspace(ROIs(segment, 2),ROIs(segment+1, 2),steps(segment))';
        step_idx = step_idx+steps(segment);
    end
    
    path = [X_pos, Y_pos];
end