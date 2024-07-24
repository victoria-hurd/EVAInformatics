%% plot_path_simple
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

function plot_path_simple(X, Y, Z, POIs, path, color, Z_label)
    %% Plot Z Map
    fig = figure('Name',strcat("Path Vizualization: ", Z_label));
%     fig.Position = [10 50 600 600];  
    hold('on' )
    axis('tight');
    axis('equal');

    imagesc(X(1,:),Y(:,1),Z);
    colormap(color);
    title("Apollo 12 Landing Site")
    xlabel("Longitude [deg]")
    ylabel("Latitude [deg]")
    c = colorbar;
    c.Label.String = Z_label;
    c.Label.Rotation = 270;
    c.Label.VerticalAlignment = "bottom";
    view(2);
    
    %% Plot ROIs
    Z_poi = ones(length(POIs(:, 1)),1);
    Z_poi(:) = 1000001;
    scatter3(POIs(:, 1),   POIs(:, 2), Z_poi, 20,  [0 .95 .05], "filled")
    dx = .0002;
    dy = -.0002;
    num_ROIs = length(POIs);
    c = cell(num_ROIs, 1);
    for i = 1:num_ROIs
    	c{i} = num2str(i);
    end
    text(POIs(:, 1)+dx,   POIs(:, 2)+dy, Z_poi, c, 'FontSize',10);
        
    %% Plot Path Between ROIs
    X_pos = path(:,1);
    Y_pos = path(:,2);
    N = length(path);
    Z_pos = ones(N,1);
    Z_pos(:) = 1000000;
    % Setup refreshdata plotting 
    X_path = NaN(N, 1);
    Y_path = NaN(N, 1);
    
    future_path_plot = plot3(X_pos, Y_pos, Z_pos , 'Color', "#27BA76", 'LineWidth',2);
    future_path_plot.XDataSource = 'X_pos';
    future_path_plot.YDataSource = 'Y_pos';
end