function writeGazeObjectCategoriesExperiment2()

    subjectDataSets = {'P_211216144513_50', 'P_220208162954_40', 'P_N'};
    %subjectDataSets = {'P_210930142529_100', 'P_211013154622_50', 'P_210928152127_40'};
    % subjectDataSets = {'P_211013154622_50'};
    conditions = {'/DenseTrees/', '/PathOnly/'};
    %conditions = {'/HoopOnly/'};
    hoopFolder = 'HoopFiles/';
    positionFolder = 'Output_positionFiles/';
    hoopPositionData = getObstacleData('gateOrientationNormalizedPointsDataset.txt');

    numFramesTotal = 0;
    dfLogical = 0;
    
     for sb = subjectDataSets
        subject = sb;
        sb = strcat('Experiment2/', sb(1));
        for cnd = conditions
            condition = {cnd{1}(2:end-1)};
            
            positionFolderPath = strcat(sb{:}, cnd{:}, positionFolder);
            
            
            
            
            positionFolderInfo = dir(fullfile(positionFolderPath, '*.txt'));
            
            for b=1:length({positionFolderInfo(:).name})
                b;
                
                currPositionFile = strcat(positionFolderPath, positionFolderInfo(b).name);
                if strcat(positionFolder, 'FinalPositions/')
                    posData = readtable(currPositionFile, 'delimiter', ',','ReadVariableNames', true, 'PreserveVariableNames', true);
                else
                    posData = readtable(currPositionFile, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true);
                end
                posFileSplit = split(currPositionFile, '_');
                block = str2double(posFileSplit(end-1));
                
                if dfLogical == 0
                    [percToTerrain4deg, angleDF, meanDistanceToPathGazeTerrain, hoops, throughpercentages, terrain, trees, path, numFrames] = findCollisionObjectCategories(posData, cnd, hoopPositionData, block, sb);
                    currentDF = table(subject, condition, b, hoops, throughpercentages, terrain, trees, path, meanDistanceToPathGazeTerrain, percToTerrain4deg);
                    dfLogical=1;
                    currentAngleDF = angleDF;
                else
                    [percToTerrain4deg, angleDF, meanDistanceToPathGazeTerrain, hoops, throughpercentages, terrain, trees, path, numFrames] = findCollisionObjectCategories(posData, cnd, hoopPositionData, block, sb);
                    DF = table(subject, condition, b, hoops, throughpercentages, terrain, trees, path, meanDistanceToPathGazeTerrain, percToTerrain4deg);
                    currentDF = [currentDF; DF];
                    currentAngleDF = [currentAngleDF; angleDF];
                end

                numFramesTotal = numFramesTotal + numFrames;
                
            
            end
            
        end
        
        
    end

    numFramesTotal
    writetable(currentDF, 'gazeObjectDatasetExperiment2_dontUse.txt');

    
    writetable(currentAngleDF, 'gazeAnglesToPathCenterExp2_liveRecordedGaze.txt')



end

function [distance, angle, countsToTerrain4deg] = findGazeDistanceToPath(terrainPositions, pathComponents)

    gazePosX = terrainPositions.('Gaze_Location(x)');
    gazePosZ = terrainPositions.('Gaze_Location(z)');
    
    dronePosX = terrainPositions.('Position(x)');
    dronePosZ = terrainPositions.('Position(z)');
    currHoopDronePosition = [dronePosX, dronePosZ];
    currHoopGazeVector = [gazePosX, gazePosZ];

    countsToTerrain4deg = 0;
    distance = zeros(1, length(gazePosX));
    angle = zeros(1, length(gazePosX));
    onesList = ones(1,length(pathComponents))';
    for i=1:length(distance)
        gazePosition = [onesList.*gazePosX(i), onesList.*gazePosZ(i)];
        allDistance = sqrt(sum(((gazePosition - pathComponents).^2), 2))/5;
        [minDistance, minIndex] = min(allDistance);
        distance(i) = minDistance;
        
        pathPoints = pathComponents(minIndex, :);
        angle(i) = calculateXCorrAngle(currHoopDronePosition(i,:), ...
            currHoopGazeVector(i,:), pathPoints); % Angle between thrust and hoop 
        
        if abs(distance(i))<=4
            countsToTerrain4deg = countsToTerrain4deg + 1;
        end
        
        
    end
    

end

