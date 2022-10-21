function [datasetVector, numFrames] = findStraightPathSegments(positionData, hoopPositionData, Subject, Condition, Block)
    
    numSeconds = 1;
    timeDelay = 60*numSeconds;

    threshold = 0.90;

    numFrames = size(positionData,1);
    
    xv = positionData.('Position(x)');
    yv = positionData.('Position(y)');
    zv = positionData.('Position(z)');
    
    straightPathVector = zeros(1,numFrames);
    
    gazePassData = positionData.('RE_First_Pass_Through_Gate');
    gazePassFrames = find(~cellfun(@isempty,gazePassData));
    hoopPos = [hoopPositionData.('Position(x)'), hoopPositionData.('Position(y)'), hoopPositionData.('Position(z)')];
    
    passedNames = findHoopsPassedThrough(gazePassData);
    
    for i=1:numFrames
        
        
        
        if i>timeDelay
            x1 = xv(i-timeDelay);
            y1 = yv(i-timeDelay);
            z1 = zv(i-timeDelay);
            
            xend = xv(i);
            yend = yv(i);
            zend = zv(i);
            
            straightDistance = sqrt((x1-xend)^2 + (y1-yend)^2 + (z1-zend)^2);
            
            actualX = xv((i-timeDelay):i);
            actualY = yv((i-timeDelay):i);
            actualZ = zv((i-timeDelay):i);
            
            
%             plot([x1 xend],[z1 zend],'r')
%             hold on;
%             plot(actualX,actualZ, 'b')
%             hold off;
%             drawnow;
            
            actualDistance = findPathLength(actualX, actualY, actualZ);
        
            proportionDistance = straightDistance/actualDistance;
            
            if proportionDistance > threshold
                straightPathVector(i) = 1;
            else
                straightPathVector(i) = 0;
            end
            
        end
        
        
    end
    
    GazeThroughGate = positionData.('RE_Gaze_Thru_Gate');
    GazeTarget = positionData.('RE_Gaze_Target');
    HeadingTarget = positionData.('RE_Heading_Target');
    StraightPathBool = straightPathVector';
    Subject = repelem(Subject, numFrames)';
    Condition = repelem(Condition, numFrames)';
    Block = ones(1,numFrames)'*Block;
    
    for j=passedNames(2:end)'
        splitName1 = split(j, ' ');
        splitName2 = split(splitName1(2), '_');
        hoopNumber = str2num(splitName2{1})+1;
        hoopPositionTemp = hoopPos(hoopNumber, :);
        dronePosition = [xv, yv, zv ];
        distanceMag = real(sqrt(sum((hoopPositionTemp.*ones(size(dronePosition)))-dronePosition,2).^2));
        distanceBool = distanceMag<10;
        StraightPathBool(distanceBool) = NaN;
    end
    
    datasetVector = table(Subject, Condition, Block, GazeThroughGate ,GazeTarget,  HeadingTarget, StraightPathBool);
    
end

function totalL = findPathLength(componentX, componentY, componentZ)
    L = zeros(1,length(componentX));
    
    for i=2:length(componentX)
        
        dx = componentX(i-1) - componentX(i);
        dy = componentY(i-1) - componentY(i);
        dz = componentZ(i-1) - componentZ(i);
        
        L(i) = sqrt(dx^2 + dy^2 + dz^2);
    end
    
    totalL = sum(L);

end

function passedNames = findHoopsPassedThrough(passedData)
        passedIndexes = find(~cellfun(@isempty,passedData));
        passedNames = unique(passedData(passedIndexes));

end
