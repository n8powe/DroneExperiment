function dataTableOutput = runAnalyses(subject, condition, block, positionFile, obstacleFile, GateFile, createTimeseriesData)
    %% This is the main function that creates the post processed dataset. 


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
    
  
    
    
    t = alldata.Timestamp;
    
    droneOrientX =alldata.('Orientation(x)');
    droneOrientY = alldata.('Orientation(y)');
    droneOrientZ = alldata.('Orientation(z)');
    
    
    Lap_Number = alldata.Lap_Number;
    
    timeStamp = alldata.Timestamp/1000;
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

    hoopPositions = parsedGateDataAnalysis(alldata, obstacleData, block);
    %parsedData = parseGateAndGazeData(gateData, alldata, obstacleData, systemStartTime);
    hoopToPassList = findCurrentHoopToPass([dronePosX, dronePosY, dronePosZ, Lap_Number], hoopPositions, block);
    
    if block==5
        hoopToPassList = flip(hoopToPassList,2);
    end

    dataTableOutput = findVisualAngleGazeAndHoop(subject, condition, block, hoopToPassList, [gazePosX, gazePosY, gazePosZ], [dronePosX, dronePosY, dronePosZ, Lap_Number, droneOrientX, droneOrientY, droneOrientZ], ...
        hoopPositions, speedVector, controllerData, obstacleDirection, speedMag, alldata, obstacleData, createTimeseriesData, timeStamp);
    %runParsedGateDataAnalysis = true;
    

end



function dx = calculateVelocity(x, t)

    dx = zeros(length(x),1);
    
    for i=2:length(x)
       
        dx(i,1) = (x(i) - x(i-1))/(t(i)-t(i-1));
        
    end


end

function dist = findDistance(x, y)

    dist = zeros(length(x), 1);
    
    for i=1:length(x)
       
        v1 = x(i,:);
        v2 = y(i,:);
        
        v = [v1; v2];
        
        dist(i) = pdist(v);
        
    end


end

function mag = calculateMag(x, y)

    mag = sqrt((x.^2) + (y.^2));

end


function a = calculate3DAngle(x, y)

    a = zeros(length(x(:,1)), 1);
    
    for i=1:length(a)
       P1 = x(i,:);
       P2 = y(i,:);
       a(i) =  atan2d(norm(cross(P1,P2)),dot(P1,P2));
        
    end

end


function d = getGateData(name)


    d = readtable(name, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true);

end

function d = getObstacleData(name)


    d = readtable(name, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true, 'HeaderLines', 0);

end

function df =  parseGateAndGazeData(gateData, gazeData, obstacleData, systemStartTime)
    df = 0;
    % This function will parse the time of passage and the gaze data to
    % find the cross-correlation of gaze and gate position (visual angle or changing visual angle) up until that point. 

    gateList = unique(gateData.Gate);
    
    gazeData.Gate = zeros(1,size(gazeData,1))';
    gazeData.GatePosX = zeros(1,size(gazeData,1))';
    gazeData.GatePosY = zeros(1,size(gazeData,1))';
    gazeData.GatePosZ = zeros(1,size(gazeData,1))';
    
    for i=1:length(gateList)-1
        currGatePassedTimestamp = gateData.Passage_Timestamp(i);
        nextGatePassedTimestamp = gateData.Passage_Timestamp(i+1);
        
        if i-1==0
            hoopName = strcat('RegularGate 0');
        else
            hoopName = strcat('RoundGate ', num2str(i-1));
        end
        hoopPositionIndex = find(strcmp(obstacleData.ObjectName, hoopName));
        
        
        gazeData(gazeData.Timestamp>currGatePassedTimestamp && gazeData.Timestamp<nextGatePassedTimestamp, :).Gate = i-1;
        gazeData.GatePosX(gazeData.Timestamp>currGatePassedTimestamp && gazeData.Timestamp<nextGatePassedTimestamp, :) =  obstacleData.Position_x_(hoopPositionIndex);
        gazeData.GatePosY(gazeData.Timestamp>currGatePassedTimestamp && gazeData.Timestamp<nextGatePassedTimestamp, :) =  obstacleData.Position_y_(hoopPositionIndex);
        gazeData.GatePosZ(gazeData.Timestamp>currGatePassedTimestamp && gazeData.Timestamp<nextGatePassedTimestamp, :) =  obstacleData.Position_z_(hoopPositionIndex);
        
    end
    
    df = gazeData;

end






function dTable =findVisualAngleGazeAndHoop(subject, condition, block, hoopFrames, ...
    gazePosition, positionData, hoopPositions, speedVector, controllerData,...
    obstacleDirection, speedMag, gazeAndPositionData, obstacleData, createTimeseriesData, timeStamp)
    %% This is a really big function that does pretty much all of the work in this analysis. It creates the dataset for cross-correlation and time-series analyses. 

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
    %if plotApproachAngle
    %    figure(1);
    %end
    
    prevHoopVisualAngle = NaN;
    prevSegmentCurvature = NaN;
    
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
    
    if ~strcmp(condition, '/PathOnly/') % Path only is a special condition for this analysis, see the else statement that follows below. 
        for i=1:numHoops*2
            ClosestPoint = NaN;
            ClosestPointNext = NaN;
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

            %if block==5
             %   hoopNum = (numHoops*2)-hoopNum;
            %end
            
            if hoopNum < numHoops*2
                lastFrame = hoopFrames(i)-1;
                
            else
                lastFrame = hoopFrames(i)-1;
                
            end
            
            %firstFrame = hoopFrames(i) - 60;

            %if length(firstFrame:lastFrame)<121
              %  'WHY YOU SO SHORT'
            %end
            

            
            length(firstFrame:lastFrame);
            
            if lastFrame > size(positionData,2)
                lastFrame = size(positionData,2);
            end
            
            currHoopDronePositionX = positionData(1,firstFrame:lastFrame);
            currHoopDronePositionY = positionData(2,firstFrame:lastFrame);
            currHoopDronePositionZ = positionData(3,firstFrame:lastFrame);
            
            
            numberOfFrames = length(firstFrame:lastFrame);
            if numberOfFrames>60
                numberOfLags = 30;
            else
                numberOfLags = numberOfFrames-1;
            end
            
            firstFrame
            lastFrame
            
            currHoopDroneOrientX = positionData(5,firstFrame:lastFrame);
            currHoopDroneOrientY = positionData(6,firstFrame:lastFrame);
            currHoopDroneOrientZ = positionData(7,firstFrame:lastFrame);

            
            dronePositionNormalPoints = findNormalPoints(currHoopDronePositionX, currHoopDronePositionZ, currHoopDroneOrientY);
            
            droneNorm1x = dronePositionNormalPoints(1,:);
            droneNorm1y = dronePositionNormalPoints(2,:);
            droneNorm2x = dronePositionNormalPoints(3,:);
            droneNorm2y = dronePositionNormalPoints(4,:);
            
            dronerNorm1x = dronePositionNormalPoints(5,:);
            dronerNorm1y = dronePositionNormalPoints(6,:);
            dronerNorm2x = dronePositionNormalPoints(7,:);
            dronerNorm2y = dronePositionNormalPoints(8,:);
            
            
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
            currHoopThrustVector = [currHoopDronePositionX+rightControlX*50; currHoopDronePositionZ+rightControlY*50];
            
            pathCurvature = findStraightPathSegmentsForPositionData(currHoopDronePosition);
            
            collisionData = gazeAndPositionData.('Collision_Target');
            currCollisionData = collisionData(firstFrame:lastFrame);
            numberCollisions = findNumberCollisions(currCollisionData);
            
            %throughHoopData = gazeAndPositionData.('Gaze_Through_Gate');
            throughHoopData = gazeAndPositionData.('RE_Gaze_Thru_Gate');
            currthroughHoopData = throughHoopData(firstFrame:lastFrame);
            timeThroughHoop = FindTimeThroughHoop(currthroughHoopData);
            
            gazeTargettemp = gazeAndPositionData.('RE_Gaze_Target');
            gazeTarget = gazeTargettemp(firstFrame:lastFrame);
            
            headingTargettemp = gazeAndPositionData.('RE_Heading_Target');
            headingTarget = headingTargettemp(firstFrame:lastFrame);
            
            currHoopThrustVector = rotateThrustVectorAroundDrone(currHoopThrustVector, currHoopDronePosition, currHoopDroneOrientY);
            
            currHoopThrustWithPositionRemoved = currHoopThrustVector - currHoopDronePosition([1,3], :);

            %distanceDifferenceVectorGazeAndHoop = differenceBetweenHoopAndGazeDistances(currHoopDronePosition-currHoopGazePosition, currHoopDronePosition-currHoopPosition'.*ones(size(currHoopDronePosition)));

            distanceToHoop = sqrt(sum((currHoopDronePosition' - currHoopPosition.*ones(size(currHoopDronePosition'))).^2, 2))/5;
            
            currNumFrames = length(firstFrame:lastFrame);
            horizontalVisualAngleGazeAndHoop = zeros(1,currNumFrames)*NaN;
            horizontalVisualAngleSpeedVector = zeros(1,currNumFrames)*NaN;
            horizontalGazeAngleSpeedVector = zeros(1,currNumFrames)*NaN;
            horizontalGazeAngleThrustVector = zeros(1,currNumFrames)*NaN;
            horizontalSpeedAngleThrustVector = zeros(1,currNumFrames)*NaN;
            horizontalHoopThrustAngleVector = zeros(1,currNumFrames)*NaN;
            horizontalCameraSpeedVector = zeros(1,currNumFrames)*NaN;
            horizontalCameraHoopVector= zeros(1,currNumFrames)*NaN;
            horizontalNextHoopDroneOffsetVector= zeros(1,currNumFrames)*NaN;


            horizontalHoopNormalHeadingVector = zeros(1,currNumFrames)*NaN;

            if i <numHoops*2
                nextHoopPositionX = hoopPositions(1, i+1);
                nextHoopPositionY = hoopPositions(2, i+1);
                nextHoopPositionZ = hoopPositions(3, i+1);
                nextHoopPosition = [nextHoopPositionX, nextHoopPositionY, nextHoopPositionZ];
            end
            
            if i==numHoops*2
                nextHoopPositionX = hoopPositions(1, 1);
                nextHoopPositionY = hoopPositions(2, 1);
                nextHoopPositionZ = hoopPositions(3, 1);
                nextHoopPosition = [nextHoopPositionX, nextHoopPositionY, nextHoopPositionZ];
            end
            
            distanceToHoopNp1_scaled = (sqrt(sum((currHoopDronePositionX - nextHoopPositionX).^2 + (currHoopDronePositionY - nextHoopPositionY).^2 + (currHoopDronePositionZ - nextHoopPositionZ).^2, 1)))'/5;
            distanceToHoopNp1_unitymeter = (sqrt(sum((currHoopDronePositionX - nextHoopPositionX).^2 + (currHoopDronePositionY - nextHoopPositionY).^2 + (currHoopDronePositionZ - nextHoopPositionZ).^2, 1)))';
          
            lateralDistanceToHoopNp1_scaled = (sqrt(sum((currHoopDronePositionX - nextHoopPositionX).^2 + (currHoopDronePositionZ - nextHoopPositionZ).^2, 1)))'/5;
            lateralDistanceToHoopNp1_unitymeter = (sqrt(sum((currHoopDronePositionX - nextHoopPositionX).^2 + (currHoopDronePositionZ - nextHoopPositionZ).^2, 1)))';
            
            
            horizontalNextHoopThrustAngleVector = zeros(1,currNumFrames)*NaN;
            horizontalVisualAngleGazeAndNextHoop = zeros(1,currNumFrames)*NaN;
            horizontalVisualAngleSpeedVectorNext = zeros(1,currNumFrames)*NaN;
            horizontalDroneAndHoops = zeros(1,currNumFrames)*NaN;
            horizontalCameraGazeVector = zeros(1,currNumFrames)*NaN;
            horizontalNextHoopNormalHeadingVector = zeros(1,currNumFrames)*NaN;

            lapPositionData = gazeAndPositionData(gazeAndPositionData.Lap_Number==lap, :);
            if lap > 0
               hoopNumLap =  hoopNum - numHoops ;
            else 
                hoopNumLap = hoopNum;
            end
