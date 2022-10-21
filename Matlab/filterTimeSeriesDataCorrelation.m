function filterTimeSeriesDataCorrelation()


    tsDF = readtable('timeSeriesHoopSegmentAngles_allSubjects_2Seconds.txt', 'delimiter', ',');
    orientationData = readtable('droneOrientationDataset120SecondCrossCorrelations_leaveOut_oldGazeTarget.txt', 'delimiter', ',');
    
    visualAngleList =orientationData.('VisualAngleBetweenHoops');
    hoopList = orientationData.('hoopNum');
    combinedHoopAngle = [hoopList, abs(visualAngleList)];
    
    highCurveHoopsList = unique(combinedHoopAngle(combinedHoopAngle(:,2)<100))';
    
    subjectDataSets = { 'P_211013154622_50', 'P_210930142529_100', 'P_210928152127_40',  'P_220207122313_Nate'};
    %subjectDataSets = {'P_210930142529_100'};% 'P_210929172928_200_300', 'P_211015152112_10'};
    conditions = {'PathAndHoops', 'HoopOnly'};
    %conditions = {'/PathAndHoops/'};
    hoopFolder = 'HoopFiles/';
    %positionFolder = 'FinalPositions/';
    positionFolder = 'Output_positionFiles/';
   
    %hoopPositionData = getObstacleData('obstacle_data.txt');
    %hoopPositionData = getObstacleData('gateOrientationNormalizedPointsDataset.txt');
    runSlidingCorrelation = true;
    dfLogical = 0;
    
    currentDF = cell(1, 1000000);
    visAngleList = zeros(1, 1000000);
    gazeDistance = zeros(1, 1000000);
    distanceRotationCorr = zeros(1, 1000000);
    ind = 1;
    
    totalCorr = zeros(1, 1000000);
    
    meanTimeCounts = ones(3000, 121)*NaN;
    sumCorr = ones(3000,121)*NaN;
    
    for sb = subjectDataSets
        Subject = sb;
        sb = strcat('Experiment1/', sb(1));
        subData = tsDF(strcmp(tsDF.('Sub'), sb), :);
        for cnd = conditions
            cnd
            %hoopFolderPath = strcat(sb{:}, cnd{:}, hoopFolder);
            positionFolderPath = strcat(sb{:}, cnd{:}, positionFolder);
            
            %hoopFolderInfo = dir(fullfile(hoopFolderPath, '*.txt'));
            %hoopFolderNames = hoopFolderInfo.name;
            
            positionFolderInfo = dir(fullfile(positionFolderPath, '*.txt'));
            
            condData = subData(strcmp(subData.('Cond'), cnd(1)) , :);
            
            for b=1:4
                blockData = condData(condData.('blck')==b, :);
                for hoop = highCurveHoopsList(2:end-1)
                    hoop;
                    hoopData = blockData(blockData.('hoopNumber')==hoop, :);
                    hoopOrientData = orientationData(orientationData.('hoopNum')==hoop, :);
                    currVisAngle = mean(hoopOrientData.('VisualAngleBetweenHoops'));
                    
                   
                    
                    if runSlidingCorrelation
                        windowSize = 10;
                        startFrame = windowSize/2;
                        thrust = calculateDerivative(hoopData.('cameraGaze'));
                        gaze = calculateDerivative(hoopData.('droneYaw'));
                        gazeDistance = hoopData.('gazeDistance');
                        slidingCorr = zeros(1, length(thrust))*NaN;
                        
                        totalCorr(ind) = corr(thrust, gaze);
                        
                        numCollisions = findNumberCollisions(hoopData.('currCollisionData'));
                         if numCollisions<10000
                        
                            if dfLogical == 0
                                for t=startFrame:(length(gaze)-windowSize/2)
                                    start = t-(windowSize/2)+1;
                                    endStep = t+(windowSize/2);

                                    slidingCorr(t) = corr(thrust(start:endStep), gaze(start:endStep));
                                    
                                end
%                                 gazeThroughHoop = hoopData.('throughHoopData');
%                                 hoopIndices = gazeThroughHoop; %findHoopIndices(gazeThroughHoop);
%                                 hoopIndices = (1:length(slidingCorr)) .* gazeThroughHoop';
%                                 noZerosIndices = hoopIndices(hoopIndices~=0);
%                                 slidingCorr = slidingCorr(noZerosIndices);
                                currentDF{ind} = slidingCorr;
                                if ~isempty(slidingCorr)
                                    visAngleList(ind) = currVisAngle;
                                    %gazeData = [hoopData, hoopData, hoopData]
                                    %gazeDistance(ind) = sqrt(sum(gazeData.^2));
                                    distanceRotationCorr(ind) = corr(slidingCorr', gazeDistance, 'rows','complete');
                                    sumCorr(ind, 1:length(slidingCorr)) = slidingCorr;
                                    meanTimeCounts(ind, 1:length(slidingCorr)) = 1:length(slidingCorr);
                                end
                                
                                
                                
                                dfLogical=1;
                            else
                                for t=startFrame:(length(gaze)-windowSize/2)
                                    start = t-(windowSize/2)+1;
                                    endStep = t+(windowSize/2);

                                    slidingCorr(t) = corr(thrust(start:endStep), gaze(start:endStep));
                                    
                                end

%                                 gazeThroughHoop = hoopData.('throughHoopData');
% 
%                                 hoopIndices = gazeThroughHoop; %findHoopIndices(gazeThroughHoop);
%                                 hoopIndices = (1:length(slidingCorr)) .* gazeThroughHoop;
%                                 noZerosIndices = hoopIndices(hoopIndices~=0);
%                                 slidingCorr = slidingCorr(noZerosIndices);

                                currentDF{ind} = slidingCorr;
                                if ~isempty(slidingCorr)
                                    visAngleList(ind) = currVisAngle;
                                    distanceRotationCorr(ind) = corr(slidingCorr', gazeDistance, 'rows','complete');
                                    sumCorr(ind, 1:length(slidingCorr)) = slidingCorr;
                                    meanTimeCounts(ind, 1:length(slidingCorr)) = 1:length(slidingCorr);
                                end
    %                             DF = slidingCorr;
    %                             
    %                             DF(DF==0) = NaN;
    %                             
    %                             currentDF = [currentDF; DF];
                            end  
                         end
                         ind = ind  + 1;
                    else
                        if dfLogical == 0
                            currentDF = [hoopData.('thrustHeadingAngle'); hoopData.('gazeHeadingAngle')]';
                            dfLogical=1;
                        else
                            DF = [hoopData.('thrustHeadingAngle'); hoopData.('gazeHeadingAngle')]';
                            currentDF = [currentDF; DF];
                        end
                    end
                    
                end
            
            end
            
        end
        
        
    end

     currentDF = currentDF(~cellfun('isempty',currentDF));
     visAngleList = visAngleList(visAngleList~=0);
     distanceRotationCorr = distanceRotationCorr(distanceRotationCorr~=0);
     
     averageCorr = zeros(1, length(currentDF));
     for c=1:length(currentDF)
%          hold on;
%          plot(currentDF{c})
%          hold off
         
         averageCorr(c) = nanmean(currentDF{c});
         
     end
     
     %averageCorr = averageCorr/length(currentDF);
%      plot(abs(visAngleList), averageCorr, 'ko')
%      hold on;
%      lsline;
%      hold off
    totalCorr = totalCorr(totalCorr~=0);
    histogram(totalCorr)
    %meanTimeCounts(meanTimeCounts==0) = NaN;
    %sumCorr(sumCorr==0) = NaN;
    meanCorr = nanmean(sumCorr, 1);
    meanCorr = meanCorr(~isnan(meanCorr));
    meanCorrTim = -(1:length(meanCorr(~isnan(meanCorr))))/60;
    figure(2);
    plot(meanCorrTim, meanCorr, 'ko');
    xlim([-2, 0])

    
    %plot(meanCorr);
    xlabel('Time (frames)')
    ylabel('Correlation')
    title('Sliding Window Correlation (Averaged) - Gaze & Yaw Rates')
    
    

    lags = meanTimeCounts;
    corr2 = sumCorr;

    pts1 = linspace(0, 2, 50);
    pts2 = linspace(-1, 1, 50);
    N = histcounts2(corr2(:), lags(:), pts2, pts1);
    
    imagesc(pts1, pts2, N);
        %axis equal;
        %set(gca, 'XLim', pts1([1 end]), 'YLim', pts2([1 end]), 'YDir', 'normal');
    %xline(90, 'k--')
%     %[coeff,score,latent,tsquared,explained,mu] = pca(currentDF');
%     
%     %explained
% 
%     %plot(score(1:121, :))
%     
%     %hold on;
%     plot(score(1:121, 1), score(1:121, 2), 'ko')
%     %hold off
%     
%     hold on;
%     plot(score(122:end, 1), score(122:end, 2), 'ro')
%     hold off;
    
    %legend('Comp 1 - Thrust','Comp 2 - Thrust','Comp 3 - Thrust','Comp 1 - Gaze','Comp 2 - Gaze','Comp 3 - Gaze')
    
    
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

function numberCollisions = findNumberCollisions(collisionData)

    numberCollisions = 0;
    for i=1:length(collisionData)
        
        if ~isempty(collisionData{i})
            numberCollisions = numberCollisions + 1;
        end
        
    end

end

function dx = calculateDerivative(x)

    dx = zeros(length(x),1);
    
    for i=2:length(x)
       
        dx(i,1) = x(i) - x(i-1);
        
    end


end
