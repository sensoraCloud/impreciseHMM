function [ Mu0,Sigma0 ] = init_Mu_Sigma( O , N , M )
%INIT MU SIGMA Compute the mean and variance of the Gaussian for each
%feature and hidden state
%   INPUT O: observations (F X T)
%         N: num. hidden states
%         M: mixtures for state 
%   OUTPUT Mu0,Sigma0 (Mu0(f,i) is a random value from interval [ Max (Of) -
%   Min(Of) ]

F=size(O,1);

minO=zeros(F,1);
maxO=zeros(F,1);
Mu0=zeros(F,N,M);
Sigma0=zeros(F,N,M);

for f=1:F
    
    Obs=O(f,:);
    minO(f)=min(Obs);
    maxO(f)=max(Obs);

    
    for m=1:M
       
          coef=rand(1,N);
          Mu0(f,:,m)=minO(f)+coef*(maxO(f)-minO(f)); 

          for s=1:N

              left = Mu0(f,s,m) - minO(f);
              right = maxO(f) - Mu0(f,s,m);

              if (left>right)
                  dev=left / 3;
              else
                  dev=right / 3;
              end

              Sigma0(f,s,m)=dev^2;

          end;
          
        
    end
    

end;


end

