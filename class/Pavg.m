function [ Pavg ] = Pavg( Pi,A,O,varargin )
%COST FUNCTION Calculate the cost function for candidate solution for SASEM
% alghoritm
%INPUT Pi : prior probability
%      A :  transition matrix  
%      O : observations (F X T)
%      Optional Mu,Sigma if continuos observation or B if discrete observation 
%OUTPUT Pavg 1/F sum_{f=i}^F  log Pf(Of(1:T)| model) 

if (size(varargin,2)>1)
    Mu=varargin{1};
    Sigma=varargin{2};   
    C=1;
else 
    B=varargin{1};   
    C=0;
end

F=size(O,1);
log_lik=zeros(1,F);

for f=1:F
   if C==1
        log_lik(1,f)=log_probObs( Pi,A,O(f,:),Mu,Sigma);
   else
        log_lik(1,f)=log_probObs( Pi,A,O(f,:),B);   
   end
    
end

Pavg = sum(log_lik,2) / F;


end