% Read in CSV data as a table
filename = 'data\bb_ca_csv.csv';
data_table = readtable(filename,...
    'Delimiter',',','Format','%{dd-MMMM-yyyy}D%f');
% The data table will have Date and Value columns.
% Create a PLA of the data.
PLA = generate_PLA_graph(data_table)
% PLA consists of all the X and Y values of the Piecewise Linear
% Approximation of the data.
% This comprises a set of start and end points for a set of segments.
% Select the first (X) and second (Y) columns of the PLA.
PLA_x = PLA(:,1)
PLA_y = PLA(:,2)

% Save results to segment CSV file.
% Create a row of index values
indices = 1:length(PLA_x) - 1
indices = transpose(indices)
% Set start and end values for each segment.
start_x = []
start_y = []
end_x = []
end_y = []
for i = 2:length(PLA_x)
    start_x = [start_x, PLA_x(i - 1)]
    start_y = [start_y, PLA_y(i - 1)]
    end_x = [end_x, PLA_x(i)]
    end_y = [end_y, PLA_y(i)]
end
start_x = transpose(start_x)
start_y = transpose(start_y)
end_x = transpose(end_x)
end_y = transpose(end_y)
% Place them together
matrix_to_write = [indices start_x start_y end_x end_y]
% Write them out to the segment.csv file.
table_to_write = array2table(matrix_to_write,'variableNames', {'index_value', 'start_x', 'start_y', 'end_x','end_y'});
writetable(table_to_write,'output\segments.csv');

% Identify shapes in the data.
% First, identify all inflection points.
inflection_x = [PLA_x(1)]
inflection_y = [PLA_y(1)]
for i = 3:length(PLA_y)
    if sign(PLA_y(i - 1) - PLA_y(i - 2)) ~= sign(PLA_y(i) - PLA_y(i - 1))
        inflection_x = [inflection_x PLA_x(i - 1)]
        inflection_y = [inflection_y PLA_y(i - 1)]
    end
end
inflection_x = [inflection_x PLA_x(length(PLA_x) - 1)]
inflection_y = [inflection_y PLA_y(length(PLA_y) - 1)]

% Greedily match the first shapes that appear.
% 2 inflection points for lines, 3 for v's, 5 for w's
% But shapes that touch will share inflection points.
shapes = []
% A running set of points in the inflection arrays used to determine shapes.
% Stored as indices for each point in inflection array.
current_point_indices = [1]
for i = 2:length(inflection_x)
    current_point_indices = [current_point_indices i]
    % segment_direction will be 1 if the direction is up, -1 if the
    % direction is down.
    segment_direction = sign(inflection_y(i) - inflection_y(i - 1))
    % If the first segment goes up, there is no chance of becoming a W or a
    % V. Match a line to it.
    if i == 2
        if segment_direction == 1
            shapes = [shapes, {'line'}]
            % Flush indices array, initialize only with current point index
            current_point_indices = [i]
        end
    end
    % Check how many points are in the indices array.
    % If there are 5 and this is an up-segment, assign a 'w'
    if length(current_point_indices) == 5
        shapes = [shapes, {'w'}]
        % Flush indices array, initialize only with current point index
        current_point_indices = [i]
    end
    % If we are at the end
    if i == length(inflection_x)
        % If there are only 2 points left, assign them to a line.
        if length (current_point_indices) == 2
            shapes = [shapes, {'line'}]
        % If there are 3 points left, assign them to a 'v'
        elseif length (current_point_indices) == 3
            shapes = [shapes, {'v'}]
        % If there are 4 points left, check the direction of the last
        % segment. If it is up, assign a line first followed by a 'v'. If
        % it is down, assign a 'v' first, followed by a line.
        elseif length (current_point_indices) == 4
            if segment_direction == 1
                shapes = [shapes, {'line'}, {'v'}]
            else
                shapes = [shapes, {'v'}, {'line'}]
            end
        end
    end
end

% Gather critical points for each shape cell in shapes cell array.


% Print results and other information to meta JSON file.