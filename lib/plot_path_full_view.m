%% plot_evelation_path_full_view
% This function take in a set of X, Y coordinate mesh grids, a Z data point to plot the surface, POIs and a path to follow.
% Units should be in latitude longitude decimal formats the same as the input map file.
%
% Inputs
%    X = [X_coordinates, X_coordinates] created with meshgrid from get_map_data()
%    Y = [Y_coordinates, Y_coordinates] created with meshgrid from get_map_data()
%    Z = surface data to plot, X x Y dimensions of floating point value (elevation, slope, cost, etc...)
%    ROIs = [X_coordinates, Y_Coordinates]
%    pathHistory = cell arrayt of [X_coordinates, Y_Coordinates]
%    endPoseHistory = array of indexies for what each cell of pathHistory
%    got to before replanning
%    color = colormap Name for the surface plot to use. (https://www.mathworks.com/help/matlab/ref/colormap.html)
%    Z_label = string for the Z axis of the surface plot to be labeled with
%    cost_matrix = 

% Outputs
%    Displays a plot
%    

function plot_path_full_view(X, Y, Z, POIs, pathHistory, endPoseHistory, color, Z_label, cost_matrix)   
    %% Get Vital Estimates
    [hr, o2, co2] = vital_estimator(cost_matrix);

    %% Plot Z Map
    fig = uifigure('Name',strcat("Path Vizualization: ", Z_label));
    fig.Position(2:4) = [100 800 800];
    g = uigridlayout(fig);
    g.RowHeight = {'1x','fit','fit'};
    g.ColumnWidth = {'1x','fit','fit','fit','fit','1x'};
    
    ax = uiaxes(g);
    ax.Layout.Row = 1;
    ax.Layout.Column = [1 6];
    
    set(ax,'units','pix');
    hold(ax, 'on' )
    axis(ax, 'tight');
    axis(ax, 'equal');
    imagesc(ax, X(1,:),Y(:,1),Z);
    colormap(ax, color);
    title(ax, "Apollo 12 Landing Site")
    xlabel(ax, "Longitude [deg]")
    ylabel(ax, "Latitude [deg]")
    c = colorbar(ax);
    c.Label.String = Z_label;
    c.Label.Rotation = 270;
    c.Label.VerticalAlignment = "bottom";
    
    %% Plot ROIs
    Z_poi = ones(length(POIs(:, 1)),1);
    Z_poi(:) = 1000001;
    scatter3(ax, POIs(:, 1),   POIs(:, 2), Z_poi, 20,  [0 .95 .05], "filled")
    dx = .0002;
    dy = -.0002;
    num_ROIs = length(POIs);
    c = cell(num_ROIs, 1);
    for i = 1:num_ROIs
    	c{i} = num2str(i);
    end
    text(ax, POIs(:, 1)+dx,   POIs(:, 2)+dy, Z_poi, c, 'FontSize',10);
        
    %% Plot Path Between ROIs
    maxLength = 0;
    for i  = 1:length(pathHistory)
        if maxLength < length(pathHistory{i})
            maxLength = length(pathHistory{i});
        end
    end
    maxLength = maxLength*2;
    endPoseHistory = [endPoseHistory;maxLength];
    path_cell_index = 1;
    current_path_cell_iter = 1;
    X_pos = pathHistory{path_cell_index}(:,1);
    Y_pos = pathHistory{path_cell_index}(:,2);
    numFrames = length(pathHistory{path_cell_index});
    Z_pos = ones(numFrames,1);
    Z_pos(:) = 1000000;
    % Setup refreshdata plotting 
    
    X_path = NaN(maxLength, 1);
    Y_path = NaN(maxLength, 1);
    Z_pos_2 = ones(maxLength,1);
    
    future_path_plot = plot3(ax, X_pos, Y_pos, Z_pos , 'Color', "#27BA76", 'LineWidth',2);
    future_path_plot.XDataSource = 'X_pos';
    future_path_plot.YDataSource = 'Y_pos';
    future_path_plot.ZDataSource = 'Z_pos';
    
    path_plot = plot3(ax, X_path ,Y_path,Z_pos_2, 'Color', "#40755C", 'LineWidth',1);
    path_plot.XDataSource = 'X_path';
    path_plot.YDataSource = 'Y_path';

    X_current = X_pos(1);
    Y_current = Y_pos(1);
    current_pos = scatter3(ax, X_current,Y_current, 1000002, 80, [.9 .4 .1], 'filled');
    current_pos.XDataSource = 'X_current';
    current_pos.YDataSource = 'Y_current';
    
    global pauseS speed reset fullView north_up;
    pauseS = true;
    speed = 3; % 1 is fastest 4 is slowest
    reset = false;
    fullView = true;
    north_up = true;
    iter=1;
     

    
    %% Setup UI Buttons    
    b1 = uibutton(g, ...
        "Text","Reset", ...
        "ButtonPushedFcn", @(src,event) resetButtonPushed());
    b1.Layout.Row = 2;
    b1.Layout.Column = 2;
    
    b2 = uibutton(g, ...
        "Text","Play/Pause", ...
        "ButtonPushedFcn", @(src,event) playPauseButtonPushed());
    b2.Layout.Row = 2;
    b2.Layout.Column = 3;
    
    b3 = uibutton(g, ...
        "Text","Faster", ...
        "ButtonPushedFcn", @(src,event) fasterButtonPushed());
    b3.Layout.Row = 2;
    b3.Layout.Column = 4;
    
    b4 = uibutton(g, ...
        "Text","Slower", ...
        "ButtonPushedFcn", @(src,event) slowerButtonPushed());
    b4.Layout.Row = 2;
    b4.Layout.Column = 5;
    
    b5 = uibutton(g, ...
        "Text","Switch Views", ...
        "ButtonPushedFcn", @(src,event) switchViewsButtonPushed());
    b5.Layout.Row = 3;
    b5.Layout.Column = 2;

    b6 = uibutton(g, ...
        "Text","Toggle North Up", ...
        "ButtonPushedFcn", @(src,event) toggleNorthButtonPushed());
    b6.Layout.Row = 3;
    b6.Layout.Column = 3;
    b6.Visible = 'off'; % default to off as this only matters in local view

    txt_alert = annotation(g, "textbox", 'vert', 'top');
    txt_alert.Position= [.102 .84 .4 .12]; % TODO: make this relative position so when the window changes form it stays in that spot
    txt_alert.EdgeColor = 'none';
    txt_alert.BackgroundColor = 'red';
    txt_alert.FaceAlpha = 0.0;
    txt_alert.FontSize = 14;
    
    hold(ax, 'off' )
    local_coords = (6.6e-5)* 25;
    
    %% Main loop to step through path
    while(1)        
        % here for slow down and speed up
        if speed ==1
            pause(0.0001);
        elseif speed==2
            pause(0.1);
        elseif speed ==3
            pause(0.5)
        elseif speed==4
            pause(1)
        end
                
        % If frame is finished, break
        if current_path_cell_iter>numFrames
            reset = true;
            pauseS = true;
            pause(1)
        end
                         
        if reset == true
            path_cell_index = 1;
            X_pos = pathHistory{path_cell_index}(:,1);
            Y_pos = pathHistory{path_cell_index}(:,2);
            numFrames = length(pathHistory{path_cell_index});
            Z_pos = ones(numFrames,1);
            Z_pos(:) = 1000000;
            X_path = NaN(maxLength, 1);
            Y_path = NaN(maxLength, 1);

            X_current = X_pos(1);
            Y_current = Y_pos(1);  
            iter = 1;
            current_path_cell_iter = 1;
            pauseS = true;
            reset = false;
            
            refreshdata(path_plot, 'caller');
            refreshdata(future_path_plot, 'caller');
            refreshdata(current_pos, 'caller');
            drawnow;
        
        end
        
        show = false;
        if current_path_cell_iter >  endPoseHistory(path_cell_index)
%             fprintf("Replanning \n");
            current_path_cell_iter = 1;
            path_cell_index = path_cell_index + 1;
            X_pos = pathHistory{path_cell_index}(:,1);
            Y_pos = pathHistory{path_cell_index}(:,2);
            numFrames = length(pathHistory{path_cell_index});
            Z_pos = ones(numFrames,1);
            Z_pos(:) = 1000000;
            show = true;
        end
        
        % pause and resume
        if pauseS == true
            while(1)
                pause(0.001);
                if pauseS == false || reset == true
                    break;
                end
            end
        end 
                
        X_path(iter) = X_pos(current_path_cell_iter);
        Y_path(iter) = Y_pos(current_path_cell_iter);
        X_current = X_pos(current_path_cell_iter);
        Y_current = Y_pos(current_path_cell_iter);
        if current_path_cell_iter > 1
            X_pos(current_path_cell_iter - 1) = NaN;
            Y_pos(current_path_cell_iter - 1) = NaN;
        end
        
       % Physio Monitoring
       X_current_idx = interp1(X(1,:), 1:length(X(1,:)), X_current,'nearest');
       Y_current_idx = interp1(Y(:,1), 1:length(Y(:,1)), Y_current,'nearest');
       heartrate = hr(X_current_idx,Y_current_idx);
       o2_consumption = o2(X_current_idx,Y_current_idx);
       co2_production = co2(X_current_idx,Y_current_idx);

       % Display alerts based on criticality levels 
       bpm_string = strcat('Heart Rate: ', string(heartrate));
       o2_string =  strcat('O2 Consumption: ', string(o2_consumption));
       co2_string = strcat('CO2 Consumption: ', string(co2_production));
       if show
           txt_alert.String = sprintf("Elevated Vitals - Replanning Path \n%s \n%s \n%s",bpm_string, o2_string, co2_string);
           txt_alert.FaceAlpha = 0.5;
           pause(0.5);
       else
           txt_alert.String = '';
           txt_alert.FaceAlpha = 0.0;
       end
              
       % Update and refresh view
        if fullView==true            
            if ishandle(ax)
                b6.Visible = 'off';
                xlim(ax,[X(1,1) X(1,end)]);
                ylim(ax,[Y(end,1) Y(1,1)]);
                view(ax, 0, 90); 
                axis(ax, 'on');
            end
        else            
            X_start_idx = interp1(X(1,:),X(1,:),X_current - local_coords,'nearest');
            X_end_idx = interp1(X(1,:),X(1,:),X_current + local_coords,'nearest');
            Y_start_idx = interp1(Y(:,1),Y(:,1),Y_current + local_coords,'nearest');
            Y_end_idx = interp1(Y(:,1),Y(:,1),Y_current - local_coords,'nearest');
            
            % Protect for the axes window going out of bounds of our input file
            if isnan(X_start_idx)
                X_start_idx = X(1,1);
            end
            if isnan(Y_start_idx)
                Y_start_idx = Y(1,1);
            end
            if isnan(X_end_idx)
                X_end_idx = X(1,end);
            end
            if isnan(Y_end_idx)
                Y_end_idx = Y(end,1);
            end
            
            if ishandle(ax)
                b6.Visible = 'on';
                xlim(ax,[X_start_idx X_end_idx]);
                ylim(ax,[Y_end_idx Y_start_idx]);

                if (north_up)
                    view(ax, 0, 90);
                    axis(ax, 'on');                    
                else
                    [view_angle, ~] = view(ax);            
                    if (current_path_cell_iter < length(pathHistory{path_cell_index}))
                        view_angle = atan2d(Y_pos(current_path_cell_iter+1)- Y_current, X_pos(current_path_cell_iter+1)- X_current) - 90;

                    end
                    view(ax, view_angle, 90); 
                    axis(ax, 'off');
                end    
            end    
  
        end        
        
        %refresh figure and draw
        if ishandle(ax)
            refreshdata(path_plot, 'caller');
            refreshdata(future_path_plot, 'caller');
            refreshdata(current_pos, 'caller');
            drawnow;
        end
        
        %break out of loop if figure closed
        if ~ishandle(ax)
            break;
        end
        
        if show ~= true
            iter = iter + 1;
        end        
        current_path_cell_iter = current_path_cell_iter + 1;
    end
    
       
    
end

 %% The following defines the UI Buttons
function playPauseButtonPushed()  
    global pauseS
    if pauseS==true
         pauseS=false;
    else
         pauseS=true;
    end
end

function fasterButtonPushed()  
    global speed
    if speed==2
       speed=1;
    elseif speed ==3
       speed=2;
    elseif speed ==4
       speed=3;
    end
end

function slowerButtonPushed()  
    global speed
    if speed ==1
        speed=2;
    elseif speed==2
        speed=3;
    elseif speed==3
        speed=4;
    end
end

function resetButtonPushed()  
     global reset
     reset = true;
end

function switchViewsButtonPushed()  
    global fullView
    if fullView==true
         fullView=false;
    else
         fullView=true;
    end
end

function toggleNorthButtonPushed()  
    global north_up
    if north_up==true
         north_up=false;
    else
         north_up=true;
    end
end