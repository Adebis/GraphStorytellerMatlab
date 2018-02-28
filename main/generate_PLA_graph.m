% Reads in time-series data as a CSV at the given filename. 
% Creates a Piecewise Linear Approximation of it.
% Returns a 2-cell array with a list of all the x values and a list
% of all the y-values.
function PLA = generate_PLA_graph(data_table)
    %'Format','%{dd/MMM/yyyy}D%f'
    
    dates = data_table.Date;
    values = data_table.Value;
    %date_nums = [];

    %for n = 1:size(dates)
        % Subtract 1/1/1980, the start year, from each datetime.
        % This gets us a list of durations since 1/1/1980, which
        % we will convert to the number of days since 1/1/1980.
    %    date_nums(n,1) = days(dates(n) - datetime(1980,1,1));
    %end

    date_nums = days(dates - datetime(1980, 1, 1))

    %date_nums

    x = date_nums;
    y = values;
    number_of_segments = 7
    XI_raw = linspace(min(x), max(x), number_of_segments + 1)
    XI = transpose(XI_raw)
    YI = lsq_lut_piecewise(x, y, XI)

    x_tick_array = [];
    x_tick_labels = [];
    years_per_tick = 4
    for n = 1:number_of_segments + 1
        x_tick_array(n) = min(x) + 365 * years_per_tick * (n - 1);
        x_tick_label(n) = 1980 + floor(x_tick_array(n) / 365);
    end
    x_tick_array
    x_tick_label
    plot(x,y,'.',XI,YI,'+-')
    %plot(x,y,'.')
    %plot(XI, YI, '+-')
    xticks(x_tick_array)
    xticklabels(x_tick_label)
    ylim([8, 14])
    ylabel('mg/l')
    xlabel('Year')
    legend('Measured Data','Piecewise Linear Approximation')
    %title_text = 'Chemical C at Site B';
    title_text = 'Calcium Levels at Basin Bay';
    title(title_text)
    
    % Horizontally concatenate
    PLA = [XI YI];
end



