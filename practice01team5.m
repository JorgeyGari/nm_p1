% Laura Belizón Merchán              100.452.273
% Jorge Lázaro Ruiz                  100.452.172
% Jesús Salvador Martínez Alcaide    100.452.289
% Jorge Ruesta Boceta                100.432.547

clear;

% LOADING DATA
disp('Loading data...');
load('datapr2.mat','-mat');
disp('Data loaded.');
    % Renaming variables
datapr2.Properties.VariableNames{1} = 'Currencies';
datapr2.Properties.VariableNames{2} = 'Date';
datapr2.Properties.VariableNames{3} = 'Time';
datapr2.Properties.VariableNames{4} = 'Value';

% CURRENCY PAIR SELECTION
disp(' ');
disp('CURRENCY PAIR SELECTION');
disp('1. EURUSD (Euro to US Dollar exchange)');
disp('2. XAUUSD (Gold to US Dollar exchange)');
selection = input('Select currency pair: ');

while (selection ~= 1 && selection ~=2)
    selection = input('Error. Select currency pair: ');
end

if selection == 1
    s = 'EURUSD';
    o = 10;
elseif selection == 2
    s = 'XAUUSD';
    o = 10000;
end

% CREATING CURRENCY MATRIX
c = 1;
d = 1;
curr = zeros();
    % Finding our currency pair
disp('Searching for relevant section...');
while (s ~= datapr2.Currencies(c:c))
    c = c + 1;
end
disp('Relevant section found.');
disp('Copying relevant data to a matrix...');
    % Copying relevant data
curr(d,1) = datapr2.Date(c:c);
curr(d,2) = datapr2.Time(c:c);
curr(d,3) = datapr2.Value(c:c);
while (curr(d,3) > o)
    curr(d,3) = curr(d,3) / 10;
end
d = d + 1;
c = c + 1;
while (datapr2.Currencies(c-1:c-1) == datapr2.Currencies(c:c) && c < height(datapr2))
    curr(d,1) = datapr2.Date(c:c);
    curr(d,2) = datapr2.Time(c:c);
    curr(d,3) = datapr2.Value(c:c);
    while (curr(d,3) > o)
        curr(d,3) = curr(d,3) / 10;
    end
    d = d + 1;
    c = c + 1;
end
% Note: Relevant rows for EURUSD:  81654 - 91856
%                     for XAUUSD: 142190 - 152048
disp('Relevant data copied to a matrix.');

% TIMELAPSE SELECTION (h)
disp(' ');
disp('TIMELAPSE SELECTION');
disp('1. Five minutes');
disp('2. One hour');
disp('3. One day');
disp('4. One week');
timelapse = floor(input('Select the timelapse: ')); % The floor function is to make sure the user doesn't input a number with decimal places inside the interval [1,4]

while ((timelapse < 1) || (timelapse > 4))
    timelapse = floor(input('Error. Select the timelapse: '));
end

switch (timelapse)
    case 1
        frequency = 'five minutes';
    case 2
        frequency = 'one hour';
    case 3
        frequency = 'day';
    case 4 
        frequency = 'week';
end

%Find initial timelapses
if(timelapse == 1)
    prevrow = 1;
    currentrow = 2;
    nextrow = 3;
elseif(timelapse == 2)
    prevrow = 1;
    
    %Find second hour
    pos = prevrow + 1;
    bFound = 0;
    while (bFound == 0 && pos <= length(curr))
        if((curr(pos,2) == 0) || (rem(curr(pos,2), 10000) == 0 ))
            bFound = 1;
        else
            pos = pos + 1;
        end
        
    end
    if(pos <= length(curr) )
        currentrow = pos;
    end
    %Find third hour
    pos = currentrow + 1;
    bFound = 0;
    while (bFound == 0 && pos <= length(curr))
        if((curr(pos,2) == 0) || (rem(curr(pos,2), 10000) == 0 ))
            bFound = 1;
        else
            pos = pos + 1;
        end       
    end
    if(pos <= length(curr) )
        nextrow = pos;
    end
