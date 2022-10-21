function minDistanceToHoopFrame = findCurrentHoopToPass(positionData, hoopPositions, b)
    %% I am unsure if this function is actually finding the frame that the drone passes through or by the hoop. It might not take into account collisions and going backwards for some reason. 
    prevDistance = 0;
    changeInDistance = 0;
    currHoop = 1;
    positionData = positionData';
    
    maxHoops = size(hoopPositions, 2);
    
    minDistanceToHoopFrame = zeros(2, size(hoopPositions, 2));
    prevFrames = 0;

    if b<5
        
        for j=1:2
            positionDataTemp = positionData(:,positionData(4,:)==j-1);
            prevMinDistance = 0;
            for i=1:size(hoopPositions, 2)
                i,j;


                xcomponent = (positionDataTemp(1,:)-hoopPositions(1,i)).^2;
                ycomponent = (positionDataTemp(2,:)-hoopPositions(2,i)).^2;
                zcomponent = (positionDataTemp(3,:)-hoopPositions(3,i)).^2;
                distanceToHoop = sqrt(xcomponent + ycomponent + zcomponent);


                [a, minDistanceFrame] = min(distanceToHoop);
                
%                 if minDistanceFrame < prevMinDistance
%                     [a, minDistanceFrame] = min(distanceToHoop(prevMinDistance:end));
%                     minDistanceFrame = minDistanceFrame + prevMinDistance;
%                 end
                
                if isempty(minDistanceFrame + prevFrames)
                    minDistanceToHoopFrame(j,i) = NaN;
                else
                    minDistanceToHoopFrame(j,i) = minDistanceFrame + prevFrames;
                end
                
                prevMinDistance = minDistanceFrame;
            end
            prevFrames = size(positionDataTemp, 2);
        end
    else
        hoopList = 1:maxHoops;
        
        for j=1:2
            prevMinDistance = 0;
            positionDataTemp = positionData(:,positionData(4,:)==j-1);
            for i=hoopList
                i;


                xcomponent = (positionDataTemp(1,:)-hoopPositions(1,i)).^2;
                ycomponent = (positionDataTemp(2,:)-hoopPositions(2,i)).^2;
                zcomponent = (positionDataTemp(3,:)-hoopPositions(3,i)).^2;
                distanceToHoop = sqrt(xcomponent + ycomponent + zcomponent);


                [a, minDistanceFrame] = min(distanceToHoop);

                if minDistanceFrame < prevMinDistance
                    [a, minDistanceFrame] = min(distanceToHoop(prevMinDistance:end));
                end
                
                minDistanceToHoopFrame(j,maxHoops-i+1) = minDistanceFrame + prevFrames;
                prevMinDistance = minDistanceFrame;

            end
            prevFrames = size(positionDataTemp, 2);
        end
        
    end
end