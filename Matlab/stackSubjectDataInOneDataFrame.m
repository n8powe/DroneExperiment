function stackSubjectDataInOneDataFrame()


    subjectDataSets = {'P_220207122313_Nate', 'P_211015152112_10', 'P_211013154622_50', 'P_210930142529_100', 'P_210929172928_200_300', 'P_210928152127_40'};
    %subjectDataSets = {'P_210930142529_100'};
    conditions = {'/PathOnly/', '/PathAndHoops/', '/HoopOnly/'};
    %conditions = {'/PathOnly/'};
    hoopFolder = 'HoopFiles/';
    %positionFolder = 'FinalPositions/';
    positionFolder = 'Output_positionFiles/';
   
    %hoopPositionData = getObstacleData('obstacle_data.txt');
    hoopPositionData = getObstacleData('gateOrientationNormalizedPointsDataset.txt');
    
    dfLogical = 0;
    
    for sb = subjectDataSets
        subject = strcat('Experiment1/', sb(1))
        for cnd = conditions
            cnd
            hoopFolderPath = strcat(subject{:}, cnd{:}, hoopFolder);
            positionFolderPath = strcat(subject{:}, cnd{:}, positionFolder);
            
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
                
                numRows = ones(1,size(posData,1));
                
                Subject = repelem(sb, length(numRows))';
                Condition = repelem(cnd, length(numRows))';
                Block = numRows'*block;
                
                posData.Subject = Subject;
                posData.Condition = Condition;
                posData.Block = Block;
                Frame = (1:length(numRows))';
                posData.Frame = Frame;
                
                
                
                subject = strcat('Experiment1/', sb(1))

                if dfLogical == 0
                    currentDF = posData;
                    dfLogical=1;
                else
                    DF = posData;
                    currentDF = [currentDF; DF];
                end
            
            end
            
        end
        
        
    end

    
    writetable(currentDF, 'stackedData.txt');


end

function d = getObstacleData(name)

    if strcmp(name, 'obstacle_data.txt')
        d = readtable(name, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true, 'HeaderLines', 0);
    else
        d = readtable(name, 'delimiter', ',','ReadVariableNames', true, 'PreserveVariableNames', true, 'HeaderLines', 0);
    end
        

end