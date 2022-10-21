function buildGazeDistanceRelativeToHoopTimeSeriesFigure()


    subjectDataSets = {'P_210930142529_100', 'P_211013154622_50', 'P_211015152112_10', 'P_210929172928_200_300', 'P_210928152127_40', 'P_220207122313_Nate'};
    % subjectDataSets = {'P_211013154622_50'};
    conditions = {'/PathAndHoops/', '/HoopOnly/'};
    %conditions = {'/PathOnly/'};
    hoopFolder = 'HoopFiles/';
    positionFolder = 'FinalPositions/';
   
    %hoopPositionData = getObstacleData('obstacle_data.txt');
    hoopPositionData = getObstacleData('gateOrientationNormalizedPointsDataset.txt');
    
    dfLogical = 0;
    figure(1);
    for sb = subjectDataSets
        sb
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
                hoopData = readtable(currHoopFile, 'delimiter', '\t' , 'ReadVariableNames', true, 'PreserveVariableNames', true);
                posFileSplit = split(currPositionFile, '_');
                block = str2double(posFileSplit(end-1));

               
                currentDF = runAdditionalAnalyses(sb{1}, cnd{1}, block, posData, hoopPositionData, hoopData);
                    
                
                %hold on;
                %plot(currentDF)
                %hold off;
            
            end
            
        end
        
        
    end




end

function dataTableOutput = runAdditionalAnalyses(subject, condition, block, positionFile, obstacleFile, GateFile)
    dataTableOutput = 0;
    %dataFileName = subjectPath;
    %droneFile = positionFile;
    imagePath = 'DroneExperimentData/P_210930142529_100/S001/Flight Data_10_GatedPath_Block_20/GaiaTest3/FPScene_CH_GP.mp4';
    %alldata = readtable('drone_positionsPathAndHoops.txt', 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true);
    alldata = positionFile;%readtable(strcat(dataFileName, droneFile), 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true);
    %alldata = alldata(600:end,:); % This chops the first few seconds are so that there is no drone movement
    numSecondsLagged = 15;
    %jsonData = readJSONfile(strcat(dataFileName, '000/info.player.json'));
    runAutoCorrelation = false;
    %systemStartTime = jsonData.start_time_system_s;
    
    plotGazeSpeed = false; % plot the gaze-speed angle
    runParsedGateDataAnalysis = false;
    dronePosX = alldata.('Position(x)');
    dronePosY = alldata.('Position(y)');
    dronePosZ = alldata.('Position(z)');
    
    %% I need to add functionality so that this also adds the path only condition to the dataset without throwing an error.
    
    
    t = alldata.Timestamp;
    
    droneOrientX =alldata.('Orientation(x)');
    droneOrientY = alldata.('Orientation(y)');
    droneOrientZ = alldata.('Orientation(z)');
    
    
    Lap_Number = alldata.Lap_Number;
    
    timeStamp = alldata.Timestamp;
    %gazePosX = alldata.('Gaze_Location(x)');
    %gazePosY = alldata.('Gaze_Location(y)');
    %gazePosZ = alldata.('Gaze_Location(z)');
    
    gazePosX = alldata.('RE_Gaze_Pos(x)');
    gazePosY = alldata.('RE_Gaze_Pos(y)');
    gazePosZ = alldata.('RE_Gaze_Pos(z)');
    
    %gazeVectorDistances = FixatedDistances(alldata)/5;
    
    %if runAutoCorrelation
        % Unsure whether this is an interesting analysis or anything but I
        % thought that it could be a description of gaze behavior. 
        %autocorr(gazeVectorDistances, 'NumLags',1200)
    %end
    
    headingModfier = 1;
    
    dDronePosX = calculateVelocity(dronePosX, timeStamp)*headingModfier;
    dDronePosY = calculateVelocity(dronePosY, timeStamp)*headingModfier;
    dDronePosZ = calculateVelocity(dronePosZ, timeStamp)*headingModfier;
    
    speedVector = [dronePosX + dDronePosX, dronePosY + dDronePosY, dronePosZ + dDronePosZ]';
    
    speedMag = [dDronePosX, dDronePosY, dDronePosZ]';
    
    
    controlLeftX = alldata.Left_X;
    controlLeftY = alldata.Left_Y;
    controlRightX = alldata.Right_X;
    controlRightY = alldata.Right_Y;
    
    controllerData = [controlLeftX, controlLeftY, controlRightX, controlRightY]';
    
    % Does this only work if the gate file is present? I want that to be
    % programmatic. 
    
    gateData = GateFile; %getGateData(strcat(dataFileName, 'gate_data.txt'));
    obstacleData = obstacleFile;%getObstacleData(strcat(dataFileName, 'obstacle_data.txt'));

    obstaclePosX = obstacleData.('Position(x)');
    obstaclePosY = obstacleData.('Position(y)');
    obstaclePosZ = obstacleData.('Position(z)');

    obstacleDirection = 0;%obstacleData.('Direction');
    %plot3(gazePosX, gazePosY, gazePosZ, 'bo')
    %xlabel('X')
    %ylabel('Y')
    %zlabel('Z')

    hoopPositions = parsedGateDataAnalysis(alldata, obstacleData);
    %parsedData = parseGateAndGazeData(gateData, alldata, obstacleData, systemStartTime);
    hoopToPassList = findCurrentHoopToPass([dronePosX, dronePosY, dronePosZ, Lap_Number], hoopPositions, block);

    dataTableOutput = findVisualAngleGazeAndHoop(subject, condition, block, hoopToPassList, [gazePosX, gazePosY, gazePosZ], [dronePosX, dronePosY, dronePosZ, Lap_Number, droneOrientX, droneOrientY, droneOrientZ], ...
        hoopPositions, speedVector, controllerData, obstacleDirection, speedMag, alldata, obstacleData);
    %runParsedGateDataAnalysis = true;
    
    
   

    
    
   

