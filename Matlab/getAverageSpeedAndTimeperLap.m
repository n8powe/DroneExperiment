function [ avgSpd, avgTime, ciSpd, ciTime] = getAverageSpeedAndTimeperLap(positionData)

    
    avgTime = 0;
    
    xPos = positionData.('Position(x)');
    yPos = positionData.('Position(y)');
    zPos = positionData.('Position(z)');
    t = positionData.Timestamp;

    speedVector = zeros(1,length(xPos)-1);
    
    for i=2:length(t)
        dt = (t(i) - t(i-1))/1000;
        dx = (xPos(i) - xPos(i-1))/dt;
        dy = (yPos(i) - yPos(i-1))/dt;
        dz = (zPos(i) - zPos(i-1))/dt;
        
        mag = sqrt(dx^2 + dy^2 + dz^2);
        
        speedVector(i-1) = mag;
    end
    B = speedVector(~isnan(speedVector));
    avgSpd = mean(B);
    
    
    ciSpd = 1.96*std(B)/sqrt(length(B));
    ciTime = 0;
    
end