function rVector = rotateThrustVectorAroundDrone(currHoopThrustVector, currHoopDronePosition, currHoopDroneOrientY)
        
        x = currHoopDronePosition(1,:);
        z = currHoopDronePosition(3,:);
        
        thrustX = currHoopThrustVector(1,:);
        thrustZ = currHoopThrustVector(2,:);
        
        numFrames = length(x);
        droneWidth = 2;
        rVector = zeros(2,numFrames);
        
        for i=1:numFrames

            %orientX = eulerAngles(3);%*(pi/180);
            orientY = -(currHoopDroneOrientY(i)*pi/180);%abs(eulerAngles(2));%*(pi/180);
            %orientZ = eulerAngles(1);%*(pi/180);

            p1x = thrustX(i);
            p1y = thrustZ(i);



            rotatedp1x = (p1x - x(i))*cos(orientY) - (p1y - z(i))*sin(orientY) + x(i);
            rotatedp1y = (p1x - x(i))*sin(pi-orientY) - (p1y - z(i))*cos(pi-orientY) + z(i);

            
            
            rVector(1,i) = rotatedp1x;
            rVector(2,i) = rotatedp1y;


            
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
        %rVector = currHoopDronePosition([1,3],:) + rVector;
end
