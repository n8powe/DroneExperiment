function createDroneOrientationAtHoopDatasets()

    subjectDataSets = {'P_210928152127_40', 'P_210930142529_100', 'P_211013154622_50', 'P_210929172928_200_300',  'P_220207122313_Nate', 'P_211015152112_10'};
    %subjectDataSets = {'P_210930142529_100', 'P_211015152112_10', 'P_210929172928_200_300'};
    conditions = {'/HoopOnly/'};
    %conditions = {'/PathAndHoops/'};
    hoopFolder = 'HoopFiles/';
    %positionFolder = 'FinalPositions/';
    positionFolder = 'Output_positionFiles/';
    outputFileName = 'droneOrientationAtHoop.csv';
   
    %hoopPositionData = getObstacleData('obstacle_data.txt');
    hoopPositionData = getObstacleData('gateOrientationNormalizedPointsDataset.txt');
    
    dfLogical = 0;
    
    for sb = subjectDataSets
        sb = strcat('Data/Experiment1/', sb(1))
        for cnd = conditions
            cnd
            hoopFolderPath = strcat(sb{:}, cnd{:}, hoopFolder);
            positionFolderPath = strcat(sb{:}, cnd{:}, positionFolder);
            
            hoopFolderInfo = dir(fullfile(hoopFolderPath, '*.txt'));
            %hoopFolderNames = hoopFolderInfo.name;
            
            positionFolderInfo = dir(fullfile(positionFolderPath, '*.txt'));
            positionFolderNames = positionFolderInfo.name;
            for b=1:length({positionFolderInfo(:).name})
                b
                currHoopFile = strcat(hoopFolderPath, hoopFolderInfo(b).name);
                currPositionFile = strcat(positionFolderPath, positionFolderInfo(b).name);
                if strcat(positionFolder, 'FinalPositions/')
                    posData = readtable(currPositionFile, 'delimiter', ',','ReadVariableNames', true, 'PreserveVariableNames', true);
                else
                    posData = readtable(currPositionFile, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true);
                end
                hoopData = readtable(currHoopFile, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true);
                posFileSplit = split(currPositionFile, '_');
                block = str2double(posFileSplit(end-1));
                
                b == block

                if dfLogical == 0
                    currentDF = runAnalyses(sb{1}, cnd{1}, block, posData, hoopPositionData, hoopData, false);
                    dfLogical=1;
                else
                    DF = runAnalyses(sb{1}, cnd{1}, block, posData, hoopPositionData, hoopData, false);
                    currentDF = [currentDF; DF];
                end
            
            end
            
        end
        
        
    end

    
    writetable(currentDF, outputFileName);

end


function d = getObstacleData(name)

    if strcmp(name, 'obstacle_data.txt')
        d = readtable(name, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true, 'HeaderLines', 0);
    else
        d = readtable(name, 'delimiter', ',','ReadVariableNames', true, 'PreserveVariableNames', true, 'HeaderLines', 0);
    end
        

end