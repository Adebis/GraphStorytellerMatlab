function LetterPlot(kt,lakedata_desend,startp,endp)
    k = kt; %set the variable that want to analyze.
    columnname = lakedata_desend.Properties.VariableNames;
    %% BB
%     x = lakedata_desend{5457:5951,3};
%     data_t = lakedata_desend{5457:5951,k};
    %% AN
    x = lakedata_desend{5952:6125,3};
    data_t = lakedata_desend{5952:6125,k};
    
    date_lable_t=datenum(x);
    figure
    scatter(date_lable_t,data_t);
    hold on
    datetick('x','dd-mm-yyyy','keepticks')
    grid on
    title(['Graph of offshore chemistry data for', columnname{1,k}]);
    legend('BB');
    ylabel('mg/l');
    xlabel('Date')
    printout = strcat('Tsite_Graph_for_',columnname{1,k});
    print(printout,'-dpng');
    
    %% Normalize date in x axis, start from 0 in x axis instead of date, eliminate repeated value
 
    [a,~] = size(x);
    u = [];
    v = [];
    
    % k: number of total data points after normalization.
    new_y = 0;
    y_c = 0;
    k = 0;
    temp = date_lable_t(1);
    kt = date_lable_t(1);
    figure
    for i=1:a
        if (date_lable_t(i)==temp)
            y_c = y_c+1;
            new_y = new_y + data_t(i);
        else
            k = k+1;
            u(k) = temp - date_lable_t(1);
            v(k) = new_y/y_c;
            temp = date_lable_t(i);
            y_c = 0;
            new_y = 0;
        end
    end
    
    %% Find median points within every 1/6 interval of whole data sets. 
    c = 1;
    threshold = (u(k))/6;
    sum = [];
    tu = [];
    tv = [];
    M = zeros(6,5);
    for i=1:k
        if (u(i)<c*threshold)
            % eliminate NaN data points
            if (~isnan(v(i)))
               sum = [sum;v(i)];
            end
        else
            M(c,1) = c;
            M(c,2) = (c-1)*threshold;
            M(c,4) = c*threshold;
            M(c,3) = min(sum);
            M(c,5) = max(sum);
            tu(c) = (c-1/2)*threshold;
            tv(c) = median(sum);
            size(sum)
            c = c+1;
            sum = [];
        end
    end
    disp(M)
    % save begining point and end point into csv file
    % , 'variableNames', {'index\value', 'start_x', 'start_y', 'end_x','end_y'}
    T = array2table(M );
    disp(T)
    writetable(T,'segments_value.csv');
    
    hold on
    % Plot out median points found in scatter plot.
    plot(tu,tv,'.b');
    index1=find(tu>startp,1,'first');
    index2=find(tu<endp,1,'last');
    tu = tu;
    tv = tv;
    tu=tu(index1:index2);
    tv=tv(index1:index2);
    kt
    hold on
    plot(tu,tv,'.b');
    xdata = tu'+kt;
    ydata = tv';
    %% connect segmentations using linear fit.
    f = fittype('linearinterp'); 
    fit1 = fit(xdata,ydata,f);
    figure
    plot(fit1,'r-',xdata,ydata,'k.') 
    
    hold on
    plot(u+kt,v,'.b');
    datetick('x','mm-yyyy','keepticks')
    %% Output json files containing segmentation linear functions, start and end points, average residual error
    file = fopen('output.json','w');
    fprintf(file,'\n');
    j = 1;
    res = 0;
    c = 0;
    for i=1:k
        if (~isnan(v(i)))
            while (u(i)<xdata(j))
                j= j+1;
                if (j>length(xdata))
                    break
                end
            end
            j = 5;
            res = res + fit1.p.coefs(j,1)*u(i) +fit1.p.coefs(j,1) - v(i);
            c = c+1;
        end
    end
    for i=1:5
        fprintf(file,jsonencode(["start",xdata(i);"starting value",ydata(i);"end",xdata(i+1);"ending value",ydata(i+1);"function","y="+fit1.p.coefs(i,1)+"x"+"+"+ fit1.p.coefs(i,2)]));
        fprintf(file,'\n');
    end
    fprintf(file,jsonencode(["average residual error",res/c;"number of points",c]));
    hold off