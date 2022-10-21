function [noCollision, hoops, throughpercentages, other, trees, path] = findCollisionObjectCategories(positionData)


    
    objects = positionData.Collision_Target; % Change this back to targets once fixed 
    
    [counts, elements] = groupcounts(objects);
    
    percentages = counts; %/sum(counts);

    noCollision = findTotalNumCollisions(objects) ;%(find(strcmp(elements, 'NULL')));
    
    if noCollision ~= 1
    
        hoops = 0; %findHoopFixationPercentage(elements, percentages);
        if isempty(hoops)
           hoops = 0; 
        end

        other = percentages(find(strcmp(elements, 'Terrain_0_0-20210127 - 113419')));
        if isempty(other)
           other = 0; 
        end


        path = percentages(find(strcmp(elements, 'PathOutline')));
        if isempty(path)
           path = 0; 
        end

        trees = sum(counts) - path - hoops - other;

        %throughGates = positionData.Gaze_Through_Gate;
        %[throughcounts, throughelements] = groupcounts(throughGates);
        throughpercentages = 0; %sum(throughcounts(2:end))/sum(throughcounts);
    else
        hoops = 0;
        trees = 0;
        other = 0;
        path = 0;
        throughpercentages = 0;
    end
    
    
  
end

function hoopFixation = findHoopFixationPercentage(elements, percentages)
    hoopFixation = 0;

    for i=1:length(elements)
       
        currString = elements(i);
        
        splitString = split(currString, ' ');
        
        if strcmp(splitString(1), 'RoundGate') || strcmp(splitString(1), 'RegularGate')
           
            hoopFixation = hoopFixation + percentages(i);
            
        end
        
        
        
    end




end

function numCollisions = findTotalNumCollisions(objects)

    numCollisions = 0;
    
    pastObj = 'firstFrame';
    
    for i=1:length(objects)
        
        if ~iscell(objects(i))
            
            currObject = objects(i);
        else
            currObject = objects{i};
        end
        
        if isnan(currObject)
            currObject = {''};
        end
        
        if ~isempty(currObject) && ~strcmp(currObject, pastObj)
            
            numCollisions = numCollisions + 1;
            pastObj = currObject;
        end
        
        %pastObj = currObject;
        
    end



end

