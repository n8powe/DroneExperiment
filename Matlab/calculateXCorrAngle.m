function theta = calculateXCorrAngle(c, u, v) % u = [x1, y1] v = [x2, y2]
    %theta = atan2d(u(:,1).*v(:,2)-v(:,1).*u(:,2), u(:,1).*u(:,2)+v(:,1).*v(:,2));
    theta = zeros(1,size(u,1));
    
    u = u - c;
    v = v - c;
    
    for i=1:size(u,1)
    
        %theta = atan2(norm(cross(u,v)),dot(u,v));
        %th = acos(dot(u(i,:), v(i,:)) / (norm(u(i,:)) * norm(v(i,:))));
        %CosTheta = max(min(dot(u,v)/(norm(u)*norm(v)),1),-1);
        %theta = real(acosd(CosTheta));
        %th = subspace(u(i,:),v(i,:));
        %th = acos(dot(u(i,:) / norm(u(i,:)), v(i,:) / norm(v(i,:))));
        %th = atan2d(u(i,1)*v(i,2)-v(i,1)*u(i,2), u(i,1)*u(i,2)+v(i,1)*v(i,2));
        %th = (th * 180.0) / pi;
        
        %ac = (u(i,:) -c(i,:))/norm(u(i,:)-c(i,:));  % Magnitude of vectors
        %av = (v1(i,:)-c(i,:))/norm(v1(i,:)-c(i,:));
        
        %dotProdUV = dot(u,v);
        
        
    
        lenU = sqrt(u(i,1)^2 + u(i,2)^2);
        lenV = sqrt(v(i,1)^2 + v(i,2)^2);
        
        dotProd = u(i,1)*v(i,1) + u(i,2)*v(i,2);
        
        denProd = lenU*lenV;
        
        cosTheta = dotProd/denProd;
        
        th = acos(cosTheta);
        %th = atan2(norm(det([ac; av])), dot(ac, av));
        x1 = u(1);
        x2 = v(1);
        y1 = u(2);
        y2 = v(2);
        a = atan2d(x1*y2-y1*x2,x1*x2+y1*y2);
        if dotProd < 0
            th = -th;
        end
        
        theta(1,i) = a; %* 180 / pi
        
        theta(isnan(theta))=0;
        
    end
end