function generatePerformanceMeasureDataset()
    
    % Create folder containing each dataset for each condition -- 3 folders
    % per participant. Place the path in the following variable. 
    subjectDataSets = { 'P_211013154622_50', 'P_211015152112_10', 'P_210930142529_100', 'P_210929172928_200_300', 'P_210928152127_40',  'P_220207122313_Nate'};
    conditions = {'/PathOnly/', '/PathAndHoops/', '/HoopOnly/'};
    hoopFolder = 'HoopFiles/';
    positionFolder = 'Output_positionFiles/';
    
    % Name of the output dataset
    
    
    prevTableExists = 0;
    for sb=subjectDataSets
        %conditionPerformanceMeasureDatasetOutput = strcat(sb, '_performanceMeasureDataset.txt');
        sb = strcat('Experiment1/', sb(1));
        for cnd=conditions
            
            hoopFolderPath = strcat(sb{:}, cnd{:}, hoopFolder);
            positionFolderPath = strcat(sb{:}, cnd{:}, positionFolder);
            
            hoopFolderInfo = dir(fullfile(hoopFolderPath, '*.txt'));
            hoopFolderNames = hoopFolderInfo.name;
            
            positionFolderInfo = dir(fullfile(positionFolderPath, '*.txt'));
            positionFolderNames = positionFolderInfo.name;
            
            for b=1:length({positionFolderInfo(:).name})
                    
                    currHoopFile = strcat(hoopFolderPath, hoopFolderInfo(b).name);
                    currPositionFile = strcat(positionFolderPath, positionFolderInfo(b).name);
                    
                    
                    if strcat(positionFolder, 'FinalPositions/')
                        posData = readtable(currPositionFile, 'delimiter', ',','ReadVariableNames', true, 'PreserveVariableNames', true);
                    else
                        posData = readtable(currPositionFile, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true);
                    end
                    hoopData = readtable(currHoopFile, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true);
                    
                    posFileSplit = split(currPositionFile, '_');
                    block = posFileSplit(end-1);
                    
                    if prevTableExists == 0
                        prevCurrBlockPerformance = createCurrentBlockDataframe(sb, cnd{1}(2:end-1), str2double(block), hoopData, posData);
                        prevTableExists = 1;
                    else
                        CurrBlockPerformance = createCurrentBlockDataframe(sb, cnd{1}(2:end-1), str2double(block), hoopData, posData);
                        prevCurrBlockPerformance = [prevCurrBlockPerformance; CurrBlockPerformance];
                    end
                
            end
                
        end
        
    end
    
    writetable(prevCurrBlockPerformance, 'performanceMeasuresDataset.txt');
   
end


function prevDF = createCurrentBlockDataframe(Subject, condition, block, hoopData, positionData)
    prevDFLogical = 0;
    Condition = {condition};
    for lap=0:1
        lapHoopData = hoopData(hoopData.Lap==lap,:);
        lapPositionData = positionData(positionData.Lap_Number==lap, :);
        
        propHoopsCompleted = length(find(ismember(lapHoopData.Passed, 'True')))/length(lapHoopData.Passed(:));
        
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
          
          
          if prevDFLogical==0
                prevDF = table(Subject, Condition, block, lap, propHoopsCompleted, timeToCompleteLap, avgSpdAdjustedForScaling, PathDeviation, noCollisions, ...
                    hoopCollisions, treeCollisions, pathCollisions, otherCollisions);
                prevDFLogical = 1;
          else
                df = table(Subject, Condition, block, lap, propHoopsCompleted, timeToCompleteLap, avgSpdAdjustedForScaling, PathDeviation, noCollisions, ...
                    hoopCollisions, treeCollisions, pathCollisions, otherCollisions);
                prevDF = [prevDF; df];
                
          end
         
    end

end



