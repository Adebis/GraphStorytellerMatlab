function [start,tend] = rapid_grow(x,y)
    max = 0;
    start = 0;
    tend = 0;
    for i= 1:size(y)
        for j = i+1:size(y)
            if (y(j)-y(i))/(x(j)-x(i)) > max
                max  = (y(j)-y(i))/(x(j)-x(i));
                start = i;
                tend = j;
            end
        end
    end
    return
end