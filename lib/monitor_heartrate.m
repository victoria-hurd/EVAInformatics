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
    if heartrate < 70
        heartrate_criticality_level = 1; %lower heart rate
    elseif heartrate >= 70 && heartrate <= 170
                heartrate_criticality_level = 2; %within the ranges of a target heartrate
    else heartrate_criticality_level = 3; %approaching and achieving max HR (175 bpm for a 45 year old)
    
    end

end
