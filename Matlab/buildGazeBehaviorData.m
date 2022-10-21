function [distanceToHoopFirstGaze, timeBeforeReachingHoopFirstGaze, LAF, gazeDistance, ...
    timeAfterPreviousHoopFirstGazeNextHoop, timeBetweenHoops, LAFthroughHoop] = ...
    buildGazeBehaviorData(gazeData, hoopData, hoopNumber, block, hoopFrames)

    gazeDistance = NaN;
    LAF = NaN;
    timeBeforeReachingHoopFirstGaze = NaN;
    distanceToHoopFirstGaze = NaN;
    timeAfterPreviousHoopFirstGazeNextHoop = NaN; 
    timeBetweenHoops = NaN;
    LAFthroughHoop = NaN;
    
    gazeX = gazeData.('RE_Gaze_Pos(x)');
    gazeY = gazeData.('RE_Gaze_Pos(y)');
    gazeZ = gazeData.('RE_Gaze_Pos(z)');
    
    droneX = gazeData.('Position(x)');
    droneY = gazeData.('Position(y)');
    droneZ = gazeData.('Position(z)');
    
    gazeTarget = gazeData.('RE_Gaze_Target');
    

    
    if block<5
        hoopName = hoopData.('ObjectName');
        hoopPosX = hoopData.('Position(x)');
        hoopPosY = hoopData.('Position(y)');
        hoopPosZ = hoopData.('Position(z)');
    elseif block==5
        hoopName = flip(hoopData.('ObjectName'));
        hoopPosX = flip(hoopData.('Position(x)'));
        hoopPosY = flip(hoopData.('Position(y)'));
        hoopPosZ = flip(hoopData.('Position(z)'));
    end
    
    throughHoop = gazeData.('RE_Gaze_Thru_Gate');
    
    
    i = hoopNumber;
    
    currHoopName = hoopName(i);
    
    frameHoopsPassed = getFrameHoopPassed(gazeData, currHoopName);
    
    if i>1
        if block==5 && i == length(hoopName)
            prevHoopName = hoopName(end);
        else
            prevHoopName = hoopName(i-1);
        end
        prevHoopPassedFrame = getFrameHoopPassed(gazeData, prevHoopName);
        
        
        timeBetweenHoops = frameHoopsPassed - prevHoopPassedFrame;
    end
    

    for j=1:size(gazeData,1)
        if strcmp(gazeTarget{j}, currHoopName) || strcmp(gazeTarget{j}, strcat(currHoopName,'_CenterCollider')) ...
                || strcmp(gazeTarget{j}, strcat(currHoopName,'_GateHoop'))
            
            distanceToHoopFirstGaze = sqrt((droneX(j)-hoopPosX(i))^2 + (droneY(j)-hoopPosY(i))^2 + (droneZ(j) - hoopPosZ(i))^2);
            
            timeBeforeReachingHoopFirstGaze = (j - frameHoopsPassed)/60;
            if i>1
                timeAfterPreviousHoopFirstGazeNextHoop = j - prevHoopPassedFrame;
            else
                timeAfterPreviousHoopFirstGazeNextHoop = NaN;
            end
            
            currThroughHoop = throughHoop(j);
            
            if i>1
                LAF = j < prevHoopPassedFrame;
                
                LAFthroughHoop = LAF && ~isempty(currThroughHoop);  
            else
                LAF = 0;
            end
            
            gazeDistance = sqrt(gazeX(j)^2 + gazeY(j)^2 + gazeZ(j)^2);

            break

        end
    end
    
    
    distanceToHoopFirstGaze;

end

function f = getFrameHoopPassed(gazeData, hoopNum)
    passedHoopVector = gazeData.('RE_First_Pass_Through_Gate');
    for i=1:size(gazeData,1)
       HoopName_GateHoop = strcat(hoopNum, '_GateHoop');
       HoopName_CenterCollider = strcat(hoopNum, '_CenterCollider');
       currPassedHoopVectorObject = passedHoopVector(i);
       if strcmp(currPassedHoopVectorObject{1}, HoopName_GateHoop) || strcmp(currPassedHoopVectorObject{1}, HoopName_CenterCollider)
           f = i;
           break
       else
           f = NaN;
       end
    end
end