function [percToTerrain4deg, angleDF, meanDistanceToPathGazeTerrain, hoops, throughpercentages, terrain, trees, path, numFrames] = findCollisionObjectCategories(positionData, cnd, hoopData, block, subject)


    
    pathComponents = readPathOutline();
    terrainPositions = positionData(strcmp(positionData.Gaze_Target, 'Terrain'),:);
    [distanceFromPathWithGazeOnTerrain, angleFromPathWithGazeOnTerrain, countsToTerrain4deg] = findGazeDistanceToPath(terrainPositions, pathComponents);
    meanDistanceToPathGazeTerrain = mean(distanceFromPathWithGazeOnTerrain);
    
    pathPositions = positionData(strcmp(positionData.Gaze_Target, 'PathOutline'),:);
    [distanceFromPathWithGazeOnPath, angleFromPathWithGazeOnPath, ~] = findGazeDistanceToPath(pathPositions, pathComponents);
    
    pathLabels = [repelem("Path", length(distanceFromPathWithGazeOnPath)); distanceFromPathWithGazeOnPath; angleFromPathWithGazeOnPath];
    
    terrainLabels = [repelem("Terrain", length(distanceFromPathWithGazeOnTerrain)); distanceFromPathWithGazeOnTerrain; angleFromPathWithGazeOnTerrain];
    
    combinedDistance = [pathLabels, terrainLabels]';
    
    nFramesDistance = size(combinedDistance, 1);
    
    Condition = repelem(cnd, nFramesDistance)';
    Subject = repelem(subject, nFramesDistance)';
    Block = repelem(block, nFramesDistance)';
    
    Object = combinedDistance(:,1);
    Angle = combinedDistance(:,3);
    Distance =  combinedDistance(:,2);
    
    angleDF = table(Subject, Block, Condition, Object, Angle, Distance);
    
    %throughGatesIndices = cellfun(@isempty,positionData.Gaze_Through_Gate);
    
    %throughpercentages = sum(~throughGatesIndices)/length(throughGatesIndices);
    %numFrames = length(throughGatesIndices);
    throughpercentages = 0;
    objects = positionData.RE_Gaze_Target;
    [counts, elements] = groupcounts(objects);
    
    numFrames = sum(counts);
    
    percentages = counts/(sum(counts)); %+sum(~throughGatesIndices));

    
    treeNames =     cell([{'_Sp_PW_Tree_Pine_01_Hero'},...
    {'_Sp_PW_Tree_Pine_01_Long'},...
    {'_Sp_PW_Tree_Pine_02 Long'},...
    {'_Sp_PW_Tree_Pine_02_Hero'},...
    {'_Sp_PW_Tree_Sequoia_01'  },...
    {'_Sp_PW_Tree_Sequoia_02'  },...
    {'_Sp_PW_Tree_Spruce_01'   },...
    {'_Sp_PW_Tree_Spruce_04'   }]);
    
    
    
    closeTreeCounts = findTreeDistanceAverageInterhoopDistance(positionData, hoopData, treeNames, block);
    closeTreePercentages = closeTreeCounts/(sum(counts)); %+sum(~throughGatesIndices));
    
    hoops = findHoopFixationPercentage(elements, percentages);
    if isempty(hoops)
       hoops = 0; 
    end

    nullElements = percentages(1);
    terrain = percentages(find(strcmp(elements, 'Terrain'))) + nullElements;
    if isempty(terrain)
       terrain = 0; 
    end


    path = percentages(find(strcmp(elements, 'PathOutline')));
    if isempty(path)
       path = 0; 
    end
    
    percToTerrain4deg = path + (countsToTerrain4deg/numFrames);

    trees = closeTreePercentages; %1 - (closeTreePercentages + throughpercentages + path + hoops + terrain);
    
    
    totalPercentage = terrain + path + hoops + throughpercentages + closeTreePercentages;
    terrain = terrain + (1-totalPercentage); % Add the remaining percentages (which is the leftover trees) to the terrain. 
    totalPercentage = terrain + path + hoops + throughpercentages + closeTreePercentages;

  
end

function hoopFixation = findHoopFixationPercentage(elements, percentages)
    hoopFixation = 0;

    for i=1:length(elements)
       
        currString = elements(i);
        
        splitString = split(currString, ' ');
        
        if strcmp(splitString(1), 'RoundGate') || strcmp(splitString(1), 'RegularGate')
           
            hoopFixation = hoopFixation + percentages(i);
            
        end
        
        
        
    end




end

function treeIndices = findTreeGazeFrames(treeNames, gazeTargets, throughGatesIndices)
    
    treeIndices = zeros(1,length(gazeTargets));
    for n = treeNames
        
        for f =1:length(gazeTargets)
            
            if strcmp(gazeTargets(f), n)
                treeIndices(f) = 1;
            end
            
        end
        
    end


