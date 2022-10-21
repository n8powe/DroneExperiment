function points = findNormalPoints(currHoopDronePositionX, currHoopDronePositionZ, currHoopDroneOrientY)

        numFrames = length(currHoopDronePositionX);
        droneWidth = 2;
        points = zeros(8,numFrames);
        
        x = currHoopDronePositionX;
        z = currHoopDronePositionZ;
        
        for i=1:numFrames

            %orientX = eulerAngles(3);%*(pi/180);
            orientY = currHoopDroneOrientY(i)*pi/180;%abs(eulerAngles(2));%*(pi/180);
            %orientZ = eulerAngles(1);%*(pi/180);

            p1x = x(i) + sin(orientY)*droneWidth;
            p1y = z(i) + cos(orientY)*droneWidth;

            p2x = x(i) - sin(orientY)*droneWidth;
            p2y = z(i) - cos(orientY)*droneWidth;

            rotatedp1x = (p1x - x(i))*cos(pi/2) - (p1y - z(i))*sin(pi/2) + x(i);
            rotatedp1y = (p1x - x(i))*sin(pi/2) - (p1y - z(i))*cos(pi/2) + z(i);

            rotatedp2x = (p2x - x(i))*cos(pi/2) - (p2y - z(i))*sin(pi/2) + x(i);
            rotatedp2y = (p2x - x(i))*sin(pi/2) - (p2y - z(i))*cos(pi/2) + z(i);
            
            
            points(1,i) = p1x;
            points(2,i) = p1y;
            points(3,i) = p2x;
            points(4,i) = p2y;
            
            points(5,i) = rotatedp1x;
            points(6,i) = rotatedp1y;
            points(7,i) = rotatedp2x;
            points(8,i) = rotatedp2y;
            
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

end