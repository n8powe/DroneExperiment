function generatePerformanceMeasureDatasetExperiment2()
    
    % Create folder containing each dataset for each condition -- 3 folders
    % per participant. Place the path in the following variable. 
    subjectDataSets = {'P_N', 'P_220208162954_40', 'P_211216144513_50'};
    %subjectDataSets = {'P_210930142529_100', 'P_211013154622_50', 'P_210928152127_40'};
    % subjectDataSets = {'P_211013154622_50'};
    conditions = {'/DenseTrees/', '/PathOnly/'};
    
    positionFolder = 'Output_positionFiles/';
    
    % Name of the output dataset
    
    
    prevTableExists = 0;
    for sb=subjectDataSets
        %conditionPerformanceMeasureDatasetOutput = strcat(sb, '_performanceMeasureDataset.txt');
        sb = strcat('Experiment2/', sb(1));
        for cnd=conditions
            
            
            positionFolderPath = strcat(sb{:}, cnd{:}, positionFolder);
            

            
            positionFolderInfo = dir(fullfile(positionFolderPath, '*.txt'));
            positionFolderNames = positionFolderInfo.name;
            
            for b=1:length({positionFolderInfo(:).name})
                    
                    
                    currPositionFile = strcat(positionFolderPath, positionFolderInfo(b).name);
                    
                    
                    if strcat(positionFolder, 'FinalPositions/')
                        posData = readtable(currPositionFile, 'delimiter', ',','ReadVariableNames', true, 'PreserveVariableNames', true);
                    else
                        posData = readtable(currPositionFile, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true);
                    end
                    %hoopData = readtable(currHoopFile, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true);
                    
                    posFileSplit = split(currPositionFile, '_');
                    block = posFileSplit(end-1);
                    
                    if prevTableExists == 0
                        prevCurrBlockPerformance = createCurrentBlockDataframe(sb, cnd{1}(2:end-1), str2double(block), 0, posData);
                        prevTableExists = 1;
                    else
                        CurrBlockPerformance = createCurrentBlockDataframe(sb, cnd{1}(2:end-1), str2double(block), 0, posData);
                        prevCurrBlockPerformance = [prevCurrBlockPerformance; CurrBlockPerformance];
                    end
                
            end
                
        end
        
    end
    
    writetable(prevCurrBlockPerformance, 'performanceMeasuresDatasetExperiment2.txt');
   
end


function prevDF = createCurrentBlockDataframe(Subject, condition, block, hoopData, positionData)
    prevDFLogical = 0;
    Condition = {condition};
    for lap=0:1
        %lapHoopData = hoopData(hoopData.Lap==lap,:);
        lapPositionData = positionData(positionData.Lap_Number==lap, :);
        
        propHoopsCompleted = 0; %length(find(ismember(lapHoopData.Passed, 'True')))/length(lapHoopData.Passed(:));
        
        timeToCompleteLap = (lapPositionData.Timestamp(end) - lapPositionData.Timestamp(1))/1000;
        
        %dDronePosX = gradient(lapPositionData.('Position(x)'), lapPositionData.Timestamp).^2;
        %dDronePosY = gradient(lapPositionData.('Position(y)'), lapPositionData.Timestamp).^2;
        %dDronePosZ = gradient(lapPositionData.('Position(z)'), lapPositionData.Timestamp).^2;
        
         %speedMagnitude = sqrt(dDronePosX + dDronePosY + dDronePosZ);
         %averageLapSpeed = mean(speedMagnitude);
         
         PathDeviation = mean(abs(lapPositionData.Path_Deviation))/5;
         
         [noCollisions, hoopCollisions, throughpercentages, otherCollisions, treeCollisions, pathCollisions] = findCollisionObjectCategories(lapPositionData);
         
          [ avgSpd, avgTime, ciSpd, ciTime] = getAverageSpeedAndTimeperLap(lapPositionData);
          avgSpdAdjustedForScaling = avgSpd/5; % Adjusted Meters per second
          
          
          lapPositionDataPath = lapPositionData(strcmp(lapPositionData.RE_Gaze_Target, "PathOutline"), :);
          lapPositionDataTerrain = lapPositionData(strcmp(lapPositionData.RE_Gaze_Target, "Terrain"), :);
          [meanDistanceToPointAtPass, timeToGazePoint, avgGazeDistance] = findTimeToReachGazePointOnPath(lapPositionDataPath);
          
