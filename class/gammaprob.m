function [ gam ] = gammaprob( s,t,Pi,A,O,varargin )
%GAMMAPROB get probability Gamma
%INPUT s : state
%      t : time
%      Pi : prior probability
%      A :  transition matrix  
%      O : observations (F X T)
%      Optional Mu,Sigma if continuos observation or B if discrete observation 
%OUTPUT posterior probs Gamma p(Q(t)=s,O(1:T)| model)

if (size(varargin,2)>1)
    Mu=varargin{1};
    Sigma=varargin{2};   
    [alp_t alp_N]=alpha( s,t,Pi,A,O,Mu,Sigma);
    [bet_t bet_N]=beta( s,t,Pi,A,O,Mu,Sigma);  
else 
    B=varargin{1};
    [alp_t alp_N]=alpha( s,t,Pi,A,O,B);
    [bet_t bet_N]=beta( s,t,Pi,A,O,B);
end
    
gam = alp_t * bet_t;

gam = gam / (alp_N' * bet_N);

end

