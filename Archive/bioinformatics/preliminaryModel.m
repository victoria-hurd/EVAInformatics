%% Preliminary Physio Model
% Author: Sarah Leary
% Date: 4 October 2023
% Purpose: 

close all;
clear;
clc;

%% %%%%%%%%%%%%%%%%%%%%%%% Santee's Model (2001) %%%%%%%%%%%%%%%%%%%%%%% %%

%% Constants
g = 1.62; %[m/s2] lunar gravity
d = 2; %[m] distance in one square
kc = 3.5; %[] muscle inefficiency factor, concentric
ke = 2.4; %[] muscle inefficiency factor, eccentric

%% Conversions
J2kcal = 0.000239; % multiply J by J2kcal to get kcal

%% Variables
% MASS?
m = 80+34.5; %[kg]

% velocity of locomotion
v = 1.34; %[m/s]

%% From simulation team
% slope data
load terrain_output.mat;

% converting to radians
alpha = deg2rad(Z_slope);

% size of the contour plot grid
grid_size = size(alpha);

%% Pre-allocating vectors
% Work due to level walking
W_level = zeros(grid_size);

% Work due to sloped (+ or -) walking
W_slope = zeros(grid_size);

%% Calculating Work over each square

for i = 1:grid_size(1)
    for j = 1:grid_size(2)

        % if level walking
        if alpha(i,j) == 0
            W_slope(i,j) = 0;

        % if inclined walking: W=PE=kc*mgh
        elseif alpha(i,j) >= 0
            W_slope(i,j) = kc*m*g*v*sin(alpha(i,j));

        % if declined walking: W=ke*mgh*(correction factor due to energy
        % being absorbed in muscles and in the joints)
        elseif alpha(i,j) <= 0
            W_slope(i,j) = ke*m*g*v*sin(alpha(i,j))*0.3^(abs(alpha(i,j))/7.65);
        end

        % level walking contribution
        W_level(i,j) = (3.28*m + 71.1) * (0.661*v*cos(alpha(i,j)) + 0.115);

    end
end

%% Metabolic Rate, USE THIS IN PATH PLANNING!!!!
MR = W_level + W_slope; %[J/s]
MR = MR*J2kcal*3600; %[kcal/hr]

%% Plotting Metabolic Rate
figure(1);
hold on;
minLevel = min(MR,[],'all');
maxLevel = max(MR,[],'all');
avgLevel = mean([minLevel maxLevel]);
levels = linspace(minLevel,maxLevel,8);
contourf(X,Y,MR,levels);
colorbar;


%% %%%%%%%%%%%%%%%% Testing Model %%%%%%%%%%%%%%%% %%
%% Mass
m_CDR = 76.4; %[kg] mass of CDR
m_LMP = 80.1;% [kg] mass of LMP
% m_s = 47.8; %[kg] mass of spacesuit
% m_CDR = m_CDR + m_s;
% m_LMP = m_LMP + m_s;

%% Data from Apollo 14 EVA-1
% net slope percent
slope_14EVA1 = [0 0 0];
% velocity of locomotion, m/s
v_14EVA1 = [.688 .765 .728]*1000/3600;
% metabolic rates of CDR and LMP, kcal/hr
MR1_14EVA1_ac = [248 321 285];
MR2_14EVA1_ac = [277 262 270];

%% Santee's Model - EVA 1

W1_slope_14EVA1 = zeros(1,length(slope_14EVA1));
W1_level_14EVA1 = zeros(1,length(slope_14EVA1));
W2_slope_14EVA1 = zeros(1,length(slope_14EVA1));
W2_level_14EVA1 = zeros(1,length(slope_14EVA1));

for i = 1:length(slope_14EVA1)
    % if level walking
    if slope_14EVA1(i) == 0
        W1_slope_14EVA1(i) = 0;
        W2_slope_14EVA1(i) = 0;

    % if inclined walking: W=PE=kc*mgh
    elseif slope_14EVA1(i) > 0
        W1_slope_14EVA1(i) = kc*m_CDR*g*v_14EVA1(i)*sin(slope_14EVA1(i));
        W2_slope_14EVA1(i) = kc*m_LMP*g*v_14EVA1(i)*sin(slope_14EVA1(i));

    % if declined walking: W=ke*mgh*(correction factor due to energy
    % being absorbed in muscles and in the joints)
    elseif slope_14EVA1(i) < 0
        W1_slope_14EVA1(i) = ke*m_CDR*g*v_14EVA1*sin(slope_14EVA1(i))*0.3^(slope_14EVA1(i)/7.65);
        W2_slope_14EVA1(i) = ke*m_LMP*g*v_14EVA1*sin(slope_14EVA1(i))*0.3^(slope_14EVA1(i)/7.65);
    end

    % level walking contribution
    W1_level_14EVA1(i) = (3.28*m_CDR + 71.1) * (0.661*v_14EVA1(i)*cos(slope_14EVA1(i)) + 0.115);
    W2_level_14EVA1(i) = (3.28*m_LMP + 71.1) * (0.661*v_14EVA1(i)*cos(slope_14EVA1(i)) + 0.115);
