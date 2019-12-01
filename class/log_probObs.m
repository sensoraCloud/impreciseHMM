function [ logprobOb ] = log_probObs( Pi,A,O,varargin )
%PROB_OBSERVATION probability of observation having model
%INPUT Pi : prior probability
%      A :  transition matrix  
%      O : observations (F X T)
%      Optional Mu,Sigma,mixmat if continuos observation or B if discrete observation 
%OUTPUT logprobOb  log p(O(1:T)| model) 

T=size(O,2);

if (size(varargin,2)>1)
    Mu=varargin{1};
    Sigma=varargin{2};
    mixmat=varargin{3};
    %get state probabilities for each t=1..t having O
    %seq_prob=eval_pdf_cont( O,Mu,Sigma,mixmat,T );
    
    F=size(Mu,1);
    M=size(Mu,3);
    N=size(Mu,2);   
    SigmaTool=zeros(F,F,N,M);
    
    if isempty(mixmat)
        mixmat=ones(N,1);
    end
        
    for s=1:N
         for f=1:F      
              for m=1:M
                        SigmaTool(f,f,s,m)=Sigma(f,s,m);
              end
         end
    end
        
    [seq_prob, seq_prob_mix] = mixgauss_prob(O, Mu, SigmaTool, mixmat );    
    
else 
    B=varargin{1};
    %get state probabilities for each t=1..t having O
    seq_prob=eval_pdf_dis( O,B,T );
end

t=1;

alpha=zeros(size(Pi,1),T);
scale = ones(1,T);

alpha(:,t)=Pi(:) .* seq_prob(:,t);

[alpha(:,t), scale(t)] = normalize(alpha(:,t));

for t=2:T
    
    % sum_i { a_ij * alpha_j(t) } for each state
    m=A' * alpha(:,t-1);
    % sum_i { a_ij * alpha_j(t) * b_j(t) } for each state
    alpha(:,t)=m(:) .* seq_prob(:,t);
   
    [alpha(:,t), scale(t)] = normalize(alpha(:,t));
       
end

if any(scale==0)
   logprobOb = -inf;
else
   logprobOb =  sum(log(scale));
end

end