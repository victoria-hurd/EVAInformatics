% Erin Richardson, Victoria Hurd
%% Make a cost map 
function [refPath, costmap] = path_planner(Z_slope,costMatrix,startPose,goalPose)
% Normalize costmatrix from 0 to 1
costMatrix = flip(normalize(costMatrix,'range'), 1); % flip is afix for row axis of latitude being inverted based on how pathPlannerRRT needs to use them
% Use normalized costMatrix to make a costmap
costmap = vehicleCostmap(costMatrix);
% figure
% hold on 
% plot(costmap)
% scatter(startPose(:,1),startPose(:,2),'filled')
% scatter(goalPose(:,1),goalPose(:,2),'filled')
% hold off
% Set occupancy and free threshold
% costmap.OccupiedThreshold = double(20/max(Z_slope,[],'all'));
% costmap.FreeThreshold = double(20/max(Z_slope,[],'all'));
costmap.OccupiedThreshold = double(0.99);
costmap.FreeThreshold = double(0.99);
% Set inflation radius to 0
costmap.CollisionChecker.InflationRadius = 0;
planner = pathPlannerRRT(costmap);

%% Plan a path
refPath = plan(planner,startPose, goalPose);
isValid = checkPathValidity(refPath,costmap); % add error if statement here
end