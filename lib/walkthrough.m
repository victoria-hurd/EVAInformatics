% Vicki/Erin time script

function [replanFlag,endPose] = walkthrough(path, pathIdx,updated_cost_matrix)
%% Constants
% https://history.nasa.gov/alsj/a11/a11.gaits.html#:~:text=During%20Apollo%2015%2C%20researchers%20in,sec%20during%20the%20second%20EVA
v = 2.2/3.6; % [km/hr]*[m/s]
% https://www.lpi.usra.edu/lunar/tools/lunardistancecalc/
coord2m = 30.28*1000; % [m]
HRthreshold = 110; % [bpm]

%% Initial Path
path1 = path(1:end-1,:);
path2 = path(2:end,:);
dists = sqrt((path1(:,1)-path2(:,1)).^2+(path1(:,2)-path2(:,2)).^2);
dists = dists*coord2m;

%% Collect time vector
t = cumsum(dists)*v;
t = [0;t];

%% Vital Estimator
[hr, o2, co2] = vital_estimator(updated_cost_matrix);
pathIdx = floor(pathIdx);
%pathHR = hr(pathIdx(:,1),pathIdx(:,2));
pathHR = zeros(length(pathIdx),1);
for i=1:length(pathIdx)
    pathHR(i)=hr(pathIdx(i,1),pathIdx(i,2));
end

%% Plot HR
figure
hold on 
grid minor
plot(t(1:end-1),pathHR)
ylim([60 180])
yline(110)
hold off

%% Threshold Flag
badHR = find(pathHR>HRthreshold);
if isempty(badHR)
   replanFlag = 0;
   endPose = nan;
else
    replanFlag = 1;
    endPose = path(badHR(1),:);
end

end
