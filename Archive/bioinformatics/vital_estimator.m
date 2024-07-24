function [hr, o2, co2] = vital_estimator(M)
% vital_estimator.m
%
% Author: Luca Bonarrigo
%
% Created: 11/15/2023
% Last edited: 11/17/2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Determine Metabolic Workload Level (MWL)
% low workload: <1000 kJ/h
% medium workload: <3000 kJ/h
% high workload >3000 kJ/h

% preallocate matrix space
N = size(M);
MWL = zeros(N);
hr = zeros(N);
o2 = zeros(N);
co2 = zeros(N);

% for each metabolic rate value in M, calculate the level of load
for i=1:(N(1)*N(2))
    if M(i) < 1000
        MWL(i) = 1;
    elseif M(i) > 3000
        MWL(i) = 3;
    else
        MWL(i) = 2;
    end 
end

%% Assign initial HR, O2 consumption, and CO2 production values based on MWL
% find indices in array for each MWL 
i_1 = find(MWL==1);
i_2 = find(MWL==2);
i_3 = find(MWL==3);

% define heart rate reserve using Karvonen equation, based on 45 y/o w/ RHR=70 bpm
% max heart rate for 45 year old = 220-45=175
rhr = 72+randn*4; % resting heart rate, std = 4bpm, avg = 72 bpm
hrr_lo = 175-rhr; % low intensity activity [bpm]
hrr_med = 175-rhr; % medium intensity activity [bpm]
hrr_hi = 175-rhr;  % high intensity activity [bpm]

% define o2 consumption averages based on Ewart et al
o2_lo = 0.59; % low intensity activity [g/min]
o2_med = 1.43; % medium intensity activity [g/min]
o2_hi = 3.99; % high intensity activity [g/min]

% define co2 production averages based on Ewart et al
o2_lo = 0.69; % low intensity activity [g/min]
o2_med = 1.89; % medium intensity activity [g/min]
o2_hi = 5.22; % high intensity activity [g/min]

%% Fill in matrix with averages modified by Gaussian noise
for i=1:length(i_1) % low level metabolic rate
    hr(i_1(i)) = (rand*0.1+0.3)*hrr_lo+rhr; % light intensity exercise = 30-40% HRR
    o2(i_1(i)) = o2_lo+(randn*0.15*o2_lo); % 15% std dev 
    co2(i_1(i)) = co2_lo+(randn*0.02*co2_lo); % 2% std dev;;
end

for i=1:length(i_2)  % medium level metabolic rate 
    hr(i_2(i)) = (rand*0.2+0.4)*hrr_med+rhr; % light intensity exercise = 40-60% HRR
    o2(i_2(i)) = o2_med+(randn*0.15*o2_med); % 15% std dev 
    co2(i_2(i)) = co2_med+(randn*0.02*co2_med); % 2% std dev;;
end

for i=1:length(i_3)  % high level metabolic rate
    hr(i_3(i)) = (rand*0.3+0.6)*hrr_hi+rhr; % light intensity exercise = 60-90% HRR
    o2(i_3(i)) = o2_hi+(randn*0.15*o2_hi); % 15% std dev;
    co2(i_3(i)) = co2_hi+(randn*0.02*co2_hi); % 2% std dev;;
end