end


function dx = calculateDerivative(x)

    dx = zeros(length(x),1);
    
    for i=2:length(x)
       
        dx(i,1) = x(i) - x(i-1);
        
    end


end

function dx = calculateVelocity(x, t)

    dx = zeros(length(x),1);
    
    for i=2:length(x)
       
        dx(i,1) = (x(i) - x(i-1))/(t(i)-t(i-1));
        
    end


end

function mag = calculateMag(x, y)

    mag = sqrt((x.^2) + (y.^2));

end

function theta = calculateAngle(c, u, v) % u = [x1, y1] v = [x2, y2]
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



function d = getGateData(name)


    d = readtable(name, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true);

end

function d = getObstacleData(name)


    d = readtable(name, 'delimiter', ',','ReadVariableNames', true, 'PreserveVariableNames', true, 'HeaderLines', 0);

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


function hoopPositions = parsedGateDataAnalysis(df, gateData)
    %% write function that finds distance between hoop and drone and it's changing magnitude. \
    %  When it is shrinking they are moving towards it when it is decreasing they are moving away from it presumably to the next hoop
    hoopPositions = zeros(16, length(unique(gateData.ObjectName))+10);
    L = length(unique(gateData.ObjectName));
    
    for i=1:L
        i;
        currHoopName = gateData.ObjectName{i};
        hoopSplit = split(currHoopName, ' ');
        hoopNumber = str2num(hoopSplit{2})+1;
        
        %hoopPositionIndex = find(strcmp(gateData.ObjectName, hoopName));
        
        x = gateData.('Position(x)');
        y = gateData.('Position(y)');
        z = gateData.('Position(z)');
        
        orientx = gateData.('Orientation(x)');
        orienty = gateData.('Orientation(y)');
        orientz = gateData.('Orientation(z)');
        
        dir = gateData.Direction;
        
        if strcmp(dir{i},'R')
            direction = 0;
        elseif strcmp(dir{i}, 'L')
            direction = 1;
        else
            direction = 2;
        end
        
        rp1x = gateData.RotatedPoint1x;
        rp1y = gateData.RotatedPoint1y;
        rp2x = gateData.RotatedPoint2x;
        rp2y = gateData.RotatedPoint2y;
         p1x = gateData.Point1x;
         p1y = gateData.Point1y;
         p2x = gateData.Point2x;
         p2y = gateData.Point2y;
        
        hoopPositions(1,hoopNumber) = x(i);
        hoopPositions(2,hoopNumber) = y(i);
        hoopPositions(3,hoopNumber) = z(i);
        hoopPositions(4,hoopNumber) = hoopNumber;
        hoopPositions(5,hoopNumber) = orientx(i);
        hoopPositions(6,hoopNumber) = orienty(i);
        hoopPositions(7,hoopNumber) = orientz(i);
        hoopPositions(8,hoopNumber) = p1x(i);
        hoopPositions(9,hoopNumber) = p1y(i);
        hoopPositions(10,hoopNumber) = p2x(i);
        hoopPositions(11,hoopNumber) = p2y(i);
        hoopPositions(12,hoopNumber) = direction;
        hoopPositions(13,hoopNumber) = rp1x(i);
        hoopPositions(14,hoopNumber) = rp1y(i);
        hoopPositions(15,hoopNumber) = rp2x(i);
        hoopPositions(16,hoopNumber) = rp2y(i);
        
        %plot([p1x(i) p2x(i)], [p1y(i) p2y(i)], 'ko')
        %hold on;
        %plot([rp1x(i) rp2x(i)],[rp1y(i) rp2y(i)],'ro')
        %hold off;
    end
    hoopPositions = hoopPositions(:,any(hoopPositions,1));
    
    %for i=1:40
        
     %   plot(hoopPositions(1,i), hoopPositions(3,i), 'bo')
       % xlim([min(hoopPositions(1,:)), max(hoopPositions(1,:))])
       % ylim([min(hoopPositions(3,:)), max(hoopPositions(3,:))])
       % drawnow;
        
        %pause(2)
    %end
