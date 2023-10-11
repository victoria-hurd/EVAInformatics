%% Make a cost map 

% Define parameters
startPose = [400,400,0];
goalPose = [500,500,0];

% Assign cost values to a cost matrix
% Right now the only input to cost is Z_slope
% Eventually we will add in physio, etc
costMatrix = Z_slope;
costMatrix = normalize(costMatrix);

% Use costMatrix to make a costmap
costmap = vehicleCostmap(costMatrix);
planner = pathPlannerRRT(costmap);

%% Plan a path
refPath = plan(planner,startPose, goalPose);
isValid = checkPathValidity(refPath,costmap);
figure; plot(planner)