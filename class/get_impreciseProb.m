function [ low_up ] = get_impreciseProb( p,eps )
%GET IMPRECISE PROBABILITY from precise probability with eps precision
%INPUT p: precise probability
%      eps: precision
%OUTPUT low_up: {[lower,upper]} imprecise probability

lower = eps * p;
upper = eps * p + (1-eps);
low_up={[lower upper]};

end


