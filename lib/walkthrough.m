% Vicki/Erin time script

function [replanFlag,endPose,endPoseIdx] = walkthrough(path, pathIdx,updated_cost_matrix)
%% Constants

% Assign constant walking velocity
v = 2.2/3.6; % [km/hr]*[m/s] ---- source: https://history.nasa.gov/alsj/a11/a11.gaits.html#:~:text=During%20Apollo%2015%2C%20researchers%20in,sec%20during%20the%20second%20EVA

% Switch from longitude degrees to meters to find distance
coord2m = 30.28*1000; % [m] --- source: https://www.lpi.usra.edu/lunar/tools/lunardistancecalc/

% Specify HR threshold that requires path replan
HRthreshold = 148; % [bpm] (arbitrarily chosen for now to get interesting results)

%% Calculate distance of each path segment
path1 = path(1:end-1,:);
path2 = path(2:end,:);
% Store distances in dists
dists = sqrt((path1(:,1)-path2(:,1)).^2+(path1(:,2)-path2(:,2)).^2);
% Convert to meters
dists = dists*coord2m;

%% Collect time vector
% Calculate time elapsed at each step
t = cumsum(dists)*v;
% Add 0 for time at starting point
t = [0;t];

%% Vital Estimator
% Use vital_estimator() to find HR, O2, CO2 associated with each cell in
% the cost map
[hr, o2, co2] = vital_estimator(updated_cost_matrix);

% Step through each segment of the path and store the associated HR in
% pathHR
pathIdx = floor(pathIdx);
pathHR = zeros(length(pathIdx),1);
for i=1:length(pathIdx)
    pathHR(i)=hr(pathIdx(i,1),pathIdx(i,2));
end

%% Plot HR vs time
figure
hold on 
grid minor
if length(t)>length(pathHR)
    plot(t(1:end-1),pathHR)
else
    plot(t,pathHR)
end
ylim([60 180])
yline(110)
hold off

%% Threshold Flag
% Check if the HR threshold was ever exceeded
badHR = find(pathHR>HRthreshold);

% If not, no need to replan, set flag to 0 and finish
if isempty(badHR)
   replanFlag = 0;
   endPose = nan;
   endPoseIdx = nan;
% If it was, set flag for replanning. Save end pose and end pose index to
% begin next path at
else
    replanFlag = 1;
    endPose = path(badHR(1),:);
    endPoseIdx = badHR(1);
end

end
