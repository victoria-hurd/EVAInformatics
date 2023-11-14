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
    fig.Position = [10 50 600 600];
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
    % TODO: investigate if grid points should be in the middle of each sqare not the corners
    h = surf(ax, X, Y, Z);
    set(h,'LineStyle','none');
    colormap(ax, color);
    h.Annotation.LegendInformation.IconDisplayStyle = 'off';
    title(ax, "Apollo 12 Landing Site")
    xlabel(ax, "Longitude [deg]")
    ylabel(ax, "Latitude [deg]")
    c = colorbar(ax);
    c.Label.String = Z_label;
    c.Label.Rotation = 270;
    c.Label.VerticalAlignment = "bottom";
    view(ax, 2)
    
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
    
    global pauseS speed reset fullView;
    pauseS = true;
    speed = 3; % 1 is fastest 4 is slowest
    reset = false;
    fullView = true;
    numFrames = N;
    iter=1;
     
    X_pos = path(:,1);
    Y_pos = path(:,2);
    
    X_path = NaN(numFrames , 1);
    Y_path = NaN(numFrames , 1);

    X_current = X_pos(1);
    Y_current = Y_pos(1);   
    
        
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
        "Text","Clear Alert", ...
        "ButtonPushedFcn", @(src,event) clearAlertButtonPushed());
    b6.Layout.Row = 3;
    b6.Layout.Column = 4;
    
    hold(ax, 'off' )
    local_coords = (6.6e-5)* 25;
    
    %TODO: put this main loop function in a button function so we can have
    %multiple plots at once.
    while(1)        
        % here for slow down and speed up
        if speed ==1
            pause(0.0001);
        elseif speed==2
            pause(0.05);
        elseif speed ==3
            pause(0.2)
        elseif speed==4
            pause(1)
        end
        
        if fullView==true
            xlim(ax,[X(1,1) X(1,end)]);
            ylim(ax,[Y(end,1) Y(1,1)]);
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
            
            xlim(ax,[X_start_idx X_end_idx]);
            ylim(ax,[Y_end_idx Y_start_idx]);
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
        
        % Here for pause and resume
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
        refreshdata(path_plot, 'caller');
        refreshdata(future_path_plot, 'caller');
        refreshdata(current_pos, 'caller');
        drawnow;
        
        iter = iter + 1;  
    end
    
       
    
 end

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

function clearAlertButtonPushed()  
     % TODO:
end