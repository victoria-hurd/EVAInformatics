function [coordVec] = user_fed_POI()
    % Create a figure -- need to pull this from the map data1
    f = figure('Name', 'Apollo 12 Map - Pick POIs');
    hold on;
    [X, Y, Z_elevation, Z_slope] = get_map_data_all();
    h = surf(X, Y, Z_elevation);
    axis('tight');
    axis('equal');
    set(h,'LineStyle','none');
    colormap(gray);
    h.Annotation.LegendInformation.IconDisplayStyle = 'off';
    title("Apollo 12 Landing Site")
    xlabel("Longitude [deg]")
    ylabel("Latitude [deg]")
    c = colorbar;
    c.Label.String = "Elevation [Meters]";
    c.Label.Rotation = 270;
    c.Label.VerticalAlignment = "bottom";
    view(2)
    
    % Display instructions
    disp('Click on points on the figure. Press Enter to finish.');
    % Allow the user to input the number of points to be selected
    n = input('Enter the number of points (up to n): ');
    % Initialize a vector to store the selected points
    coordVec = zeros(n, 2);
    % Allow the user to input default points if desired
    useDefaultPoints = input('Do you want to use default points? (1 for yes, 0 for no): ');
    if useDefaultPoints
        % Define default points (you can modify these)
        coord12055 = [336.573,-3.0115]; % Measured by hand from figure 1 - North Head Crater
        coord12052 = [336.571,-3.01384]; % Measured by hand from figure 1 - West Head Crater
        coord12040 = [336.570, -3.018]; % Measured by hand from figure 1 - NW Bench Crater
        coord12024 = [336.565,-3.0205]; % Measured by hand from figure 1 - E Sharp Crater
        coord12041 = [336.572,-3.02024]; % Measured by hand from figure 1 - E Bench Crater
        defaultPoints = [coord12055;coord12052;coord12040;coord12024;coord12041];
        % Display default points
        disp('Default Points:');
        disp(defaultPoints);

        % Plot default points on the figure
        hold on;
        plot(defaultPoints(:, 1), defaultPoints(:, 2), 'ro', 'MarkerSize', 10);
        hold off;

        % Store default points in the selectedPoints vector
        coordVec(1:size(defaultPoints, 1), :) = defaultPoints;
    end
    % Allow the user to select points interactively
    for i = 1:n
        % Wait for the user to click on the figure
        waitforbuttonpress;

        % Get the current point clicked by the user
        currentPoint = ginput(1);

        % Store the current point in the vector -- change selectedPoints to
        % coordVec
        coordVec(i, :) = currentPoint;

        % Display the selected point
        disp(['Point ', num2str(i), ': (', num2str(currentPoint(1)), ', ', num2str(currentPoint(2)), ')']);
    end
    
    % Display the final selected points vector
    disp('Selected Points:');
    disp(coordVec);
    hold off;
    close(f);
end