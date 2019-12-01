function [ iPi,iA,Pi,A,mixmat,varargout ] = hmm_EM( O,Pi0,A0,mixmat0,maxIter,s,varargin )
%EMSTEP Find the parameters of an HMM with discrete or continuos outputs using EM 
%INPUT O : observations (F X T)
%      Pi0 : prior probability
%      A0 :  transition matrix  
%      maxIter: max number of iterations 
%      Optional Mu0,Sigma0 if continuos observation or B0 if discrete observation 
%OUTPUT  Pi stimed prior; A stimed transition matrix ,
%Mu,Sigma stimed Gaussians parameter for conitnuos outputs; B stimed emission
%probabilities for discrete outputs

%init

F=size(O,1);
N=size(A0,1);
T=size(O,2);


if (size(varargin,2)>1)
    Mu0=varargin{1};
    Sigma0=varargin{2};
    M=size(Mu0,3);
    C=1;    
else 
    B0=varargin{1};
    M=size(B0,2);
    B=zeros(N,M,F);
    C=0;   
end 

SigmaTool=zeros(F,F,N,M);

for s=1:N
    for f=1:F
        for mx=1:M
            SigmaTool(f,f,s,mx)=Sigma0(f,s,mx);
        end
    end
end

[LL, Pi, A, Mu, Sigma2, mixmat ,beta,alpha,gamma,xi_summed] = mhmm_em(O, Pi0, A0, Mu0, SigmaTool, mixmat0, 'max_iter', maxIter,'verbose',0,'cov_type','diag');

new_log_lik = LL(1,end);

Sigma=zeros(F,N,M);
for s=1:N
     for f=1:F      
        for mx=1:M
            Sigma(f,s,mx)=Sigma2(f,f,s,mx);
        end
      end
end

%Pi
iPi=cell(N,1);
den=sum(beta(:,1).*alpha(:,1))+s;

%disp([' P den: ',num2str(den)]);

for i=1:N
    iPi(i,1)={[ (beta(i,1)*alpha(i,1)/den) ((beta(i,1)*alpha(i,1)+s)/den)]};
end

%A
iA=cell(N,N); 
for i=1:N
    for j=1:N
        iA(i,j)={[ ( xi_summed(i,j)  / (sum(gamma(i,1:(T-1)))+s)  )   ( (xi_summed(i,j)+s)  / (sum(gamma(i,1:(T-1)))+s)  )   ]};
        disp([' a_ij den: ',num2str((sum(gamma(i,1:(T-1)))))]);
    end
end

%display(Pi);
%display(A);

%potrei calcolarmi la lower e upper likelihood del modello impreciso!!

display(['Learned in ',num2str(size(LL,2)),' iterations!']);

if C==1
    varargout{1}=Mu;
    varargout{2}=Sigma;
    varargout{3}=new_log_lik;
else
    varargout{1}=B;
    varargout{2}=new_log_lik;
end
    
end
