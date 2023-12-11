%% get_current_vital_consumables
% <Description>
%
% Inputs
%    X_current: Longitude Coordinate
%    Y_current: Lattitude Coordinate

% Outputs
%    heartrate: bpm
%    o2_consumption: <unit?>
%    co2_produciton: <unit?>
%    water_remaining: <unit?>


function [heartrate, o2_consumption, co2_produciton, water_remaining] = get_current_vitals_and_consumables(X_current, Y_current)
    %% Please Complete based on lookups into the vital_estimator matrices and a calculation for water remaining.
    heartrate = round(normrnd(180, 30));
    o2_consumption = round(normrnd(3.5, 1));
    co2_produciton = round(normrnd(4.5, 2));
    water_remaining = 0;
end