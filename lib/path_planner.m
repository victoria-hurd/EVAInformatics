% Erin Richardson, Victoria Hurd, Nicole Futch
%% Make a cost map 
function [refPath, costmap] = path_planner(Z_slope,costMatrix,startPose,goalPose)
% Normalize costmatrix from 0 to 1
costMatrix = flip(costMatrix, 1); % flip is afix for row axis of latitude being inverted based on how pathPlannerRRT needs to use them
% Use normalized costMatrix to make a costmap
%costmap = vehicleCostmap(costMatrix); % Commented out to implement
% functionality, see below for new costmap definition

% figure
% hold on 
% plot(costmap)
% scatter(startPose(:,1),startPose(:,2),'filled')
% scatter(goalPose(:,1),goalPose(:,2),'filled')
% hold off
% Set occupancy and free threshold
% costmap.OccupiedThreshold = double(20/max(Z_slope,[],'all'));
% costmap.FreeThreshold = double(20/max(Z_slope,[],'all'));

% Rearranged script to add in vehicle dimensions, did not delete anything
% Vechile dimension definition: must force overhang values
vdims = vehicleDimensions(0.6,0.7,1.8,'FrontOverhang',0.1, 'RearOverhang',0.1); 
ccConfig = inflationCollisionChecker(vdims, 'InflationRadius', 0);

% Cost map definition and attributes
costmap = vehicleCostmap(costMatrix,'CollisionChecker',ccConfig);
costmap.CollisionChecker.InflationRadius = 0; % Set inflation radius to 0
costmap.OccupiedThreshold = double(0.99);
costmap.FreeThreshold = double(0.99);

% turning radius value of 1 meter
planner = pathPlannerRRT(costmap, 'MinTurningRadius',1); % Includes minimum 


%% Plan a path
refPath = plan(planner,startPose, goalPose);
isValid = checkPathValidity(refPath,costmap); % add error if statement here
end