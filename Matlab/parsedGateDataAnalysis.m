function hoopPositions = parsedGateDataAnalysis(df, gateData, block)
    %% write function that finds distance between hoop and drone and it's changing magnitude. \
    %  When it is shrinking they are moving towards it when it is decreasing they are moving away from it presumably to the next hoop
    hoopPositions = zeros(16, length(unique(gateData.ObjectName))+10);
    L = 1:length(unique(gateData.ObjectName));
    
    if block==5
        L = length(unique(gateData.ObjectName)):-1:1;
        
    end
    
    ind = 1;
    for i=L
        i;
        currHoopName = gateData.ObjectName{i};
        hoopSplit = split(currHoopName, ' ');
        hoopNumber = str2num(hoopSplit{2})+1;
        
        %hoopPositionIndex = find(strcmp(gateData.ObjectName, hoopName));
        
        x = gateData.('Position(x)');
        y = gateData.('Position(y)');
        z = gateData.('Position(z)');
        
        orientx = gateData.('Orientation(x)');
        orienty = gateData.('Orientation(y)');
        orientz = gateData.('Orientation(z)');
        
        dir = gateData.Direction;
        
        if strcmp(dir{i},'R')
            direction = 0;
        elseif strcmp(dir{i}, 'L')
            direction = 1;
        else
            direction = 2;
        end
        
        rp1x = gateData.RotatedPoint1x;
        rp1y = gateData.RotatedPoint1y;
        rp2x = gateData.RotatedPoint2x;
        rp2y = gateData.RotatedPoint2y;
         p1x = gateData.Point1x;
         p1y = gateData.Point1y;
         p2x = gateData.Point2x;
         p2y = gateData.Point2y;
        
        hoopPositions(1,ind) = x(i);
        hoopPositions(2,ind) = y(i);
        hoopPositions(3,ind) = z(i);
        hoopPositions(4,ind) = hoopNumber;
        hoopPositions(5,ind) = orientx(i);
        hoopPositions(6,ind) = orienty(i);
        hoopPositions(7,ind) = orientz(i);
        hoopPositions(8,ind) = p1x(i);
        hoopPositions(9,ind) = p1y(i);
        hoopPositions(10,ind) = p2x(i);
        hoopPositions(11,ind) = p2y(i);
        hoopPositions(12,ind) = direction;
        hoopPositions(13,ind) = rp1x(i);
        hoopPositions(14,ind) = rp1y(i);
        hoopPositions(15,ind) = rp2x(i);
        hoopPositions(16,ind) = rp2y(i);
        
        %plot([p1x(i) p2x(i)], [p1y(i) p2y(i)], 'ko')
        %hold on;
        %plot([rp1x(i) rp2x(i)],[rp1y(i) rp2y(i)],'ro')
        %hold off;
        ind = ind + 1;
    end
    hoopPositions = hoopPositions(:,any(hoopPositions,1));
    
    %for i=1:40
        
     %   plot(hoopPositions(1,i), hoopPositions(3,i), 'bo')
       % xlim([min(hoopPositions(1,:)), max(hoopPositions(1,:))])
       % ylim([min(hoopPositions(3,:)), max(hoopPositions(3,:))])
       % drawnow;
        
        %pause(2)
    %end
end