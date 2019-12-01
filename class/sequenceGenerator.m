function [ O hidden_states ] = sequenceGenerator( Pi,A,T,varargin )
%SequenceGenerator Generate a random sequence of T observation according with the' HMM probabilities 
%optional argument Mu,Sigma,mixmat if continuos observ. or B if discrete obs.

if (size(varargin,2)>1)
    C=1;
    Mu=varargin{1};
    Sigma=varargin{2};
    mixmat=varargin{3};
    F=size(Mu,1);   
else 
    C=0;
    B=varargin{1};
    F=size(B,3);
end

O=zeros(F,T);

hidden_states=zeros(1,T);

for t=1:T
        
    if t==1
        current_state=init_state(Pi);
    else
        current_state=transition(current_state,A);
    end
    
    hidden_states(1,t)=current_state;
    
    if (C==1)
            O(:,t)=observation(current_state,Mu,Sigma,mixmat);
        else
            O(:,t)=observation(current_state,B);  
    end
end

%display(hidden_states);

end

