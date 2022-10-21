function addHoopGazeBoolToVideo()
    currPositionFile = 'Experiment1/P_210930142529_100/PathAndHoops/Output_PositionFiles/RECON_final_positionfile_drone_capture_P_210930142529_100_4_GatedPath.txt';
    posData = readtable(currPositionFile, 'delimiter', ',','ReadVariableNames', true, 'PreserveVariableNames', true);
    
    vidReader = VideoReader('FPScene_GC_.mp4');
    throughHoopData = posData.('Gaze_Through_Gate');
    f = 1;
    
    v3 = VideoWriter('gazeThroughHoopBool', 'MPEG-4');
    v3.FrameRate = 60;
    open(v3);
    fig = figure(1);
    fig.Position = [10 10 1000 1000];
    while hasFrame(vidReader)
        
        currThroughHoop = throughHoopData{f};
        if isempty(currThroughHoop)
           through = 0;
            
        else
           through = 1;
            
        end
        
        
        frame = readFrame(vidReader);
        
        imshow(frame);
        
        if through==1
           hold on;
           title('Gaze Through Hoop')
           hold off;
        else
            hold on;
            title('')
            hold off;
            
        end
        
        drawnow
        
        gcf = getframe(fig);
        writeVideo(v3, gcf);
        
        f = f+ 1;
    end
    close(v3);

end