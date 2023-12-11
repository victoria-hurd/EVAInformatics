% Vicki/Erin time script

function [replanFlag,goHomeFlag,endPose,endPoseIdx] = walkthrough(path, pathIdx,updated_cost_matrix)
%% Constants

% Assign constant walking velocity
v = 2.2/3.6; % [km/hr]*[m/s] ---- source: https://history.nasa.gov/alsj/a11/a11.gaits.html#:~:text=During%20Apollo%2015%2C%20researchers%20in,sec%20during%20the%20second%20EVA

% Switch from longitude degrees to meters to find distance
coord2m = 30.28*1000; % [m] --- source: https://www.lpi.usra.edu/lunar/tools/lunardistancecalc/

% Specify HR threshold that requires path replan
HRthreshold = 110; % [bpm] (arbitrarily chosen for now to get interesting results)
% Specify O2 threshold that requires path replan
O2threshold = 0.7; % [g/min] (arbitrarily chosen for now to get interesting results)
% Specify CO2 threshold that requires path replan
CO2threshold = 0.7; % [g/min] (arbitrarily chosen for now to get interesting results)

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
    pathO2(i)= o2(pathIdx(i,1),pathIdx(i,2));
    pathCO2(i)= co2(pathIdx(i,1),pathIdx(i,2));
end

%% Plot HR, CO2, and O2 vs time
figure
if length(t)>length(pathHR)
    subplot(3,1,1);
    hold on
    grid minor
    title('Heart Rate over Planned Path')
    xlabel('Moving Time [sec]')
    ylabel('Heart Rate [bpm]')
    plot(t(1:end-1),pathHR)
    ylim([80 160])
    yline(HRthreshold, '-r')
    hold off

    subplot(3,1,2);
    hold on
    grid minor
    title('O2 Levels over Planned Path')
    xlabel('Moving Time [sec]')
    ylabel('O2 Level [g/min]')
    plot(t(1:end-1),pathO2)
    yline(O2threshold, '-r')
    hold off

    subplot(3,1,3);
    hold on
    grid minor
    title('CO2 Levels over Planned Path')
    xlabel('Moving Time [sec]')
    ylabel('CO2 Level [g/min]')
    plot(t(1:end-1),pathCO2)
    yline(CO2threshold, '-r')
    hold off
else
    subplot(3,1,1);
    hold on
    grid minor
    title('Heart Rate over Planned Path')
    xlabel('Moving Time [sec]')
    ylabel('Heart Rate [bpm]')
    plot(t,pathHR)
    ylim([60 180])
    yline(HRthreshold, '-r')
    hold off

    subplot(3,1,2);
    hold on
    grid minor
    title('O2 Levels over Planned Path')
    xlabel('Moving Time [sec]')
    ylabel('O2 Level [g/min]')
    plot(t,pathO2)
    yline(O2threshold, '-r')
    hold off

    subplot(3,1,3);
    hold on
    grid minor
    title('CO2 Levels over Planned Path')
    xlabel('Moving Time [sec]')
    ylabel('CO2 Level [g/min]')
    plot(t,pathCO2)
    yline(CO2threshold, '-r')
    hold off
end

%% Heart Rate Threshold Flag
% Check if any thresholds were ever exceeded
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

%% Go Home Threshold Flag
% Check to see if we need to go home based on current path
badO2 = find(pathO2>O2threshold);
badCO2 = find(pathCO2>CO2threshold);

% Create goHome flag - O2 flag is element 1, CO2 flag is element 2
goHomeFlag = nan(2,1);
% If we need to go home, flag it and flag the reason why
if ~isempty(badO2) && ~isempty(badCO2)
    if ~isempty(badO2)
        goHomeFlag(1) = 1;
    else
        goHomeFlag(1) = 0;
    end

    if ~isempty(badCO2)
        goHomeFlag(2) = 1;
    else
        goHomeFlag(2) = 0;
    end
else
    % If not out of bounds, do nothing!
    goHomeFlag = 0;
end

end