elseif(timelapse == 3)
    %First day
    prevrow = 1;
    
    %Find second day
    pos = prevrow + 1;
    bFound = 0;
    while (bFound == 0 && pos <= length(curr))
        if(curr(pos,2) == 0)
            bFound = 1;
        else
            pos = pos + 1;
        end
        
    end
    if(pos <= length(curr) )
        currentrow = pos;
    end
    %Find third day
    pos = currentrow + 1;
    bFound = 0;
    while (bFound == 0 && pos <= length(curr))
        if(curr(pos,2) == 0 )
            bFound = 1;
        else
            pos = pos + 1;
        end       
    end
    if(pos <= length(curr) )
        nextrow = pos;
    end
elseif(timelapse == 4)
    %First week
    prevrow = 1;
    
    %Second week
    
    pos = 2;
    countdays = 0;
    while (countdays < 5 && pos <= length(curr))
        if(curr(pos,1) ~= curr (pos-1,1))
            countdays = countdays + 1;
        end
        if (countdays ~= 5)
            pos = pos+1;
        end
    end
    
    %Position found before the end of the matrix
    if(countdays == 5 )
        currentrow = pos;
    end
    
    %Third week
    pos = currentrow + 1;
    countdays = 0;
    while (countdays < 5 && pos <= length(curr))
        if(curr(pos,1) ~= curr (pos-1,1))
            countdays = countdays + 1;
        end
        if (countdays ~= 5)
            pos = pos+1;
        end
    end
    
    %Position found before the end of the matrix
    if(countdays == 5 )
        nextrow = pos;
    end
end

% COMPUTING THE ERROR
worsterror = 0;
worstrow = currentrow;
norm = 0;

%Vectors that store real and predicted values
realvect = [];
errorvect = [];

while (nextrow <= length(curr))
    % Applying the formula: R(t+h) - R(t) = R(t) - R(t-h)
    % Solving for R(t+h): R(t+h) = 2R(t) - R(t-h)
    prediction = 2*curr(currentrow,3) - curr(prevrow,3);
    % Dividing by the real value to get the relative error
    relerror = 100*abs(curr(nextrow,3) - prediction)/curr(nextrow,3); % As a percentage
    
    realvect = [realvect curr(nextrow,3)];
    errorvect = [errorvect prediction];
    
    if worsterror < relerror
        worsterror = relerror;
        worstrow = currentrow;
    end
    
    norm = norm + relerror*relerror;
    
    prevrow = currentrow;
    currentrow = nextrow; 
    
    % Find next timelapse
    if(timelapse == 1)
        nextrow = currentrow + 1;
    elseif(timelapse == 2)
        %Find second hour
        pos = currentrow + 1;
        bFound = 0;
        while (bFound == 0 && pos <= length(curr))
            if((curr(pos,2) == 0) || (rem(curr(pos,2), 10000) == 0 ))
                bFound = 1;
            else
                pos = pos + 1;
            end
            
        end
        
        if(pos <= length(curr) )
            nextrow = pos;
        else
            nextrow = length(curr) + 1; %Next interval is out of matrix index
        end
        
    elseif(timelapse == 3)
        
        pos = currentrow + 1;
        bFound = 0;
        while (bFound == 0 && pos <= length(curr))
            if(curr(pos,2) == 0)
                bFound = 1;
            else
                pos = pos + 1;
            end
            
        end
        if(pos <= length(curr) )
            nextrow = pos;
        else
            nextrow = length(curr) + 1; %Next interval is out of matrix index
        end
        
    elseif(timelapse == 4)
        
        pos = currentrow + 1;
        countdays = 0;
        while (countdays < 5 && pos <= length(curr))
            if(curr(pos,1) ~= curr (pos-1,1))
                countdays = countdays + 1;
            end
            if(countdays ~= 5)
                pos = pos+1;
            end
        end
    %Position found before the end of the matrix
        if(countdays == 5 )
            nextrow = pos;
        else
            nextrow = length(curr) + 1; %Next interval is out of matrix index
        end
    end