end

function closeTreeCounts = findTreeDistanceRelHoop(posData, hoopData, treeNames, block)
    closeTreeCounts = zeros(1, size(posData, 1));
    gazeTargets = posData.RE_Gaze_Target;
    
    hoopPos = [hoopData.('Position(x)'), hoopData.('Position(y)'), hoopData.('Position(z)')];
    
   
        
    dronePos = [posData.('Position(x)'), posData.('Position(y)'), posData.('Position(z)')];
    gazePos = [posData.('RE_Gaze_Pos(x)'), posData.('RE_Gaze_Pos(y)'), posData.('RE_Gaze_Pos(z)')];
    gatePassData = posData.('RE_First_Pass_Through_Gate');
    gatePassFrames = find(~cellfun(@isempty,gatePassData));
    gateNames = unique(gatePassData(gatePassFrames));
   
    
    %hoopNumbers = cell(gatePassData(gatePassFrames,1), gatePassFrames);
    passNextHoop = false;
    currHoop = 2;
    gateNames = [gateNames; gateNames];
    passHoopFrames = zeros(1, 84);
    ind = 1;
    prevFrameData = 'nothing';
%     for j=1:size(posData,1)
%         currPassData = gatePassData{j};
%         
%         
%         [currPassData, prevFrameData]
%         if ~isempty(currPassData) && ~strcmp(currPassData, prevFrameData)
%             passHoopFrames(ind) = j;
%             ind = ind + 1;
%         end
%         
%         prevFrameData = currPassData;
%         
%     end
    positionDataForDrone = [posData.('Position(x)'), posData.('Position(y)'), posData.('Position(z)'), posData.('Lap_Number')];
    passHoopFrames = findCurrentHoopToPass(positionDataForDrone, hoopPos', block);
    passHoopFrames = [passHoopFrames(1,1:end), passHoopFrames(2,1:end)];
    numberCloseTrees = 0;
    
    hoopPos = [hoopPos; hoopPos];
    if block==5
        hoopPos = flip(hoopPos);
    end
    
    for i=1:size(posData,1)
        currGazeTarget = gazeTargets(i);
        isTree = false;
        i
        for tree=treeNames
            
            if strcmp(currGazeTarget, tree)
                isTree = true;
                
            end      
            
        end
        
        %if currHoop>84
         %   currHoop = 1;
        %end
        
            passHoopFrames(currHoop);
        if currHoop<84
            if i<=passHoopFrames(currHoop)
                currHoopPosition = hoopPos(currHoop, :);
                currDronePosition = dronePos(i,:);
                hoopDistance = sqrt(sum(currHoopPosition-currDronePosition).^2);

                currGazePos = gazePos(i,:);
                gazeDistance = sqrt(sum(currGazePos-currDronePosition).^2);

                if isTree && (gazeDistance < hoopDistance)
                    closeTreeCounts(i) = 1;
                end

            else
                passHoopFrames(currHoop);
                currHoop = currHoop + 1
            end
        else
            if i<=passHoopFrames(currHoop)
                currHoopPosition = hoopPos(1, :);
                currDronePosition = dronePos(i,:);
                hoopDistance = sqrt(sum(currHoopPosition-currDronePosition).^2);

                currGazePos = gazePos(i,:);
                gazeDistance = sqrt(sum(currGazePos-currDronePosition).^2);

                if isTree && (gazeDistance < hoopDistance)
                    closeTreeCounts(i) = 1;
                end
            end
            
        end
        
    end
    
    closeTreeCounts = sum(closeTreeCounts);

end


function d = getObstacleData(name)

    if strcmp(name, 'obstacle_data.txt')
        d = readtable(name, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true, 'HeaderLines', 0);
    else
        d = readtable(name, 'delimiter', ',','ReadVariableNames', true, 'PreserveVariableNames', true, 'HeaderLines', 0);
    end
        

end

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
                i,j


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
        hoopList = maxHoops:-1:1;
        
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

function closeTreeCounts = findTreeDistanceAverageInterhoopDistance(posData, hoopData, treeNames, block)
    closeTreeCounts = zeros(1, size(posData, 1));
    gazeTargets = posData.Gaze_Target;
    
    hoopPos = [hoopData.('Position(x)'), hoopData.('Position(y)'), hoopData.('Position(z)')];
    
   
        
    dronePos = [posData.('Position(x)'), posData.('Position(y)'), posData.('Position(z)')];
    gazePos = [posData.('RE_Gaze_Pos(x)'), posData.('RE_Gaze_Pos(y)'), posData.('RE_Gaze_Pos(z)')];
%     gatePassData = posData.('RE_First_Pass_Through_Gate');
%     gatePassFrames = find(~cellfun(@isempty,gatePassData));
%     gateNames = unique(gatePassData(gatePassFrames));
   
    
    %hoopNumbers = cell(gatePassData(gatePassFrames,1), gatePassFrames);
    passNextHoop = false;
    currHoop = 2;
%     gateNames = [gateNames; gateNames];
    passHoopFrames = zeros(1, 84);
    ind = 1;
    prevFrameData = 'nothing';
%     for j=1:size(posData,1)
%         currPassData = gatePassData{j};
%         
%         
%         [currPassData, prevFrameData]
%         if ~isempty(currPassData) && ~strcmp(currPassData, prevFrameData)
%             passHoopFrames(ind) = j;
%             ind = ind + 1;
%         end
%         
%         prevFrameData = currPassData;
%         
%     end
    positionDataForDrone = [posData.('Position(x)'), posData.('Position(y)'), posData.('Position(z)'), posData.('Lap_Number')];
%     passHoopFrames = findCurrentHoopToPass(positionDataForDrone, hoopPos', block);
%     passHoopFrames = [passHoopFrames(1,1:end), passHoopFrames(2,1:end)];
    numberCloseTrees = 0;
    
    hoopPos = [hoopPos; hoopPos];
    if block==5
        hoopPos = flip(hoopPos);
    end
    
    for i=1:size(posData,1)
        currGazeTarget = gazeTargets(i);
        isTree = false;
        i
        for tree=treeNames
            
            if strcmp(currGazeTarget, tree)
                isTree = true;
                
            end      
            
        end
        
        %if currHoop>84
         %   currHoop = 1;
        %end
        
        currDronePosition = dronePos(i,:);
        hoopDistance = 17.2*2; %sqrt(sum(currHoopPosition-currDronePosition).^2);

        currGazePos = gazePos(i,:);
        gazeDistance = sqrt(sum(currGazePos-currDronePosition).^2)/5;

        if isTree && (gazeDistance < hoopDistance)
            closeTreeCounts(i) = 1;
        end
            
            
        
        
    end
    
    closeTreeCounts = sum(closeTreeCounts);

end

function theta = calculateXCorrAngle(c, u, v) % u = [x1, y1] v = [x2, y2]
    %theta = atan2d(u(:,1).*v(:,2)-v(:,1).*u(:,2), u(:,1).*u(:,2)+v(:,1).*v(:,2));
    theta = zeros(1,size(u,1));
    
    u = u - c;
    v = v - c;
    
    for i=1:size(u,1)
    
        %theta = atan2(norm(cross(u,v)),dot(u,v));
        %th = acos(dot(u(i,:), v(i,:)) / (norm(u(i,:)) * norm(v(i,:))));
        %CosTheta = max(min(dot(u,v)/(norm(u)*norm(v)),1),-1);
        %theta = real(acosd(CosTheta));
        %th = subspace(u(i,:),v(i,:));
        %th = acos(dot(u(i,:) / norm(u(i,:)), v(i,:) / norm(v(i,:))));
        %th = atan2d(u(i,1)*v(i,2)-v(i,1)*u(i,2), u(i,1)*u(i,2)+v(i,1)*v(i,2));
        %th = (th * 180.0) / pi;
        
        %ac = (u(i,:) -c(i,:))/norm(u(i,:)-c(i,:));  % Magnitude of vectors
        %av = (v1(i,:)-c(i,:))/norm(v1(i,:)-c(i,:));
        
        %dotProdUV = dot(u,v);
        
        
    
        lenU = sqrt(u(i,1)^2 + u(i,2)^2);
        lenV = sqrt(v(i,1)^2 + v(i,2)^2);
        
        dotProd = u(i,1)*v(i,1) + u(i,2)*v(i,2);
        
        denProd = lenU*lenV;
        
        cosTheta = dotProd/denProd;
        
        th = acos(cosTheta);
        %th = atan2(norm(det([ac; av])), dot(ac, av));
        x1 = u(1);
        x2 = v(1);
        y1 = u(2);
        y2 = v(2);
        a = atan2d(x1*y2-y1*x2,x1*x2+y1*y2);
        if dotProd < 0
            th = -th;
        end
        
        theta(1,i) = a; %* 180 / pi
        
        theta(isnan(theta))=0;
        
    end
end