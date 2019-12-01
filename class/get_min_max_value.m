function [ min max ] = get_min_max_value( varargin )
%GET MINIMUM and MAXIMUM output value for each feature of one hmm
%INPUT B: emission matrix if HMMs is discrete 
%      Mu,Sigma,mixmat,q : gaussian parameters if HMM is continuos
%      and q decides the variance quantities that use for getting min and
%      max gaussian output. ( x_i_min = mu_i - q*sigma_i ) for the role of
%      three sigma of normal probability distribution q>3 is enough for the
%      calculation accuracy
%OUTPUT min max (1 X F) minimums and maximums values for each feature of the HMM   

%init

if (size(varargin,2)>2)
    Mu=varargin{1};
    Sigma=varargin{2};
    q=varargin{3};
    F=size(Mu,1);
    N=size(Mu,2);
    M=size(Mu,3);
    C=1;
else 
    B=varargin{1};
    C=0;   
end 

%discrete
if C==0
    
    %simbols 1 .. M for each feature B(N X M X F)
    min=ones(1,F);
    max=zeros(1,F);
    
    M=size(B,2);
    
    for f=1:F
      max(1,f)=M;
    end
    
else
%continuos
    
    min=zeros(1,F);
    max=zeros(1,F);
        
    for f=1:F
        
        min_val=inf; 
        max_val=-inf;
        
        for s=1:N
         
            for m=1:M
            
                 x_min=Mu(f,s,m) - q * sqrt(Sigma(f,s,m));
                 if x_min<min_val
                     min_val=x_min;
                 end

                 x_max=Mu(f,s,m) + q * sqrt(Sigma(f,s,m));
                 if x_max>max_val
                     max_val=x_max;
                 end
             
            end
             
        end    
        
        min(1,f)=min_val;
        max(1,f)=max_val;
        
     end
    
    
end




end