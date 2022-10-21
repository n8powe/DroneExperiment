function writeHoopNormalPointData()

    hoopPositionData = getObstacleData('obstacle_dataFixed.txt');

    parsedGateDataAnalysis(hoopPositionData);

end


function hoopPositions = parsedGateDataAnalysis(gateData)
    %% write function that finds distance between hoop and drone and it's changing magnitude. \
    %  When it is shrinking they are moving towards it when it is decreasing they are moving away from it presumably to the next hoop
    hoopPositions = zeros(7, length(unique(gateData.ObjectName))+10);
    Len = length(unique(gateData.ObjectName));
    hoopWidth = 7;
    R = 'R';
    L = 'L';
    S = 'S';
    hoopDirection = [R,L,S,L,S,R,R,R,R,R,L,L,L,S,S,R,R,L,R,R,R,R,R,L,L,L,S,S,L,L,R,R,R,R,S,L,L,R,R,R,R,S];
    dfLogical = 0;
    for i=2:Len
        i;
        currHoopName = gateData.ObjectName{i};
        hoopSplit = split(currHoopName, ' ');
        hoopNumber = str2num(hoopSplit{2})+1;
        hoopName = {currHoopName};
        %hoopPositionIndex = find(strcmp(gateData.ObjectName, hoopName));
        
        x = gateData.('Position(x)');
        y = gateData.('Position(y)');
        z = gateData.('Position(z)');
        X = x(i);
        Y = y(i);
        Z = z(i);
        
        orientx = gateData.('Orientation(x)');
        orienty = gateData.('Orientation(y)');
        orientz = gateData.('Orientation(z)');
        orientw = gateData.('Orientation(w)');
        
        quat = [orientw(i), orientx(i), orienty(i), orientz(i)];
        
        eulerAngles = quat2eul(quat);
        
        orientX = eulerAngles(3);%*(pi/180);
        orientY = abs(eulerAngles(2));%*(pi/180);
        orientZ = eulerAngles(1);%*(pi/180);
        
        p1x = x(i) + sin(orientY)*hoopWidth;
        p1y = z(i) + cos(orientY)*hoopWidth;
        
        p2x = x(i) - sin(orientY)*hoopWidth;
        p2y = z(i) - cos(orientY)*hoopWidth;
        
        rotatedp1x = (p1x - x(i))*cos(pi/2) - (p1y - z(i))*sin(pi/2) + x(i);
        rotatedp1y = (p1x - x(i))*sin(pi/2) - (p1y - z(i))*cos(pi/2) + z(i);
        
        rotatedp2x = (p2x - x(i))*cos(pi/2) - (p2y - z(i))*sin(pi/2) + x(i);
        rotatedp2y = (p2x - x(i))*sin(pi/2) - (p2y - z(i))*cos(pi/2) + z(i);
        
        Direction = {hoopDirection(hoopNumber)};
        
        
        if dfLogical == 0
            currentDF = table(hoopName, hoopNumber, X, Y, Z, orientX, orientY, orientZ, p1x, p1y, p2x, p2y, rotatedp1x, rotatedp1y, rotatedp2x, rotatedp2y, Direction);
            dfLogical=1;
        else
            DF = table(hoopName, hoopNumber, X, Y, Z, orientX, orientY, orientZ, p1x, p1y, p2x, p2y, rotatedp1x, rotatedp1y, rotatedp2x, rotatedp2y, Direction);
            currentDF = [currentDF; DF];
        end
    end
    hoopPositions = hoopPositions(:,any(hoopPositions,1));
    
    currentDF.Properties.VariableNames = {'ObjectName' 'HoopNumber' 'Position(x)' 'Position(y)' 'Position(z)' 'Orientation(x)' 'Orientation(y)' 'Orientation(z)' ...
        'Point1x' 'Point1y' 'Point2x' 'Point2y' 'RotatedPoint1x' 'RotatedPoint1y' 'RotatedPoint2x' 'RotatedPoint2y' 'Direction'};
    %writetable(currentDF, 'gateOrientationNormalizedPointsDataset.txt');
    
    for i=1:42
        
       plot(hoopPositions(1,i), hoopPositions(3,i), 'bo')
       xlim([min(hoopPositions(1,:)), max(hoopPositions(1,:))])
       ylim([min(hoopPositions(3,:)), max(hoopPositions(3,:))])
       
       pbaspect([1 1 1])
       drawnow; 
        pause(2)
    end
end


function d = getGateData(name)


    d = readtable(name, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true);

end

function d = getObstacleData(name)


    d = readtable(name, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true, 'HeaderLines', 0);

end