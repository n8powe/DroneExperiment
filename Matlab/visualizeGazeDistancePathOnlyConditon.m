function visualizeGazeDistancePathOnlyConditon()

    %subjectDataSets = {'P_211015152112_10', 'P_211013154622_50', 'P_210930142529_100', 'P_210929172928_200_300', 'P_210928152127_40',  'P_220207122313_Nate'};
    subjectDataSets = { 'P_210930142529_100',  'P_220207122313_Nate', 'P_211013154622_50'};
    %conditions = {'/PathOnly/'};
    conditions = {'/PathAndHoops/'};
    hoopFolder = 'HoopFiles/';
    %positionFolder = 'FinalPositions/';
    positionFolder = 'Output_positionFiles/';
   
    %hoopPositionData = getObstacleData('obstacle_data.txt');
    %hoopPositionData = getObstacleData('gateOrientationNormalizedPointsDataset.txt');
    runSlidingCorrelation = true;
    dfLogical = 0;
    
    for sb = subjectDataSets
        Subject = sb;
        sb = strcat('Experiment1/', sb(1));
        
        for cnd = conditions
            cnd
            %hoopFolderPath = strcat(sb{:}, cnd{:}, hoopFolder);
            positionFolderPath = strcat(sb{:}, cnd{:}, positionFolder);
            
            %hoopFolderInfo = dir(fullfile(hoopFolderPath, '*.txt'));
            %hoopFolderNames = hoopFolderInfo.name;
            
            positionFolderInfo = dir(fullfile(positionFolderPath, '*.txt'));
            
            
            
            for b=1:5
                currPositionFile = strcat(positionFolderPath, positionFolderInfo(b).name);
                posData = readtable(currPositionFile, 'delimiter', ',','ReadVariableNames', true, 'PreserveVariableNames', true);
                dronePosX = posData.('Position(x)');
                dronePosY = posData.('Position(y)');
                dronePosZ = posData.('Position(z)');
                
                gazePosX = posData.('RE_Gaze_Pos(x)');
                gazePosY = posData.('RE_Gaze_Pos(y)');
                gazePosZ = posData.('RE_Gaze_Pos(z)');
                
                gazeDistance = sqrt( (dronePosX-gazePosX).^2 + (dronePosY - gazePosY).^2 + (dronePosZ - gazePosZ).^2 )/5;
                
                gazeTargets = posData.('RE_Gaze_Target');
                gazeThroughHoop = posData.('RE_Gaze_Thru_Gate');
                
                hoopIndices = findHoopIndices(gazeThroughHoop);
                pathBoolean = strcmp(gazeTargets, 'PathOutline');
                    
                gazeDistanceVisualize = gazeDistance .* hoopIndices';
                
                rightControlX = posData.('Right_X')*100;
                
                rightControlXVisualize = rightControlX .* hoopIndices;
                
                gazeDistanceVisualize(gazeDistanceVisualize==0) = NaN;
                rightControlXVisualize(rightControlXVisualize==0)= NaN;
                plot(gazeDistanceVisualize)
                
                hold on;
                plot(rightControlXVisualize)
                hold off;
                
                xlabel('frame')
                ylabel('Gaze Distance')
                title('Gaze Distance to Path')
            
            end
            
        end
        
        
    end

end

function hoopIndices = findHoopIndices(gazeTargets)
    
    hoopIndices = zeros(1, length(gazeTargets));

    for i=1:length(gazeTargets)
        currTarget = gazeTargets(i);
        splitString = split(currTarget, ' ');
        
        if strcmp(splitString(1), 'RoundGate')
            hoopIndices(i) = 1;
        end
        
        
    end



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
