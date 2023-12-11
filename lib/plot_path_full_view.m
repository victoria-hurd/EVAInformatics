%% plot_evelation_path_full_view
% This function take in a set of X, Y coordinate mesh grids, a Z data point to plot the surface, POIs and a path to follow.
% Units should be in latitude longitude decimal formats the same as the input map file.
%
% Inputs
%    X = [X_coordinates, X_coordinates] created with meshgrid from get_map_data()
%    Y = [Y_coordinates, Y_coordinates] created with meshgrid from get_map_data()
%    Z = surface data to plot, X x Y dimensions of floating point value (elevation, slope, cost, etc...)
%    ROIs = [X_coordinates, Y_Coordinates]
%    path = [X_coordinates, Y_Coordinates]
%    color = colormap Name for the surface plot to use. (https://www.mathworks.com/help/matlab/ref/colormap.html)
%    Z_label = string for the Z axis of the surface plot to be labeled with

% Outputs
%    Displays a plot
%    

function plot_path_full_view(X, Y, Z, POIs, path, color, Z_label)
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
    X_pos = path(:,1);
    Y_pos = path(:,2);
    N = length(path);
    Z_pos = ones(N,1);
    Z_pos(:) = 1000000;
    % Setup refreshdata plotting 
    X_path = NaN(N, 1);
    Y_path = NaN(N, 1);
    
    future_path_plot = plot3(ax, X_pos, Y_pos, Z_pos , 'Color', "#27BA76", 'LineWidth',2);
    future_path_plot.XDataSource = 'X_pos';
    future_path_plot.YDataSource = 'Y_pos';
    
    path_plot = plot3(ax, X_path ,Y_path,Z_pos, 'Color', "#40755C", 'LineWidth',1);
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
    numFrames = N;
    iter=1;
     
    X_pos = path(:,1);
    Y_pos = path(:,2);
    
    X_path = NaN(numFrames , 1);
    Y_path = NaN(numFrames , 1);

    X_current = X_pos(1);
    Y_current = Y_pos(1);   
    
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
    
    b7 = uibutton(g, ...
        "Text","Clear Alert", ...
        "ButtonPushedFcn", @(src,event) clearAlertButtonPushed());
    b7.Layout.Row = 3;
    b7.Layout.Column = 4;
    

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
        if iter>numFrames
            reset = true;
            pauseS = true;
            pause(1)
        end
                         
        if reset == true
            X_pos = path(:,1);
            Y_pos = path(:,2);

            X_path = NaN(numFrames , 1);
            Y_path = NaN(numFrames , 1);

            X_current = X_pos(1);
            Y_current = Y_pos(1);  
            iter = 1;
            pauseS = true;
            reset = false;
            
            refreshdata(path_plot, 'caller');
            refreshdata(future_path_plot, 'caller');
            refreshdata(current_pos, 'caller');
            drawnow;
        
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
                
        X_path(iter) = X_pos(iter);
        Y_path(iter) = Y_pos(iter);
        X_current = X_pos(iter);
        Y_current = Y_pos(iter);
        if iter > 1
            X_pos(iter - 1) = NaN;
            Y_pos(iter - 1) = NaN;
        end
        
        % Physio Monitoring
       [heartrate, o2_consumption, co2_production, water_remaining] = get_current_vitals_and_consumables(X_current, Y_current);
       heartrate_criticality_level = monitor_heartrate(heartrate); 
       o2_consumption_criticality_level = monitor_o2_consumption(o2_consumption); 
       co2_production_criticality_level = monitor_co2_production(co2_production); 
       water_remaining_criticality_level = monitor_water_remaining(water_remaining);
       
       % TODO: [Viz team] Display alerts based on criticality levels 
       bpm_string = '';
       o2_string =  '';
       co2_string = '';
       h2o_string = '';
       show = false;
       
       if heartrate_criticality_level == 3
           bpm_string = strcat('Elevated Heart Rate: ', string(heartrate));
           show = true;
       end
       if o2_consumption_criticality_level == 3
           o2_string = strcat('Elevated O2 Consumption: ', string(o2_consumption));
           show = true;
       end
       if co2_production_criticality_level == 3
           co2_string = strcat('Elevated CO2 Consumption: ', string(co2_production));
           show = true;
       end
       if water_remaining_criticality_level == 3
           h2o_string = strcat('Low Water Remaining: ', string(water_remaining));
           show = true;
       end
       
       if show
           txt_alert.String = sprintf("%s \n%s \n%s \n%s",bpm_string, o2_string, co2_string, h2o_string);
           txt_alert.FaceAlpha = 0.5;
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
                    if (iter < numFrames)
                        view_angle = atan2d(Y_pos(iter+1)- Y_current, X_pos(iter+1)- X_current) - 90;

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
        
        iter = iter + 1;  
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

function clearAlertButtonPushed()  
     % TODO: Implement Alert Clear
end