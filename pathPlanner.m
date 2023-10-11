% Erin Richardson, Victoria Hurd
%% Make a cost map 
function [planner] = pathPlanner(Z_slope,costMatrix,startPose,goalPose)
% Define parameters
% startPose = [300,300,0];
% goalPose = [400,400,0];

% Normalize from 0 to 1
costMatrix = normalize(costMatrix,'range');

% Use costMatrix to make a costmap
costmap = vehicleCostmap(costMatrix);
% Set occupancy threshold
costmap.OccupiedThreshold = double(20/max(Z_slope,[],'all'));
costmap.FreeThreshold = double(20/max(Z_slope,[],'all'));
planner = pathPlannerRRT(costmap);

%% Plan a path
refPath = plan(planner,startPose, goalPose);
isValid = checkPathValidity(refPath,costmap); % add error if statement here
end