end

% Transforming the raw dates into presentable ones
aux = curr(worstrow,2)/100;
minutes = round(((aux/100)-floor(aux/100))*100);
hours = ((aux-minutes)/100);
day = ((curr(worstrow,1)/100)-floor(curr(worstrow,1)/100))*100;
day = round(day*10)/10;
aux2 = (curr(worstrow,1)-day)/100;
month = (((aux2/100)-floor(aux2/100))*100);
month = round(month);
year = ((curr(worstrow,1)-month-day)/10000);
year = round(year);

disp('Finished.');
fprintf('\nCurrency pair and timelapse: %s measured at every %s\n', s, frequency);
fprintf('Worst relative error: %f%%\n',worsterror);
fprintf('Norm of relative errors vector: %f\n', sqrt(norm)/100);
fprintf('Time and date of the worst relative error: %d/%d/%d at %02d:%02d:00\n', day, month, year, hours, minutes);



% AFTERMATH
selection = input('\n1. See answers to questions.\n2. Show plot\n3. Exit\nSelect an option: ');

while ((selection~=1) && (selection~=2) && (selection ~= 3))
    s = input('Error. Select an option: ');
end

switch (selection)
    case 1
        % Setting up some tables that will help illustrate our conclusions
        TimeInterval = ["5 minutes";"1 hour";"1 day";"1 week"];
        WorstRelativeError = ["0.387266%";"0.448351%";"0.723407%";"1.677792%"];
        Norm = ["0.025968";"0.024474";"0.019717";"0.031024"];
        Date = ["August 18th";"August 4th";"August 16th";"August 2nd"];
        Time = ["20:05";"16:00";"00:00";"00:00"];
        
        tEURUSD = table(TimeInterval,WorstRelativeError,Norm,Date,Time);
        
        TimeInterval = ["5 minutes";"1 hour";"1 day";"1 week"];
        WorstRelativeError = ["2.922985%";"5.956144%";"2.110663%";"4.256009%"];
        Norm = ["0.080498";"0.098434";"0.059800";"0.062371"];
        Date = ["August 9th";"August 9th";"August 16th";"August 9th"];
        Time = ["01:00";"01:00";"00:00";"00:00"];
        
        tXAUUSD = table(TimeInterval,WorstRelativeError,Norm,Date,Time);
        
        TimeInterval = ["5 minutes";"1 hour";"1 day";"1 week"];
        WorstRelativeError = ["1.164052%";"1.498793%";"2.110663%";"3.544595%"];
        Norm = ["0.063654";"0.061409";"0.059632";"0.045593"];
        Date = ["August 16th";"August 6th";"August 16th";"August 2nd"];
        Time = ["00:00";"14:00";"00:00";"00:00"];
        
        tXAUUSDmodified = table(TimeInterval,WorstRelativeError,Norm,Date,Time);
        
        fprintf('\n1. WHAT IS THE WORST POSSIBLE TIMELAPSE TO MAKE THIS ASSUMPTION?\n');
        fprintf('        Observing the results with the first currency pair (EURUSD), we can draw a clear pattern:\nthe longer the interval is, the higher the worst relative error will be. This leads us to believe\nthat the shorter the interval of measure is, the more accurate our approximation will be, similar\nto the famous coastline paradox. However, the norm of the relative error vector gets smaller when\nwe increase the time interval. We can interpret this as the algorithm taking less data and\ntherefore the norm having less summands as the interval gets longer. The exception to this rule is\nthe norm of the vector for the timelapse of one week, which is the biggest one. We can attribute\nthis to the fact that the largest relative error is significantly higher than the second biggest\none, probably due to real-world events. This sort of anomaly will be better understood after we\nanalyze the second pair and address Question 2.\n\n');
        
        disp('EURUSD results:');
        disp(tEURUSD);
        
        fprintf('        With the second currency pair (XAUUSD), things get trickier. Taken at face value, the data\ndon’t seem to follow a clear pattern, with the highest relative error and norm taking place when\nmeasuring every hour, a result that would contradict what we had established with the previous\npair. However, since it seemed strange that August 9th appeared so often in our program, we\nhad the hypothesis that this day was particularly bad for this currency exchange. Taking a look\nat the raw data, we can see the value took a dip this day due to some events which will be \nfurther explained in the next question. Since, were we to ignore this anomaly, the results almost\nseemed to follow a similar pattern to the ones we got with the first pair, we went ahead and\ndisregarded this day and ran the program again to test our hypothesis. The results after this\nslight modification fit neatly into the pattern we were expecting: the norm kept decreasing as the \ntimelapse and worst relative error increased.\n\n');
        
        disp('XAUUSD results:');
        disp(tXAUUSD);
        disp('XAUUSD results (excluding August 9th):');
        disp(tXAUUSDmodified);
        
        fprintf('        In conclusion, under normal conditions, the worst relative error occurs when taking a\ntimelapse of one week, the biggest out of the four we have tested.');
        
        fprintf('\n\n2. WHAT HAPPENED THE DAY/WEEK OF THE WORST RELATIVE ERRORS THAT COULD HAVE CAUSED THEM?\n');
        fprintf('        The worst relative error in the currency pair EURUSD happened in the week of the 2nd of\nAugust, while the worst error for the hour timelapse fell in that same week (the 4th of August).\nDuring that week the EURUSD proportion lowered its value significantly, this could be\nattributed to the fact that the governor of Missouri absolved a couple who pointed a gun at \nBlack Lives Matter protesters, causing a major outrage. But the worst relative error has a rather\nsmall value (1.677792%%), which leads us to believe that we should not jump to conclusions as to \nwhat the main reason was for this to happen.\n\n');
        fprintf('        Regarding the second currency pair (XAUUSD) we can observe that 3 of the 4 worst\nrelative errors happened on the 9th of August, including the worst overall (the one in the hour \ntimelapse). Apparently, the US had been evacuating troops from Afghanistan for the past month,\nbut by the 9th of August the Taliban had just recently taken up more than half of the country and \nseized control of an important strategic location. This may have caused the XAUUSD \nproportion to go down aggressively causing the error in the process.\n\n');    

        fprintf('3. WHAT CAN WE LEARN TODAY ABOUT THE DERIVATIVES OF FINANCIAL FUNCTIONS?\n');
        fprintf('        We know that the derivative of a function tells us if that function is increasing or decreasing\nover an interval. Therefore, one could be tempted to differentiate these financial functions to see\ntheir behaviour in the future.\n\n');
        fprintf('        But making this assumption is a big error because these functions are not even continuous. In\nour case, we have that the functions are discrete because they only take values from timelapse to\ntimelapse, but we don’t know the values between them.\n\n');
        fprintf('        If we try to plot any of our functions at MATLAB,  the representation that the program gives \nus joins our discrete values with straight lines. Thanks to this plotting now we have a sort of \ncontinuous function, but it is still not differentiable because we have a lot of peaks. Actually, we \nhave a peak every time we join a point with the previous and the next one.\n\n');
        fprintf('        The discrepancy is more apparent when we deal with currency exchanges that are not really\nstable, like in the case of XAUUSD, where the relative errors are much bigger in comparison\nwith EURUSD, which is much more stable.\n');
    case 2
        %Ploting functions
        length1 = 1:length(realvect);
        length2 = 1:length(errorvect);
        plot(length1,realvect,'b',length2,errorvect,'r')
        legend('Real value','Predicted value')

    
    case 3
        disp('Goodbye.');
        disp('   -- Team 5');
end
        