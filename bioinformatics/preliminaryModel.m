%% Preliminary Physio Model
% Author: Sarah Leary
% Date: 4 October 2023
% Purpose: 

%close all;
clear;
clc;

%% %%%%%%%%%%%%%%%%%%%%%%% Santee's Model (2001) %%%%%%%%%%%%%%%%%%%%%%% %%

%% Constants
g = 1.6; %[m/s2] lunar gravity
d = 2; %[m] distance in one square
grid_size = [20 20];
kc = 3.5; %[] muscle inefficiency factor, concentric
ke = 2.4; %[] muscle inefficiency factor, eccentric

%% Apollo 14 (?) values
% slope_val = deg2rad(atand([0 0 0 2.6 -2.7 4.7 10.3 11.3 5.8 3.5 ...
%     -13.8 -9.4 -3.4 0 4.5 -6.3]/100)); %[rad]
slope_val = deg2rad(atand((-15:15)/100));

% v_val = [.688 .765 .728 1.56 1.43 2.65 1.71 1.66 1.97...
%     3.69 2.57 4.8 4.49 5.7 2.64 3.18]*1000/3600; %[m/s]
v_val = linspace(1,2,100);

%% Variables
% WHAT IS THE AVERAGE MASS OF APOLLO 12 ASTRONAUT
m = 80+34.5; %[kg]

% WHAT ARE THE TYPICAL WALKING SPEEDS OF APOLLO 12 ASTRONAUTS
%v = 1.36*ones(20); %[m/s] walking speed
% WHAT ARE THE SLOPES APOLLO 12 ASTRONAUTS WALKED ON
grade = [8 10 15]; %[%] percent grades of the slope
%alpha = atan(deg2rad(grade/100)); %[%] slope CHECK FOR TYPICAL SLOPES
%alpha = deg2rad(11*ones(20));

%% Pre-allocating vectors
% Work due to level walking
W_level = zeros(size(grade));

% Work due to sloped (+ or -) walking
W_slope = zeros(size(grade));

%v = zeros(size(grade));

%alpha = zeros(size(grade));

%% From simulation team
load terrain_output.mat;
alpha = deg2rad(Z_slope);
grid_size = size(alpha);

v = 1.34; %[m/s]

%% Calculating Work over each square

for i = 1:grid_size(1)
    for j = 1:grid_size(2)

        % Choosing random (feasible) grade
        %alpha(i,j) = slope_val(randi(length(slope_val)));
        % Choosing random (feasible) velocity
        %v = v_val(randi(length(v_val)));

        % if level walking
        if alpha(i,j) == 0
            W_slope(i,j) = 0;

        % if inclined walking: W=PE=k*mgh
        elseif alpha(i,j) >= 0
            W_slope(i,j) = kc*m*g*v*sin(alpha(i,j));

        % if declined walking: W=k*mgh*(correction factor due to energy
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
MR = MR/4184; %[kcal/s] <3 English <3 units <3

%% Time over Each Square
t = sqrt((d^2+d^2))/v; %[s] time, constant for now

%% Metabolic Cost Per Square
MC = MR*t; %[kcal] SOMETHIN IS WRONG WITH THIS CALCULATION RN.... GOTTA FIGURE IT OUT

%% Plotting Metabolic Rate
figure(1);
hold on;
minLevel = min(MC,[],'all');
maxLevel = max(MC,[],'all');
avgLevel = mean([minLevel maxLevel]);
levels = linspace(minLevel,maxLevel,8);
%levels = [linspace(minLevel,avgLevel,5) linspace(avgLevel+100,maxLevel-300,2)];
contourf(X,Y,MC,levels);
colorbar;

figure(2);
subplot(2,1,1);
hold on;
plot(alpha(:),MR(:),'o');
subplot(2,1,2); 
hold on;
plot(v(:),MR(:),'o');

figure(3);
hold on;
grid on;
surf(v(:),alpha(:),MR);
colorbar;
xlabel('Velocity, m/s');
ylabel('Slope, rad');
zlabel('Metabolic Rate, kcal/hr');

%% Validation: Apollo 12?

%% Knowns/Constants


%% Validation...
slope = [0 0 0 2.6 -2.7 4.7 10.3 11.3 5.8 3.5 -13.8 -9.4 -3.4 0 4.5 -6.3];
v = [.688 .765 .728 1.56 1.43 2.65 1.71 1.66 1.97 3.69 2.57 4.8 4.49 5.7 2.64 3.18];
MR1 = [248 321 285 142 192 241 343 376 456 244 238 314 323 282 268 305];
MR2 = [277 262 270 209 212 273 291 315 520 323 266 337 367 391 379 393];

%% Characteristics of Astronaut
h = 179.1; %[cm] average height
bm = 80.7; %[kg] average body mass
age = 44.8; %[yr] average age
VO2pk = 50.8; %[mL/min/kg] average peak rage of oxygen consumption
l = 104; %[cm] average leg length