end




function distanceDifferenceVectorGazeAndHoop = findVisualAngleGazeAndHoop(subject, condition, block, hoopFrames, ...
    gazePosition, positionData, hoopPositions, speedVector, controllerData,...
    obstacleDirection, speedMag, gazeAndPositionData, obstacleData)
    
    numHoops = size(obstacleData,1);
    numLaps = 2;
    positionData = positionData';
    gazePosition = gazePosition';
    hoopFrames = [hoopFrames(1,:), hoopFrames(2,:)];
    angleType = 3;
    plotAngles = false;
    plotNextTheGazeAndHeadingForNextHoop = false;
    determineAverageHoopDistance = false;
    plotAll = false;
    Subject = {subject}; 
    Condition = {condition(2:end-1)};
    plotApproachAngle = false;
    
    
    averageFlipped = zeros(1, 120);
    numFlipped = 1;
    
    prevthrustMat = [];
    prevheadingGazeMat = [];
    prevVDmat = [];
    prevHeadingHoopMat = [];
    
    prevDataFrameLogical = 0;
    
    if determineAverageHoopDistance
        averageHoopDistance = findAverageDistanceBetweenHoops(hoopPositions);
    end
    
    hoopPositions = [hoopPositions, hoopPositions];
    obstacleDirection = [obstacleDirection, obstacleDirection];
    
     if ~strcmp(condition, '/PathOnly/')
            for i=1:numHoops*2

                if i==1 
                    firstFrame = 1;
                else
                    firstFrame = hoopFrames(i-1);
                end

                if i<=numHoops
                    lap = 0;
                elseif i>numHoops
                    lap = 1;
                end

                hoopNum = i;

                if block==5
                    hoopNum = (numHoops*2)-hoopNum;
                end

                lastFrame = hoopFrames(i);


                currHoopDronePositionX = positionData(1,firstFrame:lastFrame);
                currHoopDronePositionY = positionData(2,firstFrame:lastFrame);
                currHoopDronePositionZ = positionData(3,firstFrame:lastFrame);

                currHoopDroneOrientX = positionData(5,firstFrame:lastFrame);
                currHoopDroneOrientY = positionData(6,firstFrame:lastFrame);
                currHoopDroneOrientZ = positionData(7,firstFrame:lastFrame);






                droneOrientXatHoop = currHoopDroneOrientX(end);
                droneOrientYatHoop = currHoopDroneOrientY(end);
                droneOrientZatHoop = currHoopDroneOrientZ(end);

                currHoopPositionX = hoopPositions(1, i);
                currHoopPositionY = hoopPositions(2, i);
                currHoopPositionZ = hoopPositions(3, i);

                currHoopOrientX = hoopPositions(5, i);
                currHoopOrientY = hoopPositions(6, i);
                currHoopOrientZ = hoopPositions(7, i);

                currHoopP1x = hoopPositions(8, i);
                currHoopP1y = hoopPositions(9, i);
                currHoopP2x = hoopPositions(10, i);
                currHoopP2y = hoopPositions(11, i);

                currHooprP1x = hoopPositions(13, i);
                currHooprP1y = hoopPositions(14, i);
                currHooprP2x = hoopPositions(15, i);
                currHooprP2y = hoopPositions(16, i);

                Direction = hoopPositions(12,i);

                if i<numHoops*2
                    nextHoopPositionX = hoopPositions(1, i+1);
                    nextHoopPositionY = hoopPositions(2, i+1);
                    nextHoopPositionZ = hoopPositions(3, i+1);
                    nextHooprP1x = hoopPositions(13, i+1);
                    nextHooprP1y = hoopPositions(14, i+1);
                    nextHooprP2x = hoopPositions(15, i+1);
                    nextHooprP2y = hoopPositions(16, i+1);
                    nextHoopP1x = hoopPositions(8, i+1);
                    nextHoopP1y = hoopPositions(9, i+1);
                    nextHoopP2x = hoopPositions(10, i+1);
                    nextHoopP2y = hoopPositions(11, i+1);
                else
                    nextHoopPositionX = hoopPositions(1, 1);
                    nextHoopPositionY = hoopPositions(2, 1);
                    nextHoopPositionZ = hoopPositions(3, 1);
                    nextHooprP1x = hoopPositions(13, 1);
                    nextHooprP1y = hoopPositions(14, 1);
                    nextHooprP2x = hoopPositions(15, 1);
                    nextHooprP2y = hoopPositions(16, 1);
                    nextHoopP1x = hoopPositions(8, 1);
                    nextHoopP1y = hoopPositions(9, 1);
                    nextHoopP2x = hoopPositions(10, 1);
                    nextHoopP2y = hoopPositions(11, 1);
                end

                if i<numHoops*2
                    nextHoopOrientX = hoopPositions(5, i+1);
                    nextHoopOrientY = hoopPositions(6, i+1);
                    nextHoopOrientZ = hoopPositions(7, i+1);
                else
                    nextHoopOrientX = hoopPositions(5, 1);
                    nextHoopOrientY = hoopPositions(6, 1);
                    nextHoopOrientZ = hoopPositions(7, 1);
                end

                currHoopGazePositionX = gazePosition(1, firstFrame:lastFrame);
                currHoopGazePositionY = gazePosition(2, firstFrame:lastFrame);
                currHoopGazePositionZ = gazePosition(3, firstFrame:lastFrame);

                currHoopSpeedX = speedVector(1, firstFrame:lastFrame);
                currHoopSpeedY = speedVector(2, firstFrame:lastFrame);
                currHoopSpeedZ = speedVector(3, firstFrame:lastFrame);

                vx = speedMag(1, firstFrame:lastFrame);
                vy = speedMag(2, firstFrame:lastFrame);
                vz = speedMag(3, firstFrame:lastFrame);

                leftControlX = controllerData(1, firstFrame:lastFrame)+eps;
                leftControlY = controllerData(2, firstFrame:lastFrame)+eps;
                rightControlX = controllerData(3, firstFrame:lastFrame)+eps;
                rightControlY = -controllerData(4, firstFrame:lastFrame)+eps;% 50 is about the max speed 

                currHoopDronePosition = [currHoopDronePositionX; currHoopDronePositionY; currHoopDronePositionZ];
                currHoopPosition = [currHoopPositionX, currHoopPositionY, currHoopPositionZ];
                currHoopGazePosition = [currHoopGazePositionX; currHoopGazePositionY; currHoopGazePositionZ];
                currHoopSpeed = [currHoopSpeedX; currHoopSpeedY; currHoopSpeedZ];
                % Note that this is the horizontal thrust. For the vertical I need
                % to account for the left controller Y axis. 
                currHoopThrustVector = [currHoopDronePositionX+rightControlX*10; currHoopDronePositionZ+rightControlY*10];

                distanceDifferenceVectorGazeAndHoop = differenceBetweenHoopAndGazeDistances(currHoopDronePosition-currHoopGazePosition, currHoopDronePosition-currHoopPosition'.*ones(size(currHoopDronePosition)));
                flippedDistance = flip(distanceDifferenceVectorGazeAndHoop);
                if length(flippedDistance) >=120
                    %hold on;
                    %plot(flippedDistance(1:60))
                    %hold off;
                    averageFlipped = averageFlipped + flippedDistance(1:120);
                    numFlipped = numFlipped + 1;
                end


            end

    

        %prevthrustMat = prevthrustMat';
        %prevheadingGazeMat = prevheadingGazeMat';
        %prevVDmat = prevVDmat';
        %prevHeadingHoopMat = prevHeadingHoopMat';

        %angleTable = table(prevthrustMat, prevheadingGazeMat, prevVDmat, prevHeadingHoopMat);
        %angleTable = angleTable(1:size(positionData,2), :);
        %writetable(angleTable, 'angleDataForSubject.txt');

     end
      averageFlipped =averageFlipped/numFlipped;
     hold on;
     plot(averageFlipped, 'LineWidth', 3)
     hold off;
end


function distance = differenceBetweenHoopAndGazeDistances(gazeData, hoopPosition)
    %% Must make sure that the input to this function have the drone position removed or taken into account. 
    magGazeVector = sqrt(sum(gazeData.^2))/5;
    magHoopVector = sqrt(sum(hoopPosition.^2))/5;
    
    distance = magGazeVector - magHoopVector;

end







