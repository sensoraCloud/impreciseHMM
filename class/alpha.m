function [ alp alp_N_t] = alpha( s,t,Pi,A,O,varargin )
%ALPHA forward algorithm
%INPUT s : state
%      t : time
%      Pi : prior probability
%      A :  transition matrix  
%      O : observations (F X T)
%      Optional Mu,Sigma,mixmat if continuos observation or B if discrete observation 
%OUTPUT - posterior probs alpha p(Q(t)=s,O(1:t)| model) 
%       - alp_N_t (Nx1) p(Q(t)=(1:N),O(1:t)| model)

if (size(varargin,2)>1)
    Mu=varargin{1};
    Sigma=varargin{2};
    mixmat=varargin{3};
    %get state probabilities for each t=1..t having O
    seq_prob=eval_pdf_cont( O,Mu,Sigma,mixmat,t );
    
    
else 
    B=varargin{1};
    %get state probabilities for each t=1..t having O
    seq_prob=eval_pdf_dis( O,B,t );
end

alpha2=zeros(size(Pi,1),t);

t2=1;

alpha2(:,t2)=Pi(:) .* seq_prob(:,t2);

for t2=2:t
    
    % sum_i { a_ij * alpha_j(t) } for each state
    m=A' * alpha2(:,t2-1);
    % sum_i { a_ij * alpha_j(t) * b_j(t) } for each state
    alpha2(:,t2)=m(:) .* seq_prob(:,t2);
       
end

alp=alpha2(s,t);
alp_N_t=alpha2(:,t);

end

