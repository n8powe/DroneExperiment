function pathComponents = readPathOutline()

    currPositionFile = 'pathpositiondata.txt';
    posData = readtable(currPositionFile, 'delimiter', ',','ReadVariableNames', true, 'PreserveVariableNames', true);

    pathX = posData.('pathX');
    pathY = posData.('pathY');
    pathZ = posData.('pathZ');
    
    
    plot(pathX, pathZ, 'b-')
    
    
    pathComponents = [pathX, pathY, pathZ];

end