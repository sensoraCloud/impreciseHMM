function [ iPi,iA,varargout ] = impreciseHmmGenerator( N,C,F,eps,varargin )
%IMPRECISE HMM GENERATOR Generate a random iHMM
%INPUT  N: hidden states
%       C: C=0 discrete observations and |F|=M (default M=2); C=1 continuos observations
%       eps: imprecision  ( [0,1] )
%OPTIONAL M: only if C=0 number of  possible discrete value for
%observation
%OUTPUT discrete case: iPi ([{[l_1,u_1]},..,{[l_N,u_N]}]') ,iA([{[l_11,u_11]},..,{[l_1N,u_1N]}] ; ... ; [{[l_N1,u_N1]},..,{[l_NN,u_NN]}] ),
%iB([[{[l_11 u_11]},..,{[l_N1 u_N1]}],..,[{[l_11 u_11]},..,{[l_NM u_NM]}] ] ,1], .. ,[[{[l_11 u_11]},..,{[l_N1 u_N1]}],..,[{[l_11 u_11]},..,{[l_NM u_NM]}] ] ,F] 
%; continuos case: iPi,iA,iMu ( [{[mu_low_11,mu_up_11]}, ... , {[mu_low_1N,mu_up_1N]}]  , .. , [{[mu_low_11,mu_up_F1]}, ... , {[mu_low_1N,mu_up_FN]}]  )
%,iSigma same precise case (F X N)

Pi=rand(1,N);
Pi=Pi/sum(Pi);
iPi=cell(N,1);

for i=1:N
    iPi(i,1)=get_impreciseProb( Pi(1,i),eps );
end

%init

A=zeros(N,N);

for s=1:N
    prob=rand(N,1);
    prob=prob/sum(prob);
    A(s,:)=prob;
end


%A=eye(N,N)
iA=cell(N,N);    

for s1=1:N
    for s2=1:N
        iA(s1,s2)=get_impreciseProb( A(s1,s2),eps );
    end
end


if C == 1
%     iMu=cell(F,N);
%     iSigma=zeros(F,N);
    %iSigma=zeros(F,F,N);
    
    Mu=zeros(F,N);
    Sigma=zeros(F,N);
    
else   
    if (~isempty(varargin))
        M=varargin{1};
    else
        M=2;        
    end    
    iB=cell(N,M,F);
end 

if C == 1

    %per ora output preciso
    
    for f=1:F
        for s=1:N
            Mu(f,s)=floor(100*rand());            
        end
    end

    for f=1:F
        for s=1:N        
            Sigma(f,s)=(randn()).^2;
        end
    end

    %Sigma=[ 0.03 0.03 0.03; 0.03 0.03 0.03];

    %set only diagonal variance , cov(x,y)=0
    %for s=1:N
     %   for f=1:L        
      %      Sigma(f,f,s)=(randn()).^2;
       % end
    %end
    
    varargout{1}=Mu;
    varargout{2}=Sigma;
    
    
    
%     MuLow(:,:)=rand(F,N);
%     MuUpp=MuLow+rand(F,N);
%     
%     for f=1:F
%         for s=1:N        
%             iMu(f,s)={[MuLow(f,s) MuUpp(f,s)]};
%         end
%     end
% 
%     for f=1:F
%         for s=1:N        
%             iSigma(f,s)=(randn()).^2;
%         end
%     end
% 
%     %Sigma=[ 0.03 0.03 0.03; 0.03 0.03 0.03];
% 
%     %set only diagonal variance , cov(x,y)=0
%     %for s=1:N
%      %   for f=1:L        
%       %      Sigma(f,f,s)=(randn()).^2;
%        % end
%     %end
%     
%     varargout{1}=iMu;
%     varargout{2}=iSigma;

else    
    
    for f=1:F
        for s=1:N
            prob=rand(1,M);
            prob=prob/sum(prob);
            for m=1:M
                iB(s,m,f)=get_impreciseProb( prob(1,m),eps );
            end            
        end
    end
        
    varargout{1}=iB;
end
    

end
