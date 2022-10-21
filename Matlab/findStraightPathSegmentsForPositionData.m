function proportionDistance = findStraightPathSegmentsForPositionData(positionData)
    


    numFrames = size(positionData,1);
    
    xv = positionData(1,:);
    yv = positionData(2,:);
    zv = positionData(3,:);
    
    
    x1 = xv(1);
    y1 = yv(1);
    z1 = zv(1);

    xend = xv(end);
    yend = yv(end);
    zend = zv(end);

    straightDistance = sqrt((x1-xend)^2 + (y1-yend)^2 + (z1-zend)^2);

    actualDistance = findPathLength(xv, yv, zv);

    proportionDistance = straightDistance/actualDistance;
        

    
end

function totalL = findPathLength(componentX, componentY, componentZ)
    L = zeros(1,length(componentX));
    
    for i=2:length(componentX)
        
        dx = componentX(i-1) - componentX(i);
        dy = componentY(i-1) - componentY(i);
        dz = componentZ(i-1) - componentZ(i);
        
        L(i) = sqrt(dx^2 + dy^2 + dz^2);
    end
    
    totalL = sum(L);

end