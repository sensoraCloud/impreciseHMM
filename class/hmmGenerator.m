function [ Pi,A,varargout ] = hmmGenerator( N,C,F,varargin )
%HMM GENERATOR Generate a random iHMM
%INPUT  N: hidden states
%       C: C=0 discrete observations and |F|=M (default M=2); C=1 continuos observations 
%OPTIONAL M: only if C=0 number of  possible discrete value for
%observation
%OUTPUT  Pi,A,B for discrete and Pi,A,Mu,Sigma for continuos 

Pi=rand(N,1);
Pi=Pi/sum(Pi);

%init
A=zeros(N,N);
if C == 1
    Mu=zeros(F,N);
    Sigma=zeros(F,N);
    %Sigma=zeros(F,F,N);
else   
    if (~isempty(varargin))
        M=varargin{1};
    else
        M=2;        
    end    
    B=zeros(N,M,F);
end    

for s=1:N
    prob=rand(N,1);
    prob=prob/sum(prob);
    A(s,:)=prob;
end

if C == 1

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
else    
    
    for f=1:F
        for s=1:N
            prob=rand(M,1);
            prob=prob/sum(prob);
            B(s,:,f)=prob;
        end
    end
    varargout{1}=B;
end
    

end
