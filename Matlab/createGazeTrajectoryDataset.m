function createGazeTrajectoryDataset()


    subjectDataSets = {'P_210930142529_100', 'P_211013154622_50', 'P_211015152112_10', 'P_210929172928_200_300', 'P_210928152127_40', 'P_220207122313_Nate'};
    %subjectDataSets = {'P_210930142529_100', 'P_211013154622_50', 'P_210928152127_40', 'P_220207122313_Nate'};
    %subjectDataSets = {'P_210930142529_100'};
    conditions = {'/PathAndHoops/', '/HoopOnly/'};
    %conditions = {'/PathOnly/'};
    hoopFolder = 'HoopFiles/';
    positionFolder = 'Output_positionFiles/';
    hoopPositionData = getObstacleData('gateOrientationNormalizedPointsDataset.txt');
    totalNumFrames = 0;
    dfLogical = 0;
    
    for sb = subjectDataSets
        sb = strcat('Experiment1/', sb(1));
        for cnd = conditions
            cnd
            
            positionFolderPath = strcat(sb{:}, cnd{:}, positionFolder);
            
            
            %hoopFolderNames = hoopFolderInfo.name;
            
            positionFolderInfo = dir(fullfile(positionFolderPath, '*.txt'));
            positionFolderNames = positionFolderInfo.name;
            for b=1:length({positionFolderInfo(:).name})
                b
                
                currPositionFile = strcat(positionFolderPath, positionFolderInfo(b).name);
                if strcat(positionFolder, 'FinalPositions/')
                    posData = readtable(currPositionFile, 'delimiter', ',','ReadVariableNames', true, 'PreserveVariableNames', true);
                else
                    posData = readtable(currPositionFile, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true);
                end
                posFileSplit = split(currPositionFile, '_');
                block = str2double(posFileSplit(end-1));
                
                if dfLogical == 0
                    [currentDF, numFrames] = findStraightPathSegments(posData, hoopPositionData, sb, cnd, block);
                    dfLogical=1;
                else
                    [DF, numFrames] = findStraightPathSegments(posData, hoopPositionData, sb, cnd, block);
                    currentDF = [currentDF; DF];
                end
                
                totalNumFrames = totalNumFrames + numFrames;
            
            end
            
        end
        
        
    end

    totalNumFrames
    writetable(currentDF, 'droneGazeTrajectoryDataset.txt');


end

function d = getObstacleData(name)

    if strcmp(name, 'obstacle_data.txt')
        d = readtable(name, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true, 'HeaderLines', 0);
    else
        d = readtable(name, 'delimiter', ',','ReadVariableNames', true, 'PreserveVariableNames', true, 'HeaderLines', 0);
    end
        

end