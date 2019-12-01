function [ contr ] = get_binary_control( sets,N,complement )
%GET BINAY CONTROL 

contr=zeros(1,N);

for i=1:N
   
    if complement==0
    
        if sum(sets==i)>0
            contr(1,i)=1;
        else
            contr(1,i)=0;
        end
    
    else
        
        if sum(sets==i)>0
            contr(1,i)=0;
        else
            contr(1,i)=1;
        end

        
    end
    
    
end


end

