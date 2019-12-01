function [ state ] = generates_state(prob)
% GENERATES STATE returns a state according to the distribution prob
% Example: generates_state([0.8 0.2]) generates a state
% where the prob. of being 1 is 0.8 and the prob of being 2 is 0.2.

R = rand();
cumprob = cumsum(prob(:));
cumprob2 = cumprob(1:end-1);
state = sum(R > cumprob2)+1;
  
end


