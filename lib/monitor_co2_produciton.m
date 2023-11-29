%% monitor_co2_production
% <Description>
%
% Inputs
%    co2_production: <unit?>

% Outputs
%    co2_production_criticality_level: 1 - [3] ([3] being the higest criticality) 

function [co2_production_criticality_level] = monitor_co2_production(co2_production)    
     %% The following is just an example. Please Complete
    if co2_production <= 0.69
        co2_production_criticality_level = 1;
    elseif co2_production >= 5.22
        co2_production_criticality_level = 3;
    else
        co2_production_criticality_level = 2;
    end

end
