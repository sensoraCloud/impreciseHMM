function [ gam gamma_s_t_new ] = getGammaContrl( gamma_s_t,s,t,Pi,A,O,varargin )
%GAMMAPROB get probability Gamma
%INPUT gamma_s_t : matrix (N X T) contains gamma_s(t) values or initial
%values '99' (null)
%      s : state
%      t : time
%      Pi : prior probability
%      A :  transition matrix  
%      O : observations (F X T)
%      Optional Mu,Sigma if continuos observation or B if discrete observation 
%
%      optimized procedure that calculates the value Gamma only if it has not already been calculated (gamma_s_t(s,t)=99) 
%OUTPUT posterior probs Gamma p(Q(t)=s,O(1:T)| model)

if (gamma_s_t(s,t)~=99)
    
    gam = gamma_s_t(s,t);
    gamma_s_t_new=gamma_s_t;
    
else    
   
    if (size(varargin,2)>1)
        Mu=varargin{1};
        Sigma=varargin{2};   
        gam = gammaprob( s,t,Pi,A,O,Mu,Sigma );
        gamma_s_t(s,t)=gam;
        gamma_s_t_new=gamma_s_t;
    else 
        B=varargin{1};
        gam = gammaprob( s,t,Pi,A,O,B );
        gamma_s_t(s,t)=gam;
        gamma_s_t_new=gamma_s_t;
    end

end

end