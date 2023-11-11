% Erin Richardson, Victoria Hurd
%% Make a cost map 
function [refPath, costmap] = pathPlanner(Z_slope,costMatrix,startPose,goalPose)
% Normalize costmatrix from 0 to 1
costMatrix = normalize(costMatrix,'range');
% Use normalized costMatrix to make a costmap, including vehicle dimensions
% vehicleDims = vehicleDimensions(0.6,0.7,1.8);
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
% set vehicle dimensions with new syntax
%vehicleDims = vehicleDimensions(2.2,0.6,1.5,'FrontOverhang',0.37,'RearOverhang',0.32); % height may not be necessary
%ccConfig = inflationCollisionChecker(vehicleDims);
%costmap = vehicleCostmap(costmap,'CollisionChecker',ccConfig);

planner = pathPlannerRRT(costmap); %,'MinTurningRadius',0.1); % Includes min turning...
% radius value of _ meters

%% Plan a path
refPath = plan(planner,startPose, goalPose);
isValid = checkPathValidity(refPath,costmap); % add error if statement here
end