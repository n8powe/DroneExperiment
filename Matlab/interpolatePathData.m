function interpolatePathData()

    currPositionFile = 'pathData.txt';
    posData = readtable(currPositionFile, 'delimiter', ',','ReadVariableNames', true, 'PreserveVariableNames', true);
    
    x = posData.Position_x;
    y = posData.Position_y_Path;
    z = posData.Position_z;
    prevXYZ = [];
    
    for i=1:69
        
        pt1x = x(i);
        pt1y = y(i);
        pt1z = z(i);

        
        if i==69
            pt2x = x(1);
            pt2y = y(1);
            pt2z = z(1);
        else
            
            pt2x = x(i+1);
            pt2y = y(i+1);
            pt2z = z(i+1);
        end
        
        interpX = linspace(pt1x, pt2x, 500);
        interpY = linspace(pt1y, pt2y, 500);
        interpZ = linspace(pt1z, pt2z, 500);
        
        XYZ  = [interpX; interpY; interpZ]';
        
        prevXYZ = [prevXYZ; XYZ];
        
    end
    
    pathX = prevXYZ(:,1);
    pathY = prevXYZ(:,2);
    pathZ = prevXYZ(:,3);

    
    pathPositionTable = table(pathX, pathY, pathZ);
    
    writetable(pathPositionTable, "pathpositiondata.txt");

end