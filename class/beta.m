function [ bet bet_t_N ] = beta( s,t,Pi,A,O,varargin )
%BETA backward algorithm
%INPUT s : state
%      t : time
%      Pi : prior probability
%      A :  transition matrix  
%      O : observations (F X T)
%      Optional Mu,Sigma,mixmat if continuos observation or B if discrete observation 
%OUTPUT posterior probs beta p(  O(t+1:T) | Q(t)=s , model)
% and bet_t_N (Nx1) p(  O(t+1:T) | Q(t)=(1:N) , model)

if (size(varargin,2)>1)
    Mu=varargin{1};
    Sigma=varargin{2};
    mixmat=varargin{3};
    F=size(Mu,1);
    M=size(Mu,3);
    N=size(Mu,2);
    %get state probabilities for each t=1..t having O
    %seq_prob=eval_pdf_cont( O,Mu,Sigma,mixmat,T );
    SigmaTool=zeros(F,F,N,M);
        
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

N=size(Pi,1);
beta2=zeros(N,T);

beta2(:,T)=ones(N,1);

for t2=T-1:-1:t
    % { beta_j(t+1) * b_j(t+1) } for each state j
    b=beta2(:,t2+1) .* seq_prob(:,t2+1);
    % sum_j { a_ij * beta_j(t+1) * b_j(t+1) } for each state i
    beta2(:,t2)=A * b;   
end

bet=beta2(s,t);
bet_t_N = beta2(:,t);


end
