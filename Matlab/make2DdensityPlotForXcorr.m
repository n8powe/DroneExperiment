function make2DdensityPlotForXcorr()

        DF = readtable('droneOrientationDataset120SecondCrossCorrelations_leaveOut.txt', 'delimiter', ',');
        
        lags = DF.lagTH_GH/60;
        corr = DF.rTH_GH;
        
        pts1 = linspace(0, 0.5, 20);
        pts2 = linspace(-1, 1, 20);
        N = histcounts2(corr(:), lags(:), pts2, pts1);

        % Plot scattered data (for comparison):
        subplot(1, 2, 1);
        scatter(lags, corr, 'r.');
        axis equal;
        set(gca, 'XLim', pts1([1 end]), 'YLim', pts2([1 end]));

        % Plot heatmap:
        subplot(1, 2, 2);
        imagesc(pts1, pts2, N);
        %axis equal;
        %set(gca, 'XLim', pts1([1 end]), 'YLim', pts2([1 end]), 'YDir', 'normal');



end