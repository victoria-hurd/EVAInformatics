%% monitor_co2_produciton
% <Description>
%
% Inputs
%    co2_produciton: <unit?>

% Outputs
%    co2_produciton_criticality_level: 1 - [3] ([3] being the higest criticality) 

function [co2_produciton_criticality_level] = monitor_co2_produciton(co2_produciton)    %%% The following is just an example. Please Complete
     %% The following is just an example. Please Complete
    co2_produciton_criticality_level = 1;
    if co2_produciton > 20
        co2_produciton_criticality_level = 2;
    end

end