%             if block==5
%                %lapPositionData = flip(lapPositionData, 1);       
% 
%                 if lap > 0
%                    hoopNumLap =  numHoops + i;
%                 else 
%                     hoopNumLap = numHoops - i + 1;
%                 end
%                 
%             end
            
            if ~createTimeseriesData
                [distanceToHoopFirstGaze, timeBeforeReachingHoopFirstGaze, LAF, gazeDistanceToHoop, ...
                    timeAfterPreviousHoopFirstGazeNextHoop, timeBetweenHoops, LAFthroughHoop] = ...
                    buildGazeBehaviorData(lapPositionData, obstacleData, hoopNumLap, block, hoopFrames);
            end

            if plotApproachAngle
                v1 = VideoWriter('approachAngle', 'MPEG-4');
                open(v1);
                fig1 = figure(1);
            end

            
            for f=1:currNumFrames
                horizontalVisualAngleGazeAndHoop(1,f) = calculateXCorrAngle(currHoopDronePosition([1,angleType],f)', ...
                    currHoopPosition([1,angleType]), currHoopGazePosition([1,angleType],f)'); % Angle between gaze and hoop


                horizontalVisualAngleSpeedVector(1,f) = calculateXCorrAngle(currHoopDronePosition([1,angleType],f)', ...  
                    currHoopPosition([1,angleType]), currHoopSpeed([1,angleType],f)');  % Angle between hoop and heading
                
                %horizontalVisualAngleSpeedVector(1,f) = calculateXCorrAngle(currHoopDronePosition([1,angleType],f)', ...  
                  %  currHoopPosition([1,angleType]), currHoopSpeed([1,angleType],f)');  % Angle between hoop and heading

                horizontalGazeAngleSpeedVector(1,f) = calculateXCorrAngle(currHoopDronePosition([1,angleType],f)', ...
                    currHoopGazePosition([1,angleType],f)', currHoopSpeed([1,angleType],f)'); % Angle between heading and gaze

                horizontalGazeAngleThrustVector(1,f) = calculateXCorrAngle(currHoopDronePosition([1,angleType],f)', ...
                    currHoopThrustVector(:,f)', currHoopGazePosition([1,angleType],f)'); % Angle between thrust and gaze

                horizontalSpeedAngleThrustVector(1,f) = calculateXCorrAngle(currHoopDronePosition([1,angleType],f)', ...
                    currHoopThrustVector(:,f)', currHoopSpeed([1,angleType],f)'); % Angle between thrust and heading 
                
%                 horizontalHoopThrustAngleVector(1,f) = calculateXCorrAngle(currHoopDronePosition([1,angleType],f)', ...
%                     currHoopThrustVector(:,f)', currHoopPosition([1,angleType])); % Angle between thrust and hoop 
                
                horizontalNextHoopThrustAngleVector(1,f) = calculateXCorrAngle(currHoopDronePosition([1,angleType],f)', ...
                    currHoopThrustVector(:,f)', nextHoopPosition([1,angleType])); % Angle between thrust and next hoop 
                
                diffBetweenHoopNNP1AndThrust = abs(horizontalHoopThrustAngleVector) - abs(horizontalNextHoopThrustAngleVector);
                
                horizontalVisualAngleGazeAndNextHoop(1,f) = calculateXCorrAngle(currHoopDronePosition([1,angleType],f)', ...
                    nextHoopPosition([1,angleType]), currHoopGazePosition([1,angleType],f)'); % Angle between gaze and hoop
                
                horizontalCameraSpeedVector(1,f) = calculateXCorrAngle([droneNorm2x(f) droneNorm2y(f)], ...
                     [droneNorm1x(f) droneNorm1y(f)], [droneNorm2x(f) droneNorm2y(f)] + [vx(f) vz(f)]); % Angle between camera and heading 

                horizontalCameraGazeVector(1,f) = calculateXCorrAngle([droneNorm2x(f) droneNorm2y(f)], ...
                     [droneNorm1x(f) droneNorm1y(f)], [droneNorm2x(f) droneNorm2y(f)] + currHoopGazePosition([1,angleType],f)'); % Angle between gaze and camera 
                
                horizontalVisualAngleSpeedVectorNext(1,f) = calculateXCorrAngle(currHoopDronePosition([1,angleType],f)', ...  
                   nextHoopPosition([1,angleType]), currHoopSpeed([1,angleType],f)');  % Angle between heading and next hoop
               
                
                horizontalDroneAndHoops(1,f) = calculateXCorrAngle(currHoopDronePosition([1,angleType],f)', ...  
                    nextHoopPosition([1,angleType]), currHoopPosition([1,angleType]));  % Angle between drone and hoops

                %horizontalHoopNormalHeadingVector(1,f) = calculateAngle([currHoopP1x currHoopP1y], ...
                  %  [currHoopP2x currHoopP2y], [currHoopP1x currHoopP1y]+[vx(f) vz(f)]); 

                 magNextHoopToP1 =  sqrt((currHoopDronePositionX(1)-currHooprP1x)^2 + (currHoopDronePositionZ(1)-currHooprP1y)^2);
                 magNextHoopToP2 =  sqrt((currHoopDronePositionX(1)-currHooprP2x)^2 + (currHoopDronePositionZ(1)-currHooprP2y)^2);

                if f==1 && magNextHoopToP1 < magNextHoopToP2
                    ClosestPoint=1;
                elseif f==1 && magNextHoopToP1 > magNextHoopToP2
                    ClosestPoint=2;
                end
                
                droneNormVector = [droneNorm1x(f)-droneNorm2x(f), droneNorm1y(f)-droneNorm2y(f)];
                
%                 figure(1293);
%                 pbaspect([1 1 1]);
%                 subplot(1,2,1)
%                 plot([droneNorm1x(f), droneNorm2x(f)], [droneNorm1y(f), droneNorm2y(f)], 'ro')
%                 hold on
%                 plot([dronerNorm1x(f), dronerNorm2x(f)], [dronerNorm1y(f), dronerNorm2y(f)], 'bo')
%                 hold off;
%                 subplot(1,2,2)
%                 plot(currHoopDroneOrientY)
%                 drawnow;
                
                if ClosestPoint==1
                    horizontalHoopNormalHeadingVector(1,f) = calculateXCorrAngle([currHooprP1x currHooprP1y], ...
                        [currHooprP1x currHooprP1y]+[vx(f) vz(f)], [currHooprP2x currHooprP2y]); 
                    
                  
                %horizontalCameraHoopVector(1,f) = calculateXCorrAngle([droneNorm2x(f) droneNorm2y(f)], ...
                  %   [droneNorm1x(f) droneNorm1y(f)], [droneNorm2x(f) droneNorm2y(f)] + [vx(f) vz(f)]); % Angle between camera and heading 
                  

                   horizontalNextHoopDroneOffsetVector(1,f) = -calculateXCorrAngle([nextHooprP2x nextHooprP2y], ...
                        currHoopDronePosition([1,angleType],f)', [nextHooprP1x nextHooprP1y]); 
                    
                    horizontalCameraHoopVector(1,f) = calculateXCorrAngle([currHooprP1x currHooprP1y], ...
                        [currHooprP1x currHooprP1y]+droneNormVector, [currHooprP2x currHooprP2y]); 
                    
                    horizontalHoopThrustAngleVector(1,f) = calculateXCorrAngle([currHooprP1x currHooprP1y], ...
                        [currHooprP1x currHooprP1y]+currHoopThrustWithPositionRemoved(:,f)',  [currHooprP2x currHooprP2y]); % Angle between thrust and hoop 
                    
                else
                    horizontalHoopNormalHeadingVector(1,f) = calculateXCorrAngle([currHooprP2x currHooprP2y], ...
                       [currHooprP2x currHooprP2y]+[vx(f) vz(f)],  [currHooprP1x currHooprP1y]); 
                   
                   
                    horizontalNextHoopDroneOffsetVector(1,f) = -calculateXCorrAngle([nextHooprP1x nextHooprP1y], ...
                       currHoopDronePosition([1,angleType],f)',  [nextHooprP2x nextHooprP2y]); 
                   
                    horizontalHoopThrustAngleVector(1,f) = calculateXCorrAngle([currHooprP2x currHooprP2y], ...
                        [currHooprP2x currHooprP2y]+currHoopThrustWithPositionRemoved(:,f)', [currHooprP1x currHooprP1y]); % Angle between thrust and  hoop 
                  
                    horizontalCameraHoopVector(1,f) = calculateXCorrAngle([currHooprP2x currHooprP2y], ...
                        [currHooprP2x currHooprP2y]+droneNormVector, [currHooprP1x currHooprP1y]); 
                end
                
                
                 magHoopToNextP1 =  sqrt((currHoopDronePositionX(end)-nextHooprP1x)^2 + (currHoopDronePosition(end)-nextHooprP1y)^2);
                 magHoopToNextP2 =  sqrt((currHoopDronePositionX(end)-nextHooprP2x)^2 + (currHoopDronePositionZ(end)-nextHooprP2y)^2);

                if f==1 && magHoopToNextP1 < magHoopToNextP2
                    ClosestPointNext=1;
                elseif f==1 && magHoopToNextP1 > magHoopToNextP2
                    ClosestPointNext=2;
                end
                
                if ClosestPointNext==1
                    horizontalNextHoopNormalHeadingVector(1,f) = calculateXCorrAngle([nextHooprP1x nextHooprP1y], ...
                        [nextHooprP1x nextHooprP1y]+[vx(f) vz(f)], [nextHooprP2x nextHooprP2y]); 
                elseif ClosestPointNext==2
                   horizontalNextHoopNormalHeadingVector(1,f) = calculateXCorrAngle([nextHooprP2x nextHooprP2y], ...
                       [nextHooprP2x nextHooprP2y]+[vx(f) vz(f)],  [nextHooprP1x nextHooprP1y]);                 
                end

                
                
                if plotApproachAngle

%                     subplot(1,3,1)
% 
%                     plot([0 rightControlX(f)], [0 rightControlY(f)], 'k-')
%                     hold on;
%                     plot(rightControlX(f), rightControlY(f), 'ko', 'MarkerSize', 10)
%                     hold off;
%                     hold on;
%                     xline(0, 'k--')
%                     hold off;
%                     hold on;
%                     yline(0, 'k--')
%                     hold off;
% 
%                     ylim([-1,1])
%                     xlim([-1,1])
                    if hoopNum>0
                        figure(1);
                    
                        subplot(1,3,1)

                        plot([currHoopP2x currHoopP1x], [currHoopP2y currHoopP1y], 'ko')
                        hold on;
                        plot([currHooprP2x currHooprP1x], [currHooprP2y currHooprP1y], 'ro')
                        hold off;

                        hold on;
                        plot(nextHoopPositionX, nextHoopPositionZ, 'bo')
                        hold off;

                        hold on;
                        plot([nextHooprP1x nextHooprP2x], [nextHooprP1y nextHooprP2y], 'ro')
                        hold off;

                        hold on
                        plot([nextHoopP1x nextHoopP2x], [nextHoopP1y nextHoopP2y], 'ko')
                        hold off;

                        hold on;
                        plot(currHoopDronePosition(1, 1:f), currHoopDronePosition(3, 1:f), 'LineWidth',2)
                        hold off;

                        hold on;
                        plot([currHoopDronePosition(1, f) currHoopThrustVector(1,f)], [currHoopDronePosition(3, f) currHoopThrustVector(2,f)], 'm')
                        hold off


                        hold on;
                        plot([currHoopDronePosition(1, f) currHoopGazePosition(1,f)], [currHoopDronePosition(3, f) currHoopGazePosition(3,f)], 'g')
                        hold off;


                        hold on;
                        plot( currHoopPosition(1),currHoopPosition(3), 'bo');
                        hold off;


                        hold on;
                        plot([droneNorm1x(f) ],[droneNorm1y(f) ], 'b+')
                        hold off;
                        hold on;
                        plot([droneNorm2x(f)], [droneNorm2y(f)], 'g+')
                        hold off;

                        hold on;
                        plot([dronerNorm1x(f) dronerNorm2x(f)],[dronerNorm1y(f) dronerNorm2y(f)],'r+')
                        hold off;



                        hold on;
                        if ClosestPoint==1
                            plot([currHooprP1x currHooprP1x+vx(f)*200],[currHooprP1y currHooprP1y+vz(f)*200], 'LineWidth',2)
                        else
                            plot([currHooprP2x currHooprP2x+vx(f)*200],[currHooprP2y currHooprP2y+vz(f)*200], 'LineWidth',2)
                        end
                        hold off;

                        hold on;
                        if ClosestPoint==1
                            plot([currHooprP1x currHooprP1x+currHoopThrustWithPositionRemoved(1,f)],[currHooprP1y currHooprP1y+currHoopThrustWithPositionRemoved(2,f)], 'g', 'LineWidth',2)
                        else
                            plot([currHooprP2x currHooprP2x+currHoopThrustWithPositionRemoved(1,f)],[currHooprP2y currHooprP2y+currHoopThrustWithPositionRemoved(2,f)], 'g', 'LineWidth',2)
                        end
                        hold off;

    %                     xlim([min([dronerNorm1x(:)', dronerNorm2x(:)', droneNorm1x(:)', droneNorm2x(:)', currHoopPosition(1), currHoopP2x, currHoopP1x, currHooprP2x, currHooprP1x, nextHoopPositionX, nextHooprP1x, nextHooprP2x, nextHoopP1x, nextHoopP2x]), ...
    %                         max([dronerNorm1x(:)', dronerNorm2x(:)', droneNorm1x(:)', droneNorm2x(:)', currHoopPosition(1), currHoopP2x, currHoopP1x, currHooprP2x, currHooprP1x, nextHoopPositionX, nextHooprP1x, nextHooprP2x, nextHoopP1x, nextHoopP2x])])
    % 
    %                     ylim([min([dronerNorm1y(:)', dronerNorm2y(:)', droneNorm1y(:)', droneNorm2y(:)', currHoopPosition(3), currHoopP2y, currHoopP1y, currHooprP2y, currHooprP1y, nextHoopPositionZ, nextHooprP1y, nextHooprP2y, nextHoopP1y, nextHoopP2y]), ...
    %                         max([dronerNorm1y(:)', dronerNorm2y(:)', droneNorm1y(:)', droneNorm2y(:)', currHoopPosition(3), currHoopP2y, currHoopP1y, currHooprP2y, currHooprP1y, nextHoopPositionZ, nextHooprP1y, nextHooprP2y, nextHoopP1y, nextHoopP2y])])   
    %                     %pbaspect([1, 1, 1])

                        xlim([currHoopDronePosition(1,f)-40, currHoopDronePosition(1,f)+40])
                        ylim([currHoopDronePosition(3,f)-40, currHoopDronePosition(3,f)+40])

                        pbaspect([1 1 1])
                        subplot(1,3,3)
                        plot(horizontalNextHoopNormalHeadingVector, 'r', 'LineWidth',1.25)

                        hold on;
                        plot(horizontalHoopNormalHeadingVector, 'b', 'LineWidth',1.25)
                        hold off;

                        hold on;
                        plot(horizontalHoopThrustAngleVector, 'g', 'LineWidth',1.25)
                        hold off;
                        hold on;
                        plot(horizontalNextHoopDroneOffsetVector, 'LineWidth',1.25)
                        hold off;


                        %hold on;
                        %plot(horizontalCameraGazeVector, 'm', 'LineWidth',1.25)
                        %hold off;

                       % hold on;
                        %plot(horizontalGazeAngleSpeedVector, 'g', 'LineWidth',1.25)
                        %hold off;




                        Lsteps = length(horizontalGazeAngleSpeedVector);
                        %hold on;
                        %xline(Lsteps-60, 'k--')
                        %hold off;

                        %legend('Approach Angle','Camera/Velocity Angle','Thrust/Velocity Angle','Gaze/Velocity Angle')
                        ylim([-180,180])
                        xlim([0, Lsteps])


                        subplot(1,3,2)

                        plot(nextHoopPositionX, nextHoopPositionZ, 'bo')


                        hold on;
                        plot([nextHooprP1x nextHooprP2x], [nextHooprP1y nextHooprP2y], 'ro')
                        hold off;

                        hold on
                        plot([nextHoopP1x nextHoopP2x], [nextHoopP1y nextHoopP2y], 'ko')
                        hold off;

                        hold on;
                        if ClosestPoint==1
                            plot([nextHooprP1x nextHooprP1x+vx(f)*200],[nextHooprP1y nextHooprP1y+vz(f)*200], 'LineWidth',2)

                            hold on;
                            plot([currHoopDronePosition(1, 1:f), nextHooprP2x], [currHoopDronePosition(3, 1:f) nextHooprP2y], 'LineWidth',2)
                            hold off;


                        else
                            plot([nextHooprP2x nextHooprP2x+vx(f)*200],[nextHooprP2y nextHooprP2y+vz(f)*200], 'LineWidth',2)

                            hold on;
                            plot([currHoopDronePosition(1, 1:f) nextHooprP1x], [currHoopDronePosition(3, 1:f) nextHooprP1y], 'LineWidth',2)
                            hold off;
                        end
                        hold off;
                        pbaspect([1 1 1])

                        xlim([nextHoopPositionX-40, nextHoopPositionX+40])
                        ylim([nextHoopPositionZ-40, nextHoopPositionZ+40])


                        drawnow;

                        gcf = getframe(fig1);
                        writeVideo(v1, gcf);
                    end
                    
                    
                    
                    
                    
                end



                %plot([currHoopP2x currHoopP1x], [currHoopP2y currHoopP1y], 'ko')

                if plotNextTheGazeAndHeadingForNextHoop && i<numHoops*2
                    horizontalVisualAngleGazeAndNextHoop(1,f) = calculateAngle(currHoopDronePosition([1,angleType],f)', ...
                        nextHoopPosition([1,angleType]), currHoopGazePosition([1,angleType],f)');
                    %% Unsure about these two being correct
                    horizontalVisualAngleSpeedVectorNextHoop(1,f) = calculateAngle(currHoopDronePosition([1,angleType],f)', ...
                        nextHoopPosition([1,angleType]), currHoopSpeed([1,angleType],f)');
                end

                if plotAngles
                    subplot(1,3,1)
                    plot([currHoopDronePosition(1,f), currHoopPosition(1)], [currHoopDronePosition(3,f), currHoopPosition(3)])
                    hold on;
                    plot([currHoopDronePosition(1,f), currHoopGazePosition(1,f)], [currHoopDronePosition(3,f), currHoopGazePosition(3,f)])
                    hold off;
                    legend('Hoop', 'Gaze')
                    title(num2str(horizontalVisualAngleGazeAndHoop(1,f)));

                    subplot(1,3,2)
                    plot([currHoopDronePosition(1,f), currHoopPosition(1)], [currHoopDronePosition(3,f), currHoopPosition(3)])
                    hold on;
                    plot([currHoopDronePosition(1,f), currHoopSpeed(1,f)], [currHoopDronePosition(3,f), currHoopSpeed(3,f)])
                    hold off;
                    legend('Hoop', 'Heading')
                    title(num2str(horizontalVisualAngleSpeedVector(1,f)));

                    subplot(1,3,3)
                    plot([currHoopDronePosition(1,f), currHoopSpeed(1,f)], [currHoopDronePosition(3,f), currHoopSpeed(3,f)])
                    hold on;
                    plot([currHoopDronePosition(1,f), currHoopGazePosition(1,f)], [currHoopDronePosition(3,f), currHoopGazePosition(3,f)])
                    hold off;
                    hold on;
                    plot([currHoopDronePosition(1,f), currHoopDronePosition(1,f)+rightControlX(f)], [currHoopDronePosition(3,f), currHoopDronePosition(3,f)+rightControlY(f)])
                    hold off;
                    legend('Heading', 'Gaze', 'Thrust')
                    title(num2str(horizontalGazeAngleSpeedVector(1,f)));



                    drawnow


                end


            end

             findZeroCrossings = @(v) find(v(:).*circshift(v(:), [-1 0]) <= 0); 
             zIndices = findZeroCrossings(horizontalSpeedAngleThrustVector);
             empMat = zeros(1,length(horizontalSpeedAngleThrustVector));
             empMat(zIndices) = 1;
             filterAvg = ones(1,5)/5;
             zeroSmoothed = conv(empMat, filterAvg, 'same');
             [~, maxZeroIndex] = max(zeroSmoothed);
             dirChange = length(horizontalSpeedAngleThrustVector) - maxZeroIndex;
%             
%             dronePosThrustZerosX = currDronePosX(zIndices); 
%             dronePosThrustZerosZ = currDronePosZ(zIndices); 
%             numZeros = ones(1,length(zIndices));
%             hoopZerosNum = numZeros*hoopNum; 
%             thrustDirectionRelHoopAtZero = horizontalHoopThrustAngleVector;
            
            if plotApproachAngle 
                close(v1);
            end

            if plotAll

                figure(1);
                subplot(2,2,1)
                plot(horizontalVisualAngleGazeAndHoop, 'b', 'LineWidth',2)
                hold on;
                plot(horizontalVisualAngleSpeedVector, 'r', 'LineWidth',2)
                hold off;
                hold on;
                plot(horizontalGazeAngleSpeedVector, 'g', 'LineWidth',2)
                hold off;
                hold on;
                plot(horizontalGazeAngleThrustVector, 'y', 'LineWidth',2)
                hold off;
                hold on;
                plot(horizontalSpeedAngleThrustVector, 'k', 'LineWidth',2)
                hold off;
                %hold on;
                %plot(horizontalVisualAngleGazeAndHoop+horizontalVisualAngleSpeedVector, 'k')
                %hold off;

                ylim([0,180])
                legend('Angle - gaze and hoop', 'Angle - heading/speed and hoop', 'Angle - Gaze and heading/speed', 'Angle - Gaze and Thrust', 'Angle - Thrust and Heading')
                title('Horizontal Angle')
                xlabel('Frame')
                ylabel('Degrees')

                if plotNextTheGazeAndHeadingForNextHoop
                    subplot(2,2,3)

                    plot(horizontalVisualAngleGazeAndNextHoop, 'b', 'LineWidth',2)
                    hold on;
                    plot(horizontalVisualAngleSpeedVectorNextHoop, 'r', 'LineWidth',2)
                    hold off;

                    ylim([0,180])
                    legend('Angle - gaze and Next hoop', 'Angle - heading/speed and Next hoop')
                    title('Horizontal Angle to next hoop')
                    xlabel('Frame')
                    ylabel('Degrees')
                else
                    subplot(2,2,3)

                    plot(rightControlX, 'b', 'LineWidth',2)
                    hold on;
                    plot(leftControlX, 'r', 'LineWidth',2)
                    hold off;

                    hold on;
                    plot(rightControlY, 'g', 'LineWidth',2)
                    hold off;

                    hold on;
                    plot(leftControlY, 'y', 'LineWidth',2)
                    hold off;

                    ylim([-1,1])
                    legend('Right Controller X','Left Controller X', 'Right Controller Y','Left Controller Y')
                    title('Steering Commands')
                    xlabel('Frame')
                    ylabel('Controller Joystick Offset Magnitude')
                end


                subplot(2,2,2)
                crosscorr(horizontalGazeAngleThrustVector, rightControlX, 'NumLags',currNumFrames-1);

                subplot(2,2,4)
                plot(distanceDifferenceVectorGazeAndHoop./5)
                title('Difference between Gaze Position and Hoop Position')
            end
            

            
%             figure(200);
%             subplot(1,2,1)
%             %plot(horizontalGazeAngleThrustVector, 'r')
%             
%             plot(horizontalNextHoopThrustAngleVector, 'g')
%             
%             
%             hold on;
%             plot(horizontalVisualAngleSpeedVector(1:100), 'Color', '#7E2F8E')
%             hold off;
%             
%             hold on;
%             plot(horizontalVisualAngleSpeedVectorNext, 'r')
%             hold off;
%             
%             hold on;
%             plot(horizontalVisualAngleGazeAndNextHoop, 'b')
%             hold off;
%             
%             hold on;
%             plot(horizontalVisualAngleGazeAndHoop(1:100), 'c')
%             hold off;
%             
%             hold on;
%             plot(horizontalHoopThrustAngleVector(1:100), 'm')
%             hold off;
%             
%             hold on;
%             plot(horizontalDroneAndHoops(1:100), 'k')
%             hold off;
%             
%             hold on;
%             xline(100, 'k--')
%             hold off;
%             legend('Thrust/Next Hoop Angle','Heading/Curr Hoop Angle','Heading/Next Hoop Angle','Gaze/Next Hoop Angle','Gaze/Curr Hoop Angle', 'Thrust/Curr Hoop Angle')
%             subplot(1,2,2)
%             autocorr(horizontalGazeAngleThrustVector, 'NumLags', currNumFrames-1)
            
             [rTHp_GHpall, lagTHp_GHpall, b, h] = crosscorr(horizontalVisualAngleGazeAndHoop,horizontalHoopThrustAngleVector,  'NumLags',numberOfLags); % Thrust Hoop - Gaze Hoop
             rTHp_GHpall = rTHp_GHpall((numberOfLags+1):end);
             lagTHp_GHpall = lagTHp_GHpall((numberOfLags+1):end);
             [~, indTHp_GHp] = max(abs(rTHp_GHpall));
             rTHp_GHp = rTHp_GHpall(indTHp_GHp);
             lagTHp_GHp = lagTHp_GHpall(indTHp_GHp);
             
             
             [rHHp_GHpall, lagHHp_GHpall, b, h] = crosscorr( horizontalVisualAngleGazeAndHoop, horizontalVisualAngleSpeedVector,'NumLags',numberOfLags); % Heading Hoop - Gaze Hoop
             rHHp_GHpall = rHHp_GHpall((numberOfLags+1):end);
             lagHHp_GHpall = lagHHp_GHpall((numberOfLags+1):end);
             [~, indHHp_GHp] = max(abs(rHHp_GHpall));
             rHHp_GHp = rHHp_GHpall(indHHp_GHp);
             lagHHp_GHp = lagHHp_GHpall(indHHp_GHp);

             [rGH_GHpall, lagGH_GHpall, b, h] = crosscorr(horizontalVisualAngleGazeAndHoop, horizontalGazeAngleSpeedVector, 'NumLags',numberOfLags); % Gaze Heading - Gaze Hoop
             rGH_GHpall = rGH_GHpall((numberOfLags+1):end);
             lagGH_GHpall = lagGH_GHpall((numberOfLags+1):end);
             [~, indGH_GHp] = max(abs(rGH_GHpall));
             rGH_GHp = rGH_GHpall(indGH_GHp);
             lagGH_GHp = lagGH_GHpall(indGH_GHp);

             [rCH_GHpall, lagCH_GHpall, b, h] = crosscorr( horizontalVisualAngleGazeAndHoop, horizontalCameraSpeedVector,'NumLags',numberOfLags); % Camera Heading - Gaze Hoop
             rCH_GHpall = rCH_GHpall((numberOfLags+1):end);
             lagCH_GHpall = lagCH_GHpall((numberOfLags+1):end);
             [~, indCH_GHp] = max(abs(rCH_GHpall));
             rCH_GHp = rCH_GHpall(indCH_GHp);
             lagCH_GHp = lagCH_GHpall(indCH_GHp);
             
             [rTH_GHpall, lagTH_GHpall, b, h] = crosscorr(horizontalVisualAngleGazeAndHoop,horizontalSpeedAngleThrustVector,  'NumLags',numberOfLags); %Thrust heading - Gaze Hoop
             rTH_GHpall = rTH_GHpall((numberOfLags+1):end);
             lagTH_GHpall = lagTH_GHpall((numberOfLags+1):end);
             [~, indTH_GHp] = max(abs(rTH_GHpall));
             rTH_GHp = rTH_GHpall(indTH_GHp);
             lagTH_GHp = lagTH_GHpall(indTH_GHp);
             
             [rGH_THpall, lagGH_THpall, b, h] = crosscorr( horizontalHoopThrustAngleVector, horizontalGazeAngleSpeedVector,'NumLags',numberOfLags); % Gaze heading - thrust hoop
             rGH_THpall = rGH_THpall(1:numberOfLags);
             lagGH_THpall = lagGH_THpall(1:numberOfLags);
             [~, indGH_THp] = max(abs(rGH_THpall));
             rGH_THp = rGH_THpall(indGH_THp);
             lagGH_THp = lagGH_THpall(indGH_THp);
             
             [rGH_HHpall, lagGH_HHpall, b, h] = crosscorr( horizontalVisualAngleSpeedVector,horizontalGazeAngleSpeedVector, 'NumLags',numberOfLags); % Gaze heading - heading hoop
             rGH_HHpall = rGH_HHpall(1:numberOfLags);
             lagGH_HHpall = lagGH_HHpall(1:numberOfLags);
             [~, indGH_HHp] = max(abs(rGH_HHpall));
             rGH_HHp = rGH_HHpall(indGH_HHp);
             lagGH_HHp = lagGH_HHpall(indGH_HHp);
             
              [rTH_HHpall, lagTH_HHpall, b, h] = crosscorr( horizontalVisualAngleSpeedVector, horizontalSpeedAngleThrustVector,'NumLags',numberOfLags); % Thrust heading - heading hoop
             rTH_HHpall = rTH_HHpall(1:numberOfLags);
             lagTH_HHpall = lagTH_HHpall(1:numberOfLags);
             [~, indTH_HHp] = max(abs(rTH_HHpall));
             rTH_HHp = rTH_HHpall(indTH_HHp);
             lagTH_HHp = lagTH_HHpall(indTH_HHp);
             
             [rCH_GHall, lagCH_GHall, b, h] = crosscorr(horizontalCameraSpeedVector, horizontalGazeAngleSpeedVector, 'NumLags',numberOfLags); % camera heading - gaze heading
             rCH_GHall = rCH_GHall((numberOfLags+1):end);
             lagCH_GHall = lagCH_GHall((numberOfLags+1):end);
             [~, indCH_GH] = max(abs(rCH_GHall));
             rCH_GH = rCH_GHall(indCH_GH);
             lagCH_GH = lagCH_GHall(indCH_GH);
             
             [rCH_CGall, lagCH_CGall, b, h] = crosscorr(gradient(leftControlX), gradient(horizontalCameraGazeVector), 'NumLags',numberOfLags); % camera heading - camera gaze 
             %rCH_CGall = rCH_CGall((numberOfLags+1):end);
             %lagCH_CGall = lagCH_CGall((numberOfLags+1):end);
             [~, indCH_CG] = max(abs(rCH_CGall));
             rCH_CG = rCH_CGall(indCH_CG);
             lagCH_CG = lagCH_CGall(indCH_CG);
             
             
             [rTH_CHall, lagTH_CHall, b, h] = crosscorr( horizontalCameraSpeedVector, horizontalSpeedAngleThrustVector, 'NumLags',numberOfLags); % thrust heading - camera heading 
             rTH_CHall = rTH_CHall((numberOfLags+1):end);
             lagTH_CHall = lagTH_CHall((numberOfLags+1):end);
             [~, indTH_CH] = max(abs(rTH_CHall));
             rTH_CH = rTH_CHall(indTH_CH);
             lagTH_CH = lagTH_CHall(indTH_CH);

             [rGT_GHpall, lagGT_GHpall, b, h] = crosscorr( horizontalVisualAngleGazeAndHoop, horizontalGazeAngleThrustVector, 'NumLags',numberOfLags); % Gaze thrust - Gaze Hoop
             rGT_GHpall = rGT_GHpall((numberOfLags+1):end);
             lagGT_GHpall = lagGT_GHpall((numberOfLags+1):end);
             [~, indGT_GHp] = max(abs(rGT_GHpall));
             rGT_GHp = rGT_GHpall(indGT_GHp);
             lagGT_GHp = lagGT_GHpall(indGT_GHp);
             
             %figure(200);
             %subplot(1,2,1)
             [rTH_GHall, lagTH_GHall, b, h] = crosscorr(horizontalGazeAngleSpeedVector, horizontalSpeedAngleThrustVector, 'NumLags',numberOfLags); % thrust heading - gaze heading
             %subplot(1,2,2)
             %[c,lags] = xcorr(horizontalSpeedAngleThrustVector,horizontalGazeAngleSpeedVector,numberOfLags,'coeff');
             %stem(lags,c)
             %rTH_GHall = rTH_GHall((numberOfLags+1):end);
             %lagTH_GHall = lagTH_GHall((numberOfLags+1):end);
             [~, indTH_GH] = max(abs(rTH_GHall));
             rTH_GH = rTH_GHall(indTH_GH);
             lagTH_GH = lagTH_GHall(indTH_GH);
%              if lagTH_GH==0 && numberCollisions>1
%                 figure(21); 
%                 subplot(1,2,1)
%                 [rTH_GHall, lagTH_GHall, b, h] = crosscorr(horizontalGazeAngleSpeedVector, horizontalSpeedAngleThrustVector, 'NumLags',numberOfLags);
%                 subplot(1,2,2)
%                 plot(horizontalGazeAngleSpeedVector)
%                 hold on;
%                 plot(horizontalSpeedAngleThrustVector, 'r')
%                 hold off;
%                 legend('Gaze','Thrust')
%                 'Lag with highest Corr is 0...'
%                  hoopNum
%              end
%              
            prevthrustMat = [prevthrustMat horizontalGazeAngleThrustVector];
            prevheadingGazeMat = [prevheadingGazeMat horizontalGazeAngleSpeedVector];
            prevVDmat = [prevVDmat horizontalVisualAngleGazeAndHoop];
            prevHeadingHoopMat = [prevHeadingHoopMat horizontalVisualAngleSpeedVector];

            distanceToNextHoop = sqrt((currHoopPositionX-nextHoopPositionX)^2 + (currHoopPositionY - nextHoopPositionY)^2 + (currHoopPositionZ-nextHoopPositionZ)^2);
            
            numFrames = length(horizontalCameraHoopVector);
            
            cameraRelToHoop0 = horizontalCameraHoopVector(1);
            cameraRelToHoop25 = horizontalCameraHoopVector(round(numFrames*0.25));
            cameraRelToHoop50 = horizontalCameraHoopVector(round(numFrames*0.5));
            cameraRelToHoop75 = horizontalCameraHoopVector(round(numFrames*0.75));
            cameraRelToHoop100 = horizontalCameraHoopVector(end);
            
            cameraRotationRate15 =   findAvgRateOfChange(horizontalCameraHoopVector, numFrames-15, numFrames); %(horizontalCameraHoopVector(end) - horizontalCameraHoopVector(end-15))/15;
            cameraRotationRateALL =   findAvgRateOfChange(horizontalCameraHoopVector, 1, numFrames); %(horizontalCameraHoopVector(end) - horizontalCameraHoopVector(1))/length(horizontalCameraHoopVector);
            
            
            if (hoopNum==1 && lap==0) || (lap==0 && hoopNum==42)
                
                ApproachToNatNm1 = NaN;
                prevApproachToN=horizontalNextHoopNormalHeadingVector(end);
                
                
                AngularOffsetToNatNm1 = NaN;
                prevAngularOffsetToN = horizontalNextHoopDroneOffsetVector(end);
            else
                ApproachToNatNm1 = prevApproachToN;
                prevApproachToN = horizontalNextHoopNormalHeadingVector(end);
                
                
                AngularOffsetToNatNm1 =prevAngularOffsetToN;
                prevAngularOffsetToN = horizontalNextHoopDroneOffsetVector(end);
            end
            
                        
            hoopThrust0 = horizontalHoopThrustAngleVector(1);
            hoopThrust25 = horizontalHoopThrustAngleVector(round(numFrames*0.25));
            hoopThrust50 = horizontalHoopThrustAngleVector(round(numFrames*0.5));
            hoopThrust75 = horizontalHoopThrustAngleVector(round(numFrames*0.75));
            hoopThrust100 = horizontalHoopThrustAngleVector(end);

            
            nextHoopThrust0 = horizontalNextHoopThrustAngleVector(1);
            nextHoopThrust25 = horizontalNextHoopThrustAngleVector(round(numFrames*0.25));
            nextHoopThrust50 = horizontalNextHoopThrustAngleVector(round(numFrames*0.5));
            nextHoopThrust75 = horizontalNextHoopThrustAngleVector(round(numFrames*0.75));
            nextHoopThrust100 = horizontalNextHoopThrustAngleVector(end);

            
            thrustHoopDiff0 = diffBetweenHoopNNP1AndThrust(end);
            thrustHoopDiff5 = diffBetweenHoopNNP1AndThrust(end-5);
            thrustHoopDiff15 = diffBetweenHoopNNP1AndThrust(end-15);
            thrustHoopDiff30 = diffBetweenHoopNNP1AndThrust(end-30);
            
            if length(diffBetweenHoopNNP1AndThrust) > 60
                thrustHoopDiff60 = diffBetweenHoopNNP1AndThrust(end-60);
            else
                thrustHoopDiff60 = NaN;
            end
            
            
            thrustNextHoop = horizontalNextHoopThrustAngleVector(end); % depricated. remove. 
            headingNextHoop = horizontalVisualAngleSpeedVectorNext(end);
            
            if ~isreal(rTHp_GHp)
                rTHp_GHp = NaN;
            end

            if ~isreal(rHHp_GHp)
                rHHp_GHp = NaN;
            end

            if ~isreal(rGH_GHp)
                rGH_GHp = NaN;
            end

            if ~isreal(rCH_GHp)
                rCH_GHp = NaN;
            end

            if ~isreal(rTH_GHp)
                rTH_GHp = NaN;
            end
            

            if ~isreal(rGH_THp)
                rGH_THp = NaN;
            end

            if ~isreal(rGH_HHp)
                rGH_HHp = NaN;
            end

            if ~isreal(rTH_HHp)
                rTH_HHp = NaN;
            end

            if ~isreal(rCH_GH)
                rCH_GH = NaN;
            end

            if ~isreal(rTH_GH)
                rTH_GH = NaN;
            end
            
            if ~isreal(rGT_GHp)
                rGT_GHp = NaN;
            end
            
            if ~isreal(rTH_CH)
                rTH_CH = NaN;
            end
            
            ApproachAngleY0 = horizontalHoopNormalHeadingVector(1);
            
            
            if abs(ApproachToNatNm1 - ApproachAngleY0) >30
                ApproachToNatNm1 - ApproachAngleY0;
                somethingWeirdWithApproach = 1;
            else
                somethingWeirdWithApproach = 0;
            end
            prevVectorOfApproaches = horizontalNextHoopNormalHeadingVector;
            ApproachAngleY25 = horizontalHoopNormalHeadingVector(round(numFrames*0.25));
            ApproachAngleY50 = horizontalHoopNormalHeadingVector(round(numFrames*0.5));
            ApproachAngleY75 = horizontalHoopNormalHeadingVector(round(numFrames*0.75));
            ApproachAngleY100 = horizontalHoopNormalHeadingVector(end);
            
            approachAngleRate15 =  findAvgRateOfChange(horizontalHoopNormalHeadingVector, numFrames-15, numFrames); %(horizontalHoopNormalHeadingVector(end) - horizontalHoopNormalHeadingVector(end-15))/15;
            approachAngleRateALL =  findAvgRateOfChange(horizontalHoopNormalHeadingVector, 1, numFrames); %(horizontalHoopNormalHeadingVector(end) - horizontalHoopNormalHeadingVector(1))/length(horizontalHoopNormalHeadingVector);
            
            if abs(ApproachAngleY0)>90
                ApproachAngleY0                    
   
            end
            numFrames
            thrustRelativeToHoopN0 = mean(horizontalHoopThrustAngleVector(1:8));
            thrustRelativeToHoopN25 = mean(horizontalHoopThrustAngleVector((round(numFrames*0.25)-4):(round(numFrames*0.25)+4)));
            thrustRelativeToHoopN50 = mean(horizontalHoopThrustAngleVector((round(numFrames*0.5)-4):(round(numFrames*0.5)+4)));
            thrustRelativeToHoopN75 = mean(horizontalHoopThrustAngleVector((round(numFrames*0.75)-4):(round(numFrames*0.75)+4)));
            
            thrustRelativeToHoopN100 = mean(horizontalHoopThrustAngleVector((numFrames-8):end));
            
           thrustAngleRate15 = findAvgRateOfChange(horizontalHoopThrustAngleVector, numFrames-15, numFrames);% (horizontalHoopThrustAngleVector(end) - horizontalHoopThrustAngleVector(end-15))/15;
           thrustAngleRateALL = findAvgRateOfChange(horizontalHoopThrustAngleVector, 1, numFrames); %(horizontalHoopThrustAngleVector(end) - horizontalHoopThrustAngleVector(1))/length(horizontalHoopThrustAngleVector);

            
            if abs(thrustRelativeToHoopN0)>90
                thrustRelativeToHoopN0                    
   
            end
            
            
            if ClosestPoint==1    % I think there might be a bug introduced here. Debug this. 
                dfx = nextHoopPositionX - currHoopPositionX;
                dfy = nextHoopPositionZ - currHoopPositionZ;
                VisualAngleBetweenHoops = -calculateAngle([currHooprP1x currHooprP1y], ...
                            [currHooprP2x currHooprP2y], [nextHoopPositionX nextHoopPositionZ]);

                 subplot(1,3,2)        
                 hold on;
                 plot([currHooprP2x, currHooprP1x], [currHooprP2y, currHooprP1y], 'k-')
                 hold off;
                 hold on;
                 plot([currHooprP1x, nextHoopPositionX], [currHooprP1y, nextHoopPositionZ], 'k-')
                 hold off;
                if VisualAngleBetweenHoops > 90 
                    'Angle is higher than 90...';
                    VisualAngleBetweenHoops = VisualAngleBetweenHoops - 180;
                elseif VisualAngleBetweenHoops < -90
                    'Angle is lower than -90...';
                    VisualAngleBetweenHoops = VisualAngleBetweenHoops + 180;
                end
            else
                dfx = nextHoopPositionX - currHoopPositionX;
                dfy = nextHoopPositionZ - currHoopPositionZ;
                VisualAngleBetweenHoops = -calculateAngle([currHooprP2x currHooprP2y], ...
                            [currHooprP1x currHooprP1y], [nextHoopPositionX nextHoopPositionZ]);
                
                 subplot(1,3,2)        
                 hold on;
                 plot([currHooprP2x, currHooprP1x], [currHooprP2y, currHooprP1y], 'k-')
                 hold off;
                 hold on;
                 plot([currHooprP2x, nextHoopPositionX], [currHooprP2y, nextHoopPositionZ], 'k-')
                 hold off;
                
                if VisualAngleBetweenHoops > 90 
                    'Angle is higher than 90...';
                    VisualAngleBetweenHoops = VisualAngleBetweenHoops - 180;
                elseif VisualAngleBetweenHoops < -90
                    'Angle is lower than -90...';
                    VisualAngleBetweenHoops = VisualAngleBetweenHoops + 180;
                end
            end
         
            
%             if VisualAngleBetweenHoops > 90
%                 'Angle is higher than expected...'
%                 plot([currHooprP2x currHooprP1x],[currHooprP2y currHooprP1y], 'b') 
%                 hold on;
%                 plot([currHooprP2x currHooprP2x+dfx],[currHooprP2y currHooprP2y+dfy], 'r') 
%                 hold off;
%             end
            
            
           if createTimeseriesData
                timeSequence = (length(firstFrame:lastFrame):-1:1)';
                Sub = repelem(Subject, length(timeSequence))';
                Cond = repelem(Condition, length(timeSequence))';
                blck = block*ones(1, length(timeSequence))';
                lapNum = lap*ones(1, length(timeSequence))';
                hoopNumber = hoopNum*ones(1, length(timeSequence))';
                headingHoopAngle = horizontalVisualAngleSpeedVector';
                gazeHeadingAngle = horizontalGazeAngleSpeedVector';
                thrustHeadingAngle = horizontalSpeedAngleThrustVector';
                gazeHoopAngle = horizontalVisualAngleGazeAndHoop';
                gazeNextHoopAngle = horizontalVisualAngleGazeAndNextHoop';
                headingNextHoopAngle = horizontalVisualAngleSpeedVectorNext';
                throughHoopData = ~cellfun(@isempty, throughHoopData(firstFrame:lastFrame));
                cameraGaze = horizontalCameraGazeVector';
                droneYaw = currHoopDroneOrientY';
                leftControlX = leftControlX';
                cameraHeading = horizontalCameraSpeedVector';
                rateCameraHeading = calculateVelocity(cameraHeading, timeStamp(firstFrame:lastFrame));
                %rateCameraHeading = gradient(cameraHeading)*60;
                %plot(timeSequence, throughHoopData, 'ko')
                velX = speedMag(1, firstFrame:lastFrame)';
                velY = speedMag(2, firstFrame:lastFrame)';
                velZ = speedMag(3, firstFrame:lastFrame)';
                gazeDistance = (sqrt(sum((currHoopGazePosition - currHoopDronePosition).^2, 1))./5)';
                collisions = ~cellfun(@isempty,currCollisionData);
                
                if prevDataFrameLogical == 0
                    prevDataFrame = table(Sub, Cond, blck, lapNum, hoopNumber, timeSequence, headingHoopAngle, gazeHeadingAngle, thrustHeadingAngle, ...
                        gazeHoopAngle, gazeNextHoopAngle, headingNextHoopAngle, throughHoopData, gazeTarget, distanceToHoop, headingTarget, cameraGaze, droneYaw, currCollisionData, ...
                        gazeDistance, leftControlX, cameraHeading, velX, velY, velZ, rateCameraHeading, collisions, distanceToHoopNp1_scaled, distanceToHoopNp1_unitymeter, lateralDistanceToHoopNp1_scaled, lateralDistanceToHoopNp1_unitymeter);
                    prevDataFrameLogical = 1;
                else
                    currDataFrame = table(Sub, Cond, blck, lapNum, hoopNumber, timeSequence, headingHoopAngle, gazeHeadingAngle, thrustHeadingAngle, ...
                        gazeHoopAngle, gazeNextHoopAngle, headingNextHoopAngle, throughHoopData, gazeTarget, distanceToHoop, headingTarget, cameraGaze, droneYaw, currCollisionData,...
                        gazeDistance, leftControlX, cameraHeading, velX, velY, velZ, rateCameraHeading, collisions, distanceToHoopNp1_scaled, distanceToHoopNp1_unitymeter, lateralDistanceToHoopNp1_scaled, lateralDistanceToHoopNp1_unitymeter);
                    prevDataFrame = [prevDataFrame; currDataFrame];
                end

           else
               gazeThrustAtHoop = horizontalGazeAngleThrustVector(end);
                if prevDataFrameLogical == 0
                    prevDataFrame = table(Subject, Condition, block, lap, hoopNum, droneOrientXatHoop, droneOrientYatHoop, droneOrientZatHoop, ...
                        rTHp_GHp, lagTHp_GHp, rHHp_GHp, lagHHp_GHp, rGH_GHp, lagGH_GHp, rCH_GHp, lagCH_GHp, ...
                        rTH_GHp, lagTH_GHp, rGH_THp, lagGH_THp, rGH_HHp, lagGH_HHp, rTH_HHp, lagTH_HHp, rCH_GH, lagCH_GH, ...
                        rTH_GH, lagTH_GH, rTH_CH, lagTH_CH, rGT_GHp, lagGT_GHp, rCH_CG, lagCH_CG, currHoopPositionX, currHoopPositionY, currHoopPositionZ, currHoopOrientX, ...
                        currHoopOrientY, currHoopOrientZ, nextHoopPositionX, nextHoopPositionY, nextHoopPositionZ, nextHoopOrientX, nextHoopOrientY, ...
                        nextHoopOrientZ, distanceToNextHoop, Direction, ApproachAngleY0, ApproachAngleY25, ApproachAngleY50, ApproachAngleY75, ApproachAngleY100, VisualAngleBetweenHoops, prevHoopVisualAngle, ...
                        distanceToHoopFirstGaze, timeBeforeReachingHoopFirstGaze, LAF, gazeDistanceToHoop, timeAfterPreviousHoopFirstGazeNextHoop, ...
                        timeBetweenHoops, LAFthroughHoop, pathCurvature, numberCollisions, prevSegmentCurvature, timeThroughHoop, dirChange, gazeThrustAtHoop, cameraRelToHoop0, cameraRelToHoop25, cameraRelToHoop50, cameraRelToHoop75, cameraRelToHoop100, ...
                        thrustHoopDiff0, thrustHoopDiff5, thrustHoopDiff15, thrustHoopDiff30, thrustHoopDiff60, hoopThrust0, hoopThrust25, hoopThrust50, hoopThrust75, hoopThrust100, ...
                        nextHoopThrust0, nextHoopThrust25, nextHoopThrust50, nextHoopThrust75, nextHoopThrust100, ApproachToNatNm1, AngularOffsetToNatNm1, ...
                        thrustNextHoop, headingNextHoop, thrustRelativeToHoopN0, thrustRelativeToHoopN25, thrustRelativeToHoopN50, thrustRelativeToHoopN75, thrustRelativeToHoopN100, cameraRotationRate15, thrustAngleRate15, approachAngleRate15, cameraRotationRateALL, thrustAngleRateALL, approachAngleRateALL, somethingWeirdWithApproach);
                    prevDataFrameLogical = 1;
                else
                    currDataFrame = table(Subject, Condition, block, lap, hoopNum, droneOrientXatHoop, droneOrientYatHoop, droneOrientZatHoop, ...
                        rTHp_GHp, lagTHp_GHp, rHHp_GHp, lagHHp_GHp, rGH_GHp, lagGH_GHp, rCH_GHp, lagCH_GHp, ...
                        rTH_GHp, lagTH_GHp, rGH_THp, lagGH_THp, rGH_HHp, lagGH_HHp, rTH_HHp, lagTH_HHp, rCH_GH, lagCH_GH, ...
                        rTH_GH, lagTH_GH, rTH_CH, lagTH_CH, rGT_GHp, lagGT_GHp, rCH_CG, lagCH_CG, currHoopPositionX, currHoopPositionY, currHoopPositionZ, currHoopOrientX, ...
                        currHoopOrientY, currHoopOrientZ, nextHoopPositionX, nextHoopPositionY, nextHoopPositionZ, nextHoopOrientX, nextHoopOrientY, ...
                        nextHoopOrientZ, distanceToNextHoop, Direction, ApproachAngleY0, ApproachAngleY25, ApproachAngleY50, ApproachAngleY75, ApproachAngleY100, VisualAngleBetweenHoops, prevHoopVisualAngle, ...
                        distanceToHoopFirstGaze, timeBeforeReachingHoopFirstGaze, LAF, gazeDistanceToHoop, timeAfterPreviousHoopFirstGazeNextHoop, ...
                        timeBetweenHoops, LAFthroughHoop, pathCurvature, numberCollisions, prevSegmentCurvature, timeThroughHoop, dirChange, gazeThrustAtHoop, cameraRelToHoop0, cameraRelToHoop25, cameraRelToHoop50, cameraRelToHoop75, cameraRelToHoop100, ...
                        thrustHoopDiff0, thrustHoopDiff5, thrustHoopDiff15, thrustHoopDiff30, thrustHoopDiff60, hoopThrust0, hoopThrust25, hoopThrust50, hoopThrust75, hoopThrust100, ...
                        nextHoopThrust0, nextHoopThrust25, nextHoopThrust50, nextHoopThrust75, nextHoopThrust100, ApproachToNatNm1, AngularOffsetToNatNm1, ...
                        thrustNextHoop, headingNextHoop, thrustRelativeToHoopN0, thrustRelativeToHoopN25, thrustRelativeToHoopN50, thrustRelativeToHoopN75, thrustRelativeToHoopN100, cameraRotationRate15, thrustAngleRate15, approachAngleRate15, cameraRotationRateALL, thrustAngleRateALL, approachAngleRateALL, somethingWeirdWithApproach);
                    prevDataFrame = [prevDataFrame; currDataFrame];
                end

                prevHoopVisualAngle = VisualAngleBetweenHoops;
                prevSegmentCurvature = pathCurvature;
           end
           
        end
        
    else
        
        
            
            hoopNum = NaN;
            droneOrientXatHoop = NaN;
            droneOrientYatHoop = NaN;
            droneOrientZatHoop = NaN;
            timeThroughHoop = NaN;
            gazeThrustAtHoop = NaN;
             rTHp_GHp = NaN;
             lagTHp_GHp = NaN;
             

             rHHp_GHp = NaN;
             lagHHp_GHp = NaN;


             rGH_GHp = NaN;
             lagGH_GHp = NaN;


             rCH_GHp = NaN;
             lagCH_GHp = NaN;
             

             rTH_GHp = NaN;
             lagTH_GHp = NaN;
             
             rGH_THp = NaN;
             lagGH_THp = NaN;
             
             rGH_HHp = NaN;
             lagGH_HHp = NaN;
             
             rTH_HHp = NaN;
             lagTH_HHp = NaN;
 
             rGT_GHp = NaN;
             lagGT_GHp = NaN;
             
            currHoopPositionX = NaN;
            currHoopPositionY = NaN;
            currHoopPositionZ = NaN;
            currHoopOrientX = NaN;
            currHoopOrientY = NaN;
            currHoopOrientZ = NaN;
            nextHoopPositionX = NaN;
            nextHoopPositionY = NaN;
            nextHoopPositionZ = NaN;
            nextHoopOrientX = NaN;
            nextHoopOrientY = NaN;
            nextHoopOrientZ = NaN;
            distanceToNextHoop = NaN;
            Direction = NaN;
            ApproachAngleY = NaN;
            ApproachAngleY0 = NaN; 
            ApproachAngleY5 = NaN; 
            ApproachAngleY15 = NaN;
            ApproachAngleY30 = NaN;
            ApproachAngleY60 = NaN;
            VisualAngleBetweenHoops = NaN;
            distanceToHoopFirstGaze = NaN;
            timeBeforeReachingHoopFirstGaze = NaN;
            LAF = NaN;
            gazeDistanceToHoop = NaN;
            timeAfterPreviousHoopFirstGazeNextHoop = NaN;
            timeBetweenHoops = NaN;
            LAFthroughHoop = NaN;
            prevHoopVisualAngle = NaN;
            cameraRelToHoop0 = NaN;
            cameraRelToHoop5 = NaN;
            cameraRelToHoop15 = NaN;
            cameraRelToHoop30 = NaN;
            cameraRelToHoop60 = NaN;
            thrustHoopDiff0 = NaN; 
            thrustHoopDiff5 = NaN; 
            thrustHoopDiff15 = NaN; 
            thrustHoopDiff30 = NaN; 
            thrustHoopDiff60 = NaN;
            hoopThrust0 = NaN; 
            hoopThrust5= NaN; 
            hoopThrust15= NaN; 
            hoopThrust30= NaN; 
            hoopThrust60= NaN; 
            nextHoopThrust0= NaN; 
            nextHoopThrust5= NaN; 
            nextHoopThrust15= NaN; 
            nextHoopThrust30= NaN; 
            nextHoopThrust60= NaN; 
            ApproachToNatNm1 = NaN; 
            AngularOffsetToNatNm1 = NaN;
            thrustNextHoop = NaN;
            headingNextHoop = NaN;
            thrustRelativeToHoopN = NaN;
            thrustRelativeToHoopN5= NaN;
            thrustRelativeToHoopN15= NaN;
            thrustRelativeToHoopN30= NaN;
            thrustRelativeToHoopN60= NaN;
            cameraRotationRate15= NaN;
            thrustAngleRate15= NaN;
            approachAngleRate15= NaN;
            cameraRotationRateALL= NaN;
            thrustAngleRateALL= NaN;
            approachAngleRateALL= NaN;
            somethingWeirdWithApproach = 0;
            
           for k=1:numHoops*2 
                if k==1 
                    firstFrame = 1;
                else
                    firstFrame = hoopFrames(k-1);
                end

                if k<=numHoops
                    lap = 0;
                elseif k>numHoops
                    lap = 1;
                end

                hoopNum = k;

                if block==5
                    hoopNum = (numHoops*2)-hoopNum;
                end

                if hoopNum < numHoops*2
                    lastFrame = hoopFrames(k)-1;

                else
                    lastFrame = hoopFrames(k)-1;

                end

                %firstFrame = hoopFrames(i) - 60;

                %if length(firstFrame:lastFrame)<121
                  %  'WHY YOU SO SHORT'
                %end
                
                

                if lastFrame > size(positionData,2)
                    lastFrame = size(positionData,2);
                end
                
                numberOfFrames = length(firstFrame:lastFrame);
                if numberOfFrames>60
                    numberOfLags = 30;
                else
                    numberOfLags = numberOfFrames-1;
                end

                currHoopDronePositionX = positionData(1,firstFrame:lastFrame);
                currHoopDronePositionY = positionData(2,firstFrame:lastFrame);
                currHoopDronePositionZ = positionData(3,firstFrame:lastFrame);
                
                currHoopDroneOrientX = positionData(5,firstFrame:lastFrame);
                currHoopDroneOrientY = positionData(6,firstFrame:lastFrame);
                currHoopDroneOrientZ = positionData(7,firstFrame:lastFrame);
                
                currHoopGazePositionX = gazePosition(1, firstFrame:lastFrame);
                currHoopGazePositionY = gazePosition(2, firstFrame:lastFrame);
                currHoopGazePositionZ = gazePosition(3, firstFrame:lastFrame);

                currHoopSpeedX = speedVector(1, firstFrame:lastFrame);
                currHoopSpeedY = speedVector(2, firstFrame:lastFrame);
                currHoopSpeedZ = speedVector(3, firstFrame:lastFrame);
                
                dronePositionNormalPoints = findNormalPoints(currHoopDronePositionX, currHoopDronePositionZ, currHoopDroneOrientY);

                droneNorm1x = dronePositionNormalPoints(1,:);
                droneNorm1y = dronePositionNormalPoints(2,:);
                droneNorm2x = dronePositionNormalPoints(3,:);
                droneNorm2y = dronePositionNormalPoints(4,:);
                
                leftControlX = controllerData(1, firstFrame:lastFrame)+eps;
                leftControlY = controllerData(2, firstFrame:lastFrame)+eps;
                rightControlX = controllerData(3, firstFrame:lastFrame)+eps;
                rightControlY = -controllerData(4, firstFrame:lastFrame)+eps;% 50 is about the max speed 

                currHoopDronePosition = [currHoopDronePositionX; currHoopDronePositionY; currHoopDronePositionZ];
                currHoopPosition = [currHoopPositionX, currHoopPositionY, currHoopPositionZ];
                currHoopGazePosition = [currHoopGazePositionX; currHoopGazePositionY; currHoopGazePositionZ];
                currHoopSpeed = [currHoopSpeedX; currHoopSpeedY; currHoopSpeedZ];
                currHoopThrustVector = [currHoopDronePositionX+rightControlX*10; currHoopDronePositionZ+rightControlY*10];
                
                
                currNumFrames = length(firstFrame:lastFrame);
                collisionData = gazeAndPositionData.('Collision_Target');
                currCollisionData = collisionData(firstFrame:lastFrame);
                numberCollisions = findNumberCollisions(currCollisionData);
                collisions = ~cellfun(@isempty,currCollisionData);
                pathCurvature = findStraightPathSegments(currHoopDronePosition);
                
                gazeTargettemp = gazeAndPositionData.('RE_Gaze_Target');
                
                gazeTarget = gazeTargettemp(firstFrame:lastFrame);

                headingTargettemp = gazeAndPositionData.('RE_Heading_Target');
                headingTarget = headingTargettemp(firstFrame:lastFrame);
                
                horizontalGazeAngleSpeedVector = zeros(1,currNumFrames);
                horizontalGazeAngleThrustVector = zeros(1,currNumFrames);
                horizontalSpeedAngleThrustVector = zeros(1,currNumFrames);
                horizontalCameraSpeedVector = zeros(1,currNumFrames);
                horizontalCameraGazeVector = zeros(1,currNumFrames);
                vx = speedMag(1, firstFrame:lastFrame);
                vy = speedMag(2, firstFrame:lastFrame);
                vz = speedMag(3, firstFrame:lastFrame);
                
                if currNumFrames>10
                
                    for f=1:currNumFrames

                        horizontalGazeAngleSpeedVector(1,f) = calculateXCorrAngle(currHoopDronePosition([1,angleType],f)', ...
                            currHoopSpeed([1,angleType],f)', currHoopGazePosition([1,angleType],f)'); % Angle between heading and gaze

                        horizontalGazeAngleThrustVector(1,f) = calculateXCorrAngle(currHoopDronePosition([1,angleType],f)', ...
                            currHoopThrustVector(:,f)', currHoopGazePosition([1,angleType],f)'); % Angle between thrust and gaze

                        horizontalSpeedAngleThrustVector(1,f) = calculateXCorrAngle(currHoopDronePosition([1,angleType],f)', ...
                            currHoopThrustVector(:,f)', currHoopSpeed([1,angleType],f)'); % Angle between thrust and heading 

                        horizontalCameraSpeedVector(1,f) = calculateXCorrAngle([droneNorm2x(f) droneNorm2y(f)], ...
                            [droneNorm1x(f) droneNorm1y(f)], [droneNorm2x(f) droneNorm2y(f)] + [vx(f) vz(f)]); % Angle between thrust and heading 
                        horizontalCameraGazeVector(1,f) = calculateXCorrAngle([droneNorm2x(f) droneNorm2y(f)], ...
                            [droneNorm1x(f) droneNorm1y(f)], [droneNorm2x(f) droneNorm2y(f)] + currHoopGazePosition([1,angleType],f)'); % Angle between thrust and heading 
                
                    end
  
                 findZeroCrossings = @(v) find(v(:).*circshift(v(:), [-1 0]) <= 0); 
                 zIndices = findZeroCrossings(horizontalSpeedAngleThrustVector);
                 empMat = zeros(1,length(horizontalSpeedAngleThrustVector));
                 empMat(zIndices) = 1;
                 filterAvg = ones(1,5)/5;
                 zeroSmoothed = conv(empMat, filterAvg, 'same');
                 [~, maxZeroIndex] = max(zeroSmoothed);
                 dirChange = lastFrame - maxZeroIndex;
                 
                 
                 [rCH_GHall, lagCH_GHall, b, h] = crosscorr(horizontalGazeAngleSpeedVector,horizontalCameraSpeedVector, 'NumLags',numberOfLags); % camera heading - gaze heading
                 rCH_GHall = rCH_GHall((numberOfLags+1):end);
                 lagCH_GHall = lagCH_GHall((numberOfLags+1):end);
                 [~, indCH_GH] = max(abs(rCH_GHall));
                 rCH_GH = rCH_GHall(indCH_GH);
                 lagCH_GH = lagCH_GHall(indCH_GH);

                 [rTH_GHall, lagTH_GHall, b, h] = crosscorr( horizontalGazeAngleSpeedVector,horizontalSpeedAngleThrustVector, 'NumLags',numberOfLags); % thrust heading - gaze heading
                 rTH_GHall = rTH_GHall((numberOfLags+1):end);
                 lagTH_GHall = lagTH_GHall((numberOfLags+1):end);
                 [~, indTH_GH] = max(abs(rTH_GHall));
                 rTH_GH = rTH_GHall(indTH_GH);
                 lagTH_GH = lagTH_GHall(indTH_GH);
                 

                 [rTH_CHall, lagTH_CHall, b, h] = crosscorr(horizontalCameraSpeedVector, horizontalSpeedAngleThrustVector, 'NumLags',numberOfLags); % thrust heading - camera heading 
                 [~, indTH_CH] = max(abs(rTH_CHall));
                 rTH_CH = rTH_CHall(indTH_CH);
                 lagTH_CH = lagTH_CHall(indTH_CH);


                    if ~isreal(rCH_GH)
                        rCH_GH = NaN;
                    end

                    if ~isreal(rTH_GH)
                        rTH_GH = NaN;
                    end

                    if ~isreal(rTH_CH)
                        rTH_CH = NaN;
                    end
                else
                    rCH_GH = NaN;
                    rTH_GH = NaN;
                    rTH_CH = NaN;
                    lagCH_GH = NaN;
                    lagTH_GH = NaN;
                    lagTH_CH = NaN;
                end
                if createTimeseriesData
                    timeSequence = (length(firstFrame:lastFrame):-1:1)';
                    Sub = repelem(Subject, length(timeSequence))';
                    Cond = repelem(Condition, length(timeSequence))';
                    blck = block*ones(1, length(timeSequence))';
                    lapNum = lap*ones(1, length(timeSequence))';
                    hoopNumber = NaN*ones(1, length(timeSequence))';
                    headingHoopAngle = NaN*ones(1, length(timeSequence))';
                    gazeHeadingAngle = horizontalGazeAngleSpeedVector';
                    thrustHeadingAngle = horizontalSpeedAngleThrustVector';
                    gazeHoopAngle = NaN*ones(1, length(timeSequence))';
                    gazeNextHoopAngle = NaN*ones(1, length(timeSequence))';
                    headingNextHoopAngle = NaN*ones(1, length(timeSequence))';
                    throughHoopData = NaN*ones(1, length(timeSequence))';
                    cameraGaze = horizontalCameraGazeVector';
                    droneYaw = currHoopDroneOrientY';
                    leftControlX = leftControlX';
                    cameraHeading = horizontalCameraSpeedVector';
                    rateCameraHeading = calculateVelocity(cameraHeading, timeStamp(firstFrame:lastFrame));
                    %rateCameraHeading = gradient(cameraHeading)*60;
                    %plot(timeSequence, throughHoopData, 'ko')
                    gazeDistance = (sqrt(sum((currHoopGazePosition - currHoopDronePosition).^2, 1))./5)';
                    distanceToHoop =  NaN*ones(1, length(timeSequence))';
                    velX = speedMag(1, firstFrame:lastFrame)';
                    velY = speedMag(2, firstFrame:lastFrame)';
                    velZ = speedMag(3, firstFrame:lastFrame)';
                    
                    if prevDataFrameLogical == 0
                        prevDataFrame = table(Sub, Cond, blck, lapNum, hoopNumber, timeSequence, headingHoopAngle, gazeHeadingAngle, thrustHeadingAngle, ...
                            gazeHoopAngle, gazeNextHoopAngle, headingNextHoopAngle, throughHoopData, gazeTarget, distanceToHoop, headingTarget, cameraGaze, droneYaw, currCollisionData, gazeDistance, leftControlX, cameraHeading, velX, velY, velZ, rateCameraHeading, collisions);
                        prevDataFrameLogical = 1;
                    else
                        currDataFrame = table(Sub, Cond, blck, lapNum, hoopNumber, timeSequence, headingHoopAngle, gazeHeadingAngle, thrustHeadingAngle, ...
                            gazeHoopAngle, gazeNextHoopAngle, headingNextHoopAngle, throughHoopData, gazeTarget, distanceToHoop, headingTarget, cameraGaze, droneYaw, currCollisionData, gazeDistance, leftControlX, cameraHeading, velX, velY, velZ, rateCameraHeading, collisions);
                        prevDataFrame = [prevDataFrame; currDataFrame];
                    end

                else
                    
                    if prevDataFrameLogical == 0
                        prevDataFrame = table(Subject, Condition, block, lap, hoopNum, droneOrientXatHoop, droneOrientYatHoop, droneOrientZatHoop, ...
                            rTHp_GHp, lagTHp_GHp, rHHp_GHp, lagHHp_GHp, rGH_GHp, lagGH_GHp, rCH_GHp, lagCH_GHp, ...
                            rTH_GHp, lagTH_GHp, rGH_THp, lagGH_THp, rGH_HHp, lagGH_HHp, rTH_HHp, lagTH_HHp, rCH_GH, lagCH_GH, ...
                            rTH_GH, lagTH_GH, rTH_CH, lagTH_CH, rGT_GHp, lagGT_GHp, currHoopPositionX, currHoopPositionY, currHoopPositionZ, currHoopOrientX, ...
                            currHoopOrientY, currHoopOrientZ, nextHoopPositionX, nextHoopPositionY, nextHoopPositionZ, nextHoopOrientX, nextHoopOrientY, ...
                            nextHoopOrientZ, distanceToNextHoop, Direction, ApproachAngleY0, ApproachAngleY5, ApproachAngleY15, ApproachAngleY30, ApproachAngleY60, VisualAngleBetweenHoops, prevHoopVisualAngle, ...
                            distanceToHoopFirstGaze, timeBeforeReachingHoopFirstGaze, LAF, gazeDistanceToHoop, timeAfterPreviousHoopFirstGazeNextHoop, ...
                            timeBetweenHoops, LAFthroughHoop, pathCurvature, numberCollisions, prevSegmentCurvature, timeThroughHoop, dirChange, gazeThrustAtHoop, cameraRelToHoop0, cameraRelToHoop5, cameraRelToHoop15, cameraRelToHoop30, cameraRelToHoop60, ...
                            thrustHoopDiff0, thrustHoopDiff5, thrustHoopDiff15, thrustHoopDiff30, thrustHoopDiff60, hoopThrust0, hoopThrust5, hoopThrust15, hoopThrust30, hoopThrust60, ...
                        nextHoopThrust0, nextHoopThrust5, nextHoopThrust15, nextHoopThrust30, nextHoopThrust60, ApproachToNatNm1, AngularOffsetToNatNm1, ...
                        thrustNextHoop, headingNextHoop, thrustRelativeToHoopN, thrustRelativeToHoopN5, thrustRelativeToHoopN15, thrustRelativeToHoopN30, thrustRelativeToHoopN60, somethingWeirdWithApproach);
                        prevDataFrameLogical = 1;
                    else
                        currDataFrame = table(Subject, Condition, block, lap, hoopNum, droneOrientXatHoop, droneOrientYatHoop, droneOrientZatHoop, ...
                            rTHp_GHp, lagTHp_GHp, rHHp_GHp, lagHHp_GHp, rGH_GHp, lagGH_GHp, rCH_GHp, lagCH_GHp, ...
                            rTH_GHp, lagTH_GHp, rGH_THp, lagGH_THp, rGH_HHp, lagGH_HHp, rTH_HHp, lagTH_HHp, rCH_GH, lagCH_GH, ...
                            rTH_GH, lagTH_GH, rTH_CH, lagTH_CH, rGT_GHp, lagGT_GHp, currHoopPositionX, currHoopPositionY, currHoopPositionZ, currHoopOrientX, ...
                            currHoopOrientY, currHoopOrientZ, nextHoopPositionX, nextHoopPositionY, nextHoopPositionZ, nextHoopOrientX, nextHoopOrientY, ...
                            nextHoopOrientZ, distanceToNextHoop, Direction, ApproachAngleY0, ApproachAngleY5, ApproachAngleY15, ApproachAngleY30, ApproachAngleY60, VisualAngleBetweenHoops, prevHoopVisualAngle,...
                            distanceToHoopFirstGaze, timeBeforeReachingHoopFirstGaze, LAF, gazeDistanceToHoop, timeAfterPreviousHoopFirstGazeNextHoop, ...
                            timeBetweenHoops, LAFthroughHoop, pathCurvature, numberCollisions, prevSegmentCurvature, timeThroughHoop, dirChange, gazeThrustAtHoop, cameraRelToHoop0, cameraRelToHoop5, cameraRelToHoop15, cameraRelToHoop30, cameraRelToHoop60, ...
                            thrustHoopDiff0, thrustHoopDiff5, thrustHoopDiff15, thrustHoopDiff30, thrustHoopDiff60, hoopThrust0, hoopThrust5, hoopThrust15, hoopThrust30, hoopThrust60, ...
                        nextHoopThrust0, nextHoopThrust5, nextHoopThrust15, nextHoopThrust30, nextHoopThrust60, ApproachToNatNm1, AngularOffsetToNatNm1, ...
                        thrustNextHoop, headingNextHoop, thrustRelativeToHoopN, thrustRelativeToHoopN5, thrustRelativeToHoopN15, thrustRelativeToHoopN30, thrustRelativeToHoopN60, somethingWeirdWithApproach);
                         prevDataFrame = [prevDataFrame; currDataFrame];
                    end
                    prevSegmentCurvature = pathCurvature;
                end
           end
           
           
        
        
        
    end
    
    
    dTable = prevDataFrame;
    
    %prevthrustMat = prevthrustMat';
    %prevheadingGazeMat = prevheadingGazeMat';
    %prevVDmat = prevVDmat';
    %prevHeadingHoopMat = prevHeadingHoopMat';
    
    %angleTable = table(prevthrustMat, prevheadingGazeMat, prevVDmat, prevHeadingHoopMat);
    %angleTable = angleTable(1:size(positionData,2), :);
    %writetable(angleTable, 'angleDataForSubject.txt');

end


function buildAngleTable(positionData, hoopData, obstacleData)
    angleType = 3;
    
        for f=1:currNumFrames
            horizontalVisualAngleGazeAndHoop(1,f) = calculateAngle(currHoopDronePosition([1,angleType],f)', ...
                currHoopPosition([1,angleType]), currHoopGazePosition([1,angleType],f)');
            %% Unsure about these two being correct
            horizontalVisualAngleSpeedVector(1,f) = calculateAngle(currHoopDronePosition([1,angleType],f)', ...  % This one is the angle between heading and hoop position relative to the drone
                currHoopPosition([1,angleType]), currHoopSpeed([1,angleType],f)');
            horizontalGazeAngleSpeedVector(1,f) = calculateAngle(currHoopDronePosition([1,angleType],f)', ...
                currHoopSpeed([1,angleType],f)', currHoopGazePosition([1,angleType],f)');
            
            horizontalGazeAngleThrustVector(1,f) = calculateAngle(currHoopDronePosition([1,angleType],f)', ...
                currHoopThrustVector(:,f)', currHoopGazePosition([1,angleType],f)');
        
        
        end


end


% function distance = differenceBetweenHoopAndGazeDistances(gazeData, hoopPosition)
%     %% Must make sure that the input to this function have the drone position removed or taken into account. 
%      
%     magHoopVector = sqrt(sum(hoopPosition.^2));
%     
%     distance = magGazeVector - magHoopVector;
% 
% end

function distance = findAverageDistanceBetweenHoops(hoopPosition)

    distanceTemp = zeros(size(hoopPosition,2)-1,1);
    
    for i=2:length(distanceTemp)
        
        Hoop1x = hoopPosition(1,i);
        Hoop1y = hoopPosition(2,i);
        Hoop1z = hoopPosition(3,i);
        
        Hoop2x = hoopPosition(1,i-1);
        Hoop2y = hoopPosition(2,i-1);
        Hoop2z = hoopPosition(3,i-1);
        
        x = (Hoop1x - Hoop2x)^2;
        y = (Hoop1y - Hoop2y)^2;
        z = (Hoop1z - Hoop2z)^2;
        
        
        distanceTemp(i-1,1) = sqrt(x + y + z);
        
    end

    distance = mean(distanceTemp)/5;
    variance = std( distanceTemp/.5 ) / sqrt( length( distanceTemp ));
end






function numberCollisions = findNumberCollisions(collisionData)

    numberCollisions = 0;
    for i=1:length(collisionData)
        
        if ~isempty(collisionData(i))
            numberCollisions = numberCollisions + 1;
        end
        
    end

end

function ThroughHoop = FindTimeThroughHoop(collisionData)

    ThroughHoop = 0;
    for i=1:length(collisionData)
        collisionData(i);
        if ~isempty(collisionData{i})
            ThroughHoop = ThroughHoop + 1;
        end
        
    end
    ThroughHoop = ThroughHoop/length(collisionData);

end

function output = findAvgRateOfChange(vector, start, endpt)

    numFrames = length(start:endpt);
    dt = 0;
    for i=(start+1):endpt

        currdt = vector(i-1) - vector(i);
        
        dt = dt + currdt;
        
    end
    
    output = dt/numFrames;

end
