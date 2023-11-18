%% monitor_o2_consumption
% <Description>
%
% Inputs
%    o2_consumption: <unit?>

% Outputs
%    o2_consumption_criticality_level: 1 - [3] ([3] being the higest criticality)

function [o2_consumption_criticality_level] = monitor_o2_consumption(o2_consumption)
    %% The following is just an example. Please Complete
    o2_consumption_criticality_level = 1;
    if o2_consumption > 35
        o2_consumption_criticality_level = 2;
    end

end