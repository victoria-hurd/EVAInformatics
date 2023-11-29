%% monitor_o2_consumption
% <Description>
%
% Inputs
%    o2_consumption: <g/min>

% Outputs
%    o2_consumption_criticality_level: 1 - [3] ([3] being the higest criticality)

function [o2_consumption_criticality_level] = monitor_o2_consumption(o2_consumption)
    %% The following is just an example. Please Complete
    if o2_consumption < 0.59
        o2_consumption_criticality_level = 1; %low O2 levels
    elseif o2_consumption >= 3.99
        o2_consumption_criticality_level = 3; %high O2 levels
    else
        o2_consumption_criticality_level = 2; %Medium O2 levels

    end

end
