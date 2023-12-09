function plot_path_history(X, Y, Z, POIs, pathHistory, endPoseHistory, color, Z_label)

%% Plot Z Map
    fig = figure('Name',strcat("Path Vizualization: ", Z_label));
%     fig.Position = [10 50 600 600];  
    hold on
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
    endPoseHistory = [endPoseHistory;length(pathHistory{end})]

    for i = 1:length(pathHistory)
        X_pos = pathHistory{i}(:,1);
        Y_pos = pathHistory{i}(:,2);
        N = length(X_pos);
        Z_pos = ones(N,1);
        Z_pos(:) = 1000000;
        % Setup refresh data plotting 
        X_path = NaN(N, 1);
        Y_path = NaN(N, 1);
        
        future_path_plot = plot3(X_pos(1:endPoseHistory(i)), Y_pos(1:endPoseHistory(i)), Z_pos(1:endPoseHistory(i)), 'LineWidth',2);
        future_path_plot.XDataSource = 'X_pos';
        future_path_plot.YDataSource = 'Y_pos';
    end

end