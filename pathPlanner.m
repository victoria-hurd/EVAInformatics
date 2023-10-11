% Erin Richardson, Victoria Hurd
%% Make a cost map 
function [planner] = pathPlanner(Z_slope,costMatrix,startPose,goalPose)
% For debugging
%startPose = [350 350 0];
%goalPose = [400 400 0];
% Normalize costmatrix from 0 to 1
costMatrix = normalize(costMatrix,'range');
% Use normalized costMatrix to make a costmap
costmap = vehicleCostmap(costMatrix);
% Set occupancy and free threshold
costmap.OccupiedThreshold = double(20/max(Z_slope,[],'all'));
costmap.FreeThreshold = double(20/max(Z_slope,[],'all'));
% Set inflation radius to 0
costmap.CollisionChecker.InflationRadius = 0;
planner = pathPlannerRRT(costmap);
figure; plot(planner)
%% Plan a path
refPath = plan(planner,startPose(1,:), goalPose(1,:));
isValid = checkPathValidity(refPath,costmap); % add error if statement here
end