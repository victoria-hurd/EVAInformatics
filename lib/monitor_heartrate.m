%% monitor_heartrate
% <Description>
%
% Inputs
%    heartrate: bpm

% Outputs
%    heartrate_criticality_level: 1 - [3] ([3] being the higest criticality)

function [heartrate_criticality_level] = monitor_heartrate(heartrate)
    %% The following is just an example. Please Complete
    heartrate_criticality_level = 1;
    if heartrate > 140
        heartrate_criticality_level = 2;
    end

end