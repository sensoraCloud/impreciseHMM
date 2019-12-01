function [ seqQ ] = sequenceHiddenStateGenerator( Pi,A,T )
%sequenceHiddenStateGenerator Generate a random sequence of T hidden states according with the xi distribution 

seqQ=zeros(1,T);

for t=1:T
        
    if t==1
        current_state=init_state(Pi);
    else
        %current_state = generates_state(xi{t-1}(current_state,:));       
        current_state = generates_state(A(current_state,:));        
    end
    
    seqQ(1,t)=current_state;
    
end

%display(seqQ);

end