function [ measures ] = observation( current_state,varargin )
%OBSERVATION makes a measurement
% optional argument Mu,Sigma,mixmat if continuos observ. or B if discrete obs.

if (size(varargin,2)>1)
    C=1;
    Mu=varargin{1};
    Sigma=varargin{2};
    mixmat=varargin{3};
    F=size(Mu,1);
    M=size(Mu,3);
else 
    C=0;
    B=varargin{1};
    F=size(B,3);
end

measures=zeros(F,1);

for f=1:F
    
    if (C==1)
        if M==1
            measures(f,:)=normrnd(Mu(f,current_state), sqrt( Sigma(f,current_state) ) );
            %measures(f,:)=normrnd(Mu(f,current_state),Sigma(f,f,current_state));
        else
            
            for m=1:M
                muTmp(m,1)=Mu(f,current_state,m);
                sigmaTmp(:,:,m)=sqrt(Sigma(f,current_state,m));
                mix(1,m)=mixmat(current_state,m);
            end         
            
            objDis = gmdistribution(muTmp,sigmaTmp,mix); 
            measures(f,:)=random(objDis,1);
        end
        
    else
        measures(f,:)=generatesDiscreteSample(B(current_state,:,f));
    end
    
end


end

