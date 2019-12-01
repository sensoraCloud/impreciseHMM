function [ x_i_t ] = xi( i,j,t,Pi,A,O,varargin )
%XI get probability Xi
%INPUT i : from state
%      j : to state
%      t : time
%      Pi : prior probability
%      A :  transition matrix  
%      O : observations (F X T)
%      Optional Mu,Sigma,mixmat if continuos observation or B if discrete observation 
%OUTPUT posterior probs Xi p(Q(t)=i ,Q(t+1)=j|O(1:T) , model)

if (size(varargin,2)>1)
    Mu=varargin{1};
    Sigma=varargin{2};   
    mixmat=varargin{3};
    bet_j=beta( j,t+1,Pi,A,O,Mu,Sigma);
    bet_i=beta( i,t,Pi,A,O,Mu,Sigma);
    gam_i_t=gammaprob( i,t,Pi,A,O,Mu,Sigma );
    emm_prob_j=eval_pdf_cont( O,Mu,Sigma,mixmat,t+1,j);
else 
    B=varargin{1};
    bet_j=beta( j,t+1,Pi,A,O,B);
    bet_i=beta( i,t,Pi,A,O,B);
    gam_i_t=gammaprob( i,t,Pi,A,O,B );
    emm_prob_j=eval_pdf_dis( O,B,t+1,j);
end
    
x_i_t = (gam_i_t *  A(i,j) * emm_prob_j * bet_j) / bet_i;

end