end

MR1_14EVA1 = W1_level_14EVA1 + W1_slope_14EVA1;
MR1_14EVA1 = MR1_14EVA1*J2kcal*3600; %[kcal/hr]
MR2_14EVA1 = W2_level_14EVA1 + W2_slope_14EVA1;
MR2_14EVA1 = MR2_14EVA1*J2kcal*3600; %[kcal/hr]

%% Correction Factor
% Norcross et al. (2010) level ambulation
% 12.3% and 21.2% so total 33.5%
MR1_14EVA1 = MR1_14EVA1 + MR1_14EVA1*0.4 + 100;
MR2_14EVA1 = MR2_14EVA1 + MR2_14EVA1*0.4 + 100;

%% Plotting Apollo 14 EVA 1 Modeled vs. Actual
figure(2);
hold on;
sgtitle('Metabolic Rates on Apollo 14 EVA-1');

subplot(1,2,1);
hold on;
grid minor;
plot(MR1_14EVA1,'o','Color','k','LineWidth',2);
plot(MR1_14EVA1_ac,'x','Color','#A2142F','MarkerSize',12,'LineWidth',2);
ylabel('MR, kcal/hr');
title('CDR');
hold off;

subplot(1,2,2);
hold on;
grid minor;
plot(MR2_14EVA1,'o','Color','k','LineWidth',2);
plot(MR2_14EVA1_ac,'x','Color','#7E2F8E','MarkerSize',12,'LineWidth',2)
ylabel('MR, kcal/hr');
title('LMP')
hold off;

%% Error EVA-1
err1_14EVA1 = abs(MR1_14EVA1-MR1_14EVA1_ac)./MR1_14EVA1_ac*100;
err2_14EVA1 = abs(MR1_14EVA1-MR2_14EVA1_ac)./MR2_14EVA1_ac*100;

figure(9);
hold on
grid on;
plot(err1_14EVA1,'o','Color','#A2142F','LineWidth',2);
plot(err2_14EVA1,'o','Color','#7E2F8E','LineWidth',2);
ylabel('Percent Error');
title('Percent Error of Model Estimation');
ylim([0 100])
hold off;

%% Data from Apollo 14 EVA-2
% net slope percent
slope_14EVA2= atan([2.6 -2.7 4.7 10.3 11.3 5.8 3.5 -13.8 -9.4 -3.4 0 4.5 -6.3]/100);
% velocity of locomotion, m/s
v_14EVA2 = [1.56 1.43 2.65 1.71 1.66 1.97 3.69 2.57 4.8 4.49 5.7 2.64 3.18]*1000/3600;
% metabolic rates of CDR and LMP, kcal/hr
MR1_14EVA2_ac = [142 192 241 343 376 456 244 238 314 323 282 268 305];
MR2_14EVA2_ac = [209 212 273 291 315 520 323 266 337 367 391 379 393];

%% Mass
m_CDR = 76.4; %[kg] mass of CDR
m_LMP = 80.1;% [kg] mass of LMP
m_s = 47.8; %[kg] mass of spacesuit
m_CDR = m_CDR + m_s;
m_LMP = m_LMP + m_s;

%% Santee's Model - EVA 2

W1_slope_14EVA2 = zeros(1,length(slope_14EVA2));
W1_level_14EVA2 = zeros(1,length(slope_14EVA2));
W2_slope_14EVA2 = zeros(1,length(slope_14EVA2));
W2_level_14EVA2 = zeros(1,length(slope_14EVA2));

for i = 1:length(slope_14EVA2)
    % if level walking
    if slope_14EVA2(i) == 0
        W1_slope_14EVA2(i) = 0;
        W2_slope_14EVA2(i) = 0;

    % if inclined walking: W=PE=kc*mgh
    elseif slope_14EVA2(i) > 0
        W1_slope_14EVA2(i) = kc*m_CDR*g*v_14EVA2(i)*sin(slope_14EVA2(i));
        W2_slope_14EVA2(i) = kc*m_LMP*g*v_14EVA2(i)*sin(slope_14EVA2(i));

    % if declined walking: W=ke*mgh*(correction factor due to energy
    % being absorbed in muscles and in the joints)
    elseif slope_14EVA2(i) < 0
        W1_slope_14EVA2(i) = ke*m_CDR*g*v_14EVA2(i)*sin(slope_14EVA2(i))*0.3^(slope_14EVA2(i)/7.65);
        W2_slope_14EVA2(i) = ke*m_LMP*g*v_14EVA2(i)*sin(slope_14EVA2(i))*0.3^(slope_14EVA2(i)/7.65);
    end
    
    % level walking contribution
    W1_level_14EVA2(i) = (3.28*m_CDR + 71.1) * (0.661*v_14EVA2(i)*cos(slope_14EVA2(i)) + 0.115);
    W2_level_14EVA2(i) = (3.28*m_LMP + 71.1) * (0.661*v_14EVA2(i)*cos(slope_14EVA2(i)) + 0.115);
end

MR1_14EVA2 = W1_level_14EVA2 + W1_slope_14EVA2;
MR1_14EVA2 = MR1_14EVA2*J2kcal*3600; %[kcal/hr]
MR2_14EVA2 = W2_level_14EVA2 + W2_slope_14EVA2;
MR2_14EVA2 = MR2_14EVA2*J2kcal*3600; %[kcal/hr]

%% Correction Factor - BMR
% I'm making the assumption that Santee's model does not take into account
% the Basal Metabolic Rate (BMR) of the astronaut (which makes sense based
% on the equations). However, I think it is a safe assumption that the
% measured metabolic rates from the Apollo astronauts do take into account
% BMR. 

% corrBMR = 100;
% 
% MR1_14EVA2 = MR1_14EVA2+corrBMR;
% MR2_14EVA2 = MR2_14EVA2+corrBMR;

%% Plotting Apollo 14 Modeled vs. Actual
% figure(2);
% hold on;
% grid on;
% plot(MR1_14EVA1,'Color','#A2142F','LineWidth',2);
% plot(MR2_14EVA1,'Color','#7E2F8E','LineWidth',2);
% plot(MR1_14EVA1_ac,'x','Color','#A2142F','MarkerSize',12,'LineWidth',2)
% plot(MR2_14EVA1_ac,'x','Color','#7E2F8E','MarkerSize',12,'LineWidth',2)
% legend('Modeled CDR','Modeled, LMP','Measured CDR','Measured LMP')
% ylabel('MR, kcal/hr');
% title('Metabolic Rates on Apollo 14 EVA-1');
% hold off;

figure(3);
hold on;
sgtitle('Metabolic Rates on Apollo 14 EVA-2');
subplot(1,2,1);
hold on;
grid minor;
plot(v_14EVA2,MR1_14EVA2,'o','Color','k','LineWidth',2);
plot(v_14EVA2,MR1_14EVA2_ac,'x','Color','#A2142F','MarkerSize',12,'LineWidth',2)
xlabel('Velocity, m/s');
ylabel('MR, kcal/hr');
title('CDR');
hold off;
subplot(1,2,2);
hold on;
grid minor;
plot(v_14EVA2,MR2_14EVA2,'o','Color','k','LineWidth',2);
plot(v_14EVA2,MR2_14EVA2_ac,'x','Color','#7E2F8E','MarkerSize',12,'LineWidth',2)
legend('Modeled','Measured');
xlabel('Velocity, m/s');
ylabel('MR, kcal/hr');
title('LMP');
hold off;

figure(5);
hold on;
sgtitle('Metabolic Rates on Apollo 14 EVA-2');
subplot(1,2,1);
hold on;
grid minor;
plot(slope_14EVA2,MR1_14EVA2,'o','Color','k','LineWidth',2);
plot(slope_14EVA2,MR1_14EVA2_ac,'x','Color','#A2142F','MarkerSize',12,'LineWidth',2)
xlabel('Slope, rad');
ylabel('MR, kcal/hr');
title('CDR');
hold off;
subplot(1,2,2);
hold on;
grid minor;
plot(slope_14EVA2,MR2_14EVA2,'o','Color','k','LineWidth',2);
plot(slope_14EVA2,MR2_14EVA2_ac,'x','Color','#7E2F8E','MarkerSize',12,'LineWidth',2)
legend('Modeled','Measured');
xlabel('Slope, rad');
ylabel('MR, kcal/hr');
title('LMP');
hold off;


%% Calculating Error

err1_14EVA2 = abs(MR1_14EVA2-MR1_14EVA2_ac)./MR1_14EVA2_ac*100;
err2_14EVA2 = abs(MR1_14EVA2-MR2_14EVA2_ac)./MR2_14EVA2_ac*100;

figure(4);
hold on
grid on;
% plot(err1_14EVA1,'Color','#A2142F','LineWidth',2);
% plot(err2_14EVA1,'Color','#7E2F8E','LineWidth',2);
plot(v_14EVA2,err1_14EVA2,'o','Color','#A2142F','LineWidth',2);
plot(v_14EVA2,err2_14EVA2,'o','Color','#7E2F8E','LineWidth',2);
ylabel('Percent Error');
title('Percent Error of Model Estimation');
%legend('EVA-1 CDR','EVA-1 LMP','EVA-2 CDR','EVA-2 LMP');
hold off;

figure(8);
hold on
grid on;
% plot(err1_14EVA1,'Color','#A2142F','LineWidth',2);
% plot(err2_14EVA1,'Color','#7E2F8E','LineWidth',2);
plot(rad2deg(slope_14EVA2),err1_14EVA2,'o','Color','#A2142F','LineWidth',2);
plot(rad2deg(slope_14EVA2),err2_14EVA2,'o','Color','#7E2F8E','LineWidth',2);
ylabel('Percent Error');
xlabel('Slope, degrees')
title('Percent Error of Model Estimation');
%legend('EVA-1 CDR','EVA-1 LMP','EVA-2 CDR','EVA-2 LMP');
hold off;


%% Trying something new
dataSim = readtable('3.csv');
