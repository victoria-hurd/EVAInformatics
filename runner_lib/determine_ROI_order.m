function [ROIs, startPoses, goalPoses] = determine_ROI_order(coordVec)
    % Use SolveTSP to solve traveling salesman problem
    % Provide SolveTSP coordinates of multiple ROI as well as your start and end
    % points
    % Ensure your starting point is the first coordinate pair
    % Ensure your ending point is the last coordinate pair
    % The ROI (in between) doesn't matter
    [ROIOrder] = SolveTSP(coordVec);
    
    % Make entire angle column zero since we don't care about astronaut
    % orientation
    coordVec(:,3) = 0;
%     
%    % Use output to define the start and goal poses
    startPoses = coordVec(ROIOrder(1:end-1),:);
    goalPoses = coordVec(ROIOrder(2:end),:);
    
    ROIs =  coordVec(ROIOrder,:);
        
end