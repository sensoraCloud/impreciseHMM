
for c=1:72
   
    for f=1:15
    
        if (relative_distances{3}(c,f)<=relative_distances{6}(c,f))  && (relative_distances{3}(c,f)>=relative_distances{5}(c,f))
        
            %disp('1');
            
        else
        
            disp('0');
            
        end
    end
    
end


