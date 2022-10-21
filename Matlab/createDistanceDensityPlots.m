function createDistanceDensityPlots()


    subjectDataSets = {'P_210930142529_100', 'P_211013154622_50', 'P_211015152112_10', 'P_210929172928_200_300', 'P_210928152127_40', 'P_220207122313_Nate'};
    % subjectDataSets = {'P_211013154622_50'};
    conditions = {'/PathAndHoops/', '/HoopOnly/', '/PathOnly/'};
    %conditions = {'/PathOnly/'};
    hoopFolder = 'HoopFiles/';
    positionFolder = 'Output_positionFiles/';
    fontSize = 18;
    
    plotByCondition = true;
    
    plotAverageDensity = true;
    
    totalDensityVector = 0;
    totalNumDensities = 0;
    
    alphaLevel = 0.33;
    
    allDensities = [];
    phDensities = [];
    hDensities = [];
    pDensities = [];
    
    avgDistancesPH = [];
    avgDistancesH = [];
    avgDistancesP = [];
    
    avgDistances = [];
    Subject = [];
    Condition = []
    Block = [];
    
    figure(1);
    for sb = subjectDataSets
        sb = strcat('Experiment1/', sb(1))
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
                totalNumDensities = totalNumDensities + 1;
                currHoopFile = strcat(hoopFolderPath, hoopFolderInfo(b).name);
                currPositionFile = strcat(positionFolderPath, positionFolderInfo(b).name);
                if strcat(positionFolder, 'FinalPositions/')
                    posData = readtable(currPositionFile, 'delimiter', ',','ReadVariableNames', true, 'PreserveVariableNames', true);
                else
                    posData = readtable(currPositionFile, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true);
                end
                hoopData = readtable(currHoopFile, 'delimiter', '\t','ReadVariableNames', true, 'PreserveVariableNames', true);
                
                distances = findGazeDistanceMag(posData);
                pts = linspace(0,50,200); % points to evaluate the estimator
                
                avgDistances = [avgDistances; mean(distances)];
                Subject = [Subject; sb];
                Condition = [Condition; cnd];
                Block = [Block; b];
                
                
                subplot(2,3,2)
                hold on;
                
                [f_all, x_all] = ksdensity(distances,pts);
                s = plot(x_all, f_all, 'k');
                s.Color(4) = alphaLevel;
                hold off;

                totalDensityVector = totalDensityVector + f_all;
                allDensities = [allDensities; f_all];


                if strcmp(cnd, '/PathAndHoops/')
                    subplot(2,3,4)
                    [fPH, xPH] = ksdensity(distances,pts);
                    phDensities = [phDensities; fPH];
                    hold on;
                    sPH = plot(xPH,fPH, 'k');
                    sPH.Color(4) = alphaLevel;
                    hold off;
                    
                    avgDistancesPH = [avgDistancesPH, mean(distances)];
                    
                elseif strcmp(cnd, '/HoopOnly/')
                    subplot(2,3,5)
                    [fH, xH] = ksdensity(distances,pts);
                    hDensities = [hDensities; fH];
                    hold on;
                    
                    sH = plot(xH,fH, 'k');
                    sH.Color(4) = alphaLevel;
                    hold off;
                    avgDistancesH = [avgDistancesH, mean(distances)];
                    
                else
                    subplot(2,3,6)
                    [fP, xP] = ksdensity(distances,pts);
                    pDensities = [pDensities; fP];
                    hold on;
                    
                    sP = plot(xP,fP, 'k');
                    sP.Color(4) = alphaLevel;
                    hold off;
                    
                    avgDistancesP = [avgDistancesP, mean(distances)];
                end
                    
                
                %histogram(distances,'Normalization','pdf')
            
            end
            
        end
        
        
    end
    
    
    if plotAverageDensity
        
        pts = linspace(0,50,200); % points to evaluate the estimator
        
        stdDevDen = std(allDensities);
        
        % Need average Density 
        avgDensity = totalDensityVector./totalNumDensities;
        
        
        inBetween = [avgDensity+stdDevDen; avgDensity-stdDevDen];
        subplot(2,3,2)
        hold on;
        plot(pts, avgDensity+stdDevDen, 'r', 'LineWidth', 2);
        %shade(pts,avgDensity-stdDevDen,pts,avgDensity+stdDevDen,'FillType',[1 2;2 1]);
        hold off;
        
        hold on;
        plot(pts, avgDensity-stdDevDen, 'r', 'LineWidth', 2);
        hold off;
        
        hold on;
        plot(pts, avgDensity, 'y', 'LineWidth', 3);
        hold off;
        title('Gaze Distance Density - All','fontsize',fontSize)
        xlabel('Distance (m)','fontsize',fontSize)
        ylabel('P','fontsize',fontSize)
        %ylim([-0.005, 0.05])
        %legend('','Mean','Std.')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        stdDevDenPH = std(phDensities);
        
        % Need average Density 
        avgDensityPH = mean(phDensities,1);
        subplot(2,3,4)
        hold on;
        plot(pts, avgDensityPH+stdDevDenPH, 'r', 'LineWidth', 1.5);
        %shade(pts,avgDensity-stdDevDen,pts,avgDensity+stdDevDen,'FillType',[1 2;2 1]);
        hold off;
        
        hold on;
        plot(pts, avgDensityPH-stdDevDenPH, 'r', 'LineWidth', 1.5);
        hold off;
        
        hold on;
        plot(pts, avgDensityPH, 'y', 'LineWidth', 1.8);
        hold off;
        title('Gaze Distance Density - Path and Hoops','fontsize',fontSize)
        xlabel('Distance (m)','fontsize',fontSize)
        ylabel('P','fontsize',fontSize)
        %ylim([-0.005, 0.05])
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        stdDevDenH = std(hDensities);
        
        % Need average Density 
        avgDensityH = mean(hDensities,1);
        subplot(2,3,5)
        hold on;
        plot(pts, avgDensityH+stdDevDenH, 'r', 'LineWidth', 1.5);
        %shade(pts,avgDensity-stdDevDen,pts,avgDensity+stdDevDen,'FillType',[1 2;2 1]);
        hold off;
        
        hold on;
        plot(pts, avgDensityH-stdDevDenH, 'r', 'LineWidth', 1.5);
        hold off;
        
        hold on;
        plot(pts, avgDensityH, 'y', 'LineWidth', 1.8);
        hold off;
        title('Gaze Distance Density - Hoop Only','fontsize',fontSize)
        xlabel('Distance (m)','fontsize',fontSize)
        ylabel('P','fontsize',fontSize)
        %ylim([-0.005, 0.05])
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        stdDevDenP = std(pDensities);
        
        % Need average Density 
        avgDensityP = mean(pDensities,1);
        subplot(2,3,6)
        hold on;
        plot(pts, avgDensityP+stdDevDenP, 'r', 'LineWidth', 1.5);
        %shade(pts,avgDensity-stdDevDen,pts,avgDensity+stdDevDen,'FillType',[1 2;2 1]);
        hold off;
        
        hold on;
        plot(pts, avgDensityP-stdDevDenP, 'r', 'LineWidth', 1.5);
        hold off;
        
        hold on;
        plot(pts, avgDensityP, 'y', 'LineWidth', 1.8);
        hold off;
        title('Gaze Distance Density - Path Only','fontsize',fontSize)
        xlabel('Distance (m)', 'fontsize',fontSize)
        ylabel('P','fontsize',fontSize)
        %ylim([-0.005, 0.05])
    end
    
    figure(1000);
    
    mPH = mean(avgDistancesPH);
    mH = mean(avgDistancesH);
    mP = mean(avgDistancesP);
    
   
    
    plot([1,2,3], [mPH, mH, mP], 'ko')
   
    
    df = table(Subject, Block, Condition, avgDistances);
    
    writetable(df, 'avgGazeDistancesData.txt')
    
end


function gd = findGazeDistanceMag(gazeData)

    x = gazeData.('Position(x)') - gazeData.('RE_Gaze_Pos(x)');
    y = gazeData.('Position(y)') - gazeData.('RE_Gaze_Pos(y)');
    z = gazeData.('Position(z)')  - gazeData.('RE_Gaze_Pos(z)');
    
    %x = gazeData.('Position(x)') - gazeData.('Gaze_Location(x)');
    %y = gazeData.('Position(y)') - gazeData.('Gaze_Location(y)');
    %z = gazeData.('Position(z)')  - gazeData.('Gaze_Location(z)');

    gd = sqrt(x.^2 + y.^2 + z.^2)/5;


end