%           plotGazeDistance(lapPositionData, 'k-', 1)
%           hold on;
%           plotGazeDistance(lapPositionDataPath, 'ro', 2)
%           hold off;
%           hold on;
%           plotGazeDistance(lapPositionDataTerrain, 'bo', 2)
%           hold off;
          
          if prevDFLogical==0
                prevDF = table(Subject, Condition, block, lap, propHoopsCompleted, timeToCompleteLap, avgSpdAdjustedForScaling, PathDeviation, noCollisions, ...
                    hoopCollisions, treeCollisions, pathCollisions, otherCollisions, timeToGazePoint, avgGazeDistance, meanDistanceToPointAtPass);
                prevDFLogical = 1;
          else
                df = table(Subject, Condition, block, lap, propHoopsCompleted, timeToCompleteLap, avgSpdAdjustedForScaling, PathDeviation, noCollisions, ...
                    hoopCollisions, treeCollisions, pathCollisions, otherCollisions, timeToGazePoint, avgGazeDistance, meanDistanceToPointAtPass);
                prevDF = [prevDF; df];
                
          end
         
    end

end

function [meanDistanceToPointAtPass, timeToPoint, avgDistance] = findTimeToReachGazePointOnPath(posData)

    dronePosX = posData.('Position(x)');
    dronePosZ = posData.('Position(z)');
    dronePosY = posData.('Position(y)');
    
    dronePositions = [dronePosX, dronePosZ];
    
    timeStamps = posData.Timestamp;
    
    gazePosX = posData.('RE_Gaze_Pos(x)');
    gazePosZ = posData.('RE_Gaze_Pos(z)');
    gazePosY = posData.('RE_Gaze_Pos(y)');
    
    fullDronePos = [dronePosX, dronePosY, dronePosZ];
    fullGazePos = [gazePosX, gazePosY, gazePosZ];
    
    avgDistance = mean(sqrt(sum((fullDronePos - fullGazePos).^2,2)))/5;
    
    
    distanceList = sqrt(sum((fullDronePos - fullGazePos).^2,2))/5;
    %plot(distanceList, 'b-')
    
    times = zeros(length(dronePosX),1);
    onesList = [ones(length(dronePosX), 1), ones(length(dronePosX), 1)];
    
    timeList = zeros(length(dronePosX),1);
    
    meanDistanceToPointAtPass = zeros(length(dronePosX),1);
    for i=1:length(times)
        
        currGazePos = [gazePosX(i), gazePosZ(i)];
        
        dronePosRelToGaze = sqrt(sum(((currGazePos.*onesList) - dronePositions).^2, 2))/5;
        
        [minDistance, minDistanceIndex] = min(dronePosRelToGaze);
        meanDistanceToPointAtPass(i) = minDistance;
        timeList(i) = (timeStamps(minDistanceIndex) - timeStamps(i))/1000;
        
    end
    meanDistanceToPointAtPass = mean(meanDistanceToPointAtPass);
    timeToPoint = mean(timeList(1:end-10));

end


function plotGazeDistance(posData, color, size_)
    dronePosX = posData.('Position(x)');
    dronePosZ = posData.('Position(z)');
    dronePosY = posData.('Position(y)');
    
    dronePositions = [dronePosX, dronePosZ];
    
    timeStamps = posData.Timestamp;
    
    gazePosX = posData.('RE_Gaze_Pos(x)');
    gazePosZ = posData.('RE_Gaze_Pos(z)');
    gazePosY = posData.('RE_Gaze_Pos(y)');
    
    fullDronePos = [dronePosX, dronePosY, dronePosZ];
    fullGazePos = [gazePosX, gazePosY, gazePosZ];
    
    avgDistance = mean(sqrt(sum((fullDronePos - fullGazePos).^2,2)))/5;
    
    
    
    distanceList = sqrt(sum((fullDronePos - fullGazePos).^2,2))/5;
    plot(timeStamps, distanceList, color, 'MarkerSize', size_)


end

