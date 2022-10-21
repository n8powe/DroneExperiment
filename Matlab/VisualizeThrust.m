function VisualizeThrust()
    

    currPositionFile = 'stackedData.txt';
    posData = readtable(currPositionFile, 'delimiter', ',','ReadVariableNames', true, 'PreserveVariableNames', true);
    
    numFrames = size(posData,1);
    currHoopGazePositionX = posData.('RE_Gaze_Pos(x)');
    currHoopGazePositionZ = posData.('RE_Gaze_Pos(z)');
    currHoopDronePositionX = posData.('Position(x)');
    currHoopDronePositionZ = posData.('Position(z)');
    rightControlX = posData.('Right_X');
    rightControlY = posData.('Right_Y');
    timeStamp = posData.Timestamp;
    currHoopDroneOrientY = posData.('Orientation(y)');
    dDronePosX = calculateVelocity(currHoopDronePositionX, timeStamp)*10;
    %dDronePosY = calculateVelocity(dronePosY, timeStamp)*headingModfier;
    dDronePosZ = calculateVelocity(currHoopDronePositionZ, timeStamp)*10;
    currHoopSpeed = [dDronePosX, dDronePosZ];
    
    ThrustAngle = zeros(1,numFrames)*NaN;
    GazeAngle =  zeros(1,numFrames)*NaN;
    GazeThrustAngle = zeros(1,numFrames)*NaN;
    frameOneIndices = find(posData.Frame==1);
    dDronePosX(frameOneIndices) = 0;
    dDronePosZ(frameOneIndices) = 0;

    currHoopThrustVectorUnrotated = [currHoopDronePositionX+rightControlX*20, currHoopDronePositionZ+rightControlY*20];
    currHoopDronePosition = [currHoopDronePositionX, currHoopDronePositionZ];
    currHoopGazePosition = [currHoopGazePositionX, currHoopGazePositionZ];
    currHoopThrustVector = rotateThrustVectorAroundDrone(currHoopThrustVectorUnrotated, currHoopDronePosition, currHoopDroneOrientY);

    for f=1:numFrames
        ThrustAngle(1,f) = calculateXCorrAngle(currHoopDronePosition(f,:), ...
            currHoopThrustVector(:,f)', currHoopSpeed(f, :)); % Angle between thrust and heading 
        

        GazeAngle(1,f) = calculateXCorrAngle(currHoopDronePosition(f, :), ...
            currHoopGazePosition(f, :), currHoopSpeed(f, :)); % Angle between heading and gaze

        GazeThrustAngle(1,f) = calculateXCorrAngle(currHoopDronePosition(f,:), ...
            currHoopThrustVector(:,f)', currHoopGazePosition(f, :)); % Angle between thrust and gaze
 
        
        
    end

    posData.ThrustAngle = ThrustAngle';
    posData.GazeAngle = GazeAngle';
    posData.GazThrustAngle = GazeThrustAngle';
    
    writetable(posData, 'stackedDataWithThrustAngle.txt');
    
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

function d = getObstacleData(name)

    if strcmp(name, 'obstacle_data.txt')
        d = readtable(name, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true, 'HeaderLines', 0);
    else
        d = readtable(name, 'delimiter', ',','ReadVariableNames', true, 'PreserveVariableNames', true, 'HeaderLines', 0);
    end
        

end


function rVector = rotateThrustVectorAroundDrone(currHoopThrustVector, currHoopDronePosition, currHoopDroneOrientY)
        
        x = currHoopDronePosition(:,1);
        z = currHoopDronePosition(:,2);
        
        thrustX = currHoopThrustVector(:,1);
        thrustZ = currHoopThrustVector(:,2);
        
        numFrames = length(x);
        droneWidth = 2;
        rVector = zeros(2,numFrames);
        
        for i=1:numFrames

            %orientX = eulerAngles(3);%*(pi/180);
            orientY = -(currHoopDroneOrientY(i)*pi/180);%abs(eulerAngles(2));%*(pi/180);
            %orientZ = eulerAngles(1);%*(pi/180);

            p1x = thrustX(i);
            p1y = thrustZ(i);



            rotatedp1x = (p1x - x(i))*cos(orientY) - (p1y - z(i))*sin(orientY) + x(i);
            rotatedp1y = (p1x - x(i))*sin(pi-orientY) - (p1y - z(i))*cos(pi-orientY) + z(i);

            
            
            rVector(1,i) = rotatedp1x;
            rVector(2,i) = rotatedp1y;


            
%             plot([p1x ],[p1y ], 'bo')
%             hold on;
%             plot([ p2x],[ p2y], 'go')
%             hold off;
%             
%             hold on;
%             plot([rotatedp1x rotatedp2x],[rotatedp1y rotatedp2y],'ro')
%             hold off;
%             hold on;
%             plot(x(i), z(i), 'ko')
%             hold off;
%             xlim([min(currHoopDronePositionX)-10, max(currHoopDronePositionX)+10])
%             ylim([min(currHoopDronePositionZ)-10, max(currHoopDronePositionZ)+10])
%             drawnow;
        end
        %rVector = currHoopDronePosition([1,3],:) + rVector;
end

function dx = calculateVelocity(x, t)

    dx = zeros(length(x),1);
    
    for i=2:length(x)
       
        dx(i,1) = (x(i) - x(i-1))/(t(i)-t(i-1));
        
    end


end