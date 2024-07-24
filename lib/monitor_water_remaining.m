%% monitor_water_remaining
% <Description>
%
% Inputs
%    water_remaining: <unit?>

% Outputs
%    water_remaining_criticality_level: 1 - [3] ([3] being the higest criticality)

function [water_remaining_criticality_level] = monitor_water_remaining(water_remaining)
    %% The following is just an example. Please Complete
    water_remaining_criticality_level = 1;
    if water_remaining < 15
        water_remaining_criticality_level = 2;
    end

end