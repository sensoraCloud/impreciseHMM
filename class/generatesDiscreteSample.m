function [ sample ] = generatesDiscreteSample(prob)
% GENERATES SAMPLE returns a sample according to the distribution prob
% Example: generatesDiscreteSample([0.8 0.2]) generates a sample
% where the prob. of being 0 is 0.8 and the prob of being 1 is 0.2.

R = rand();
cumprob = cumsum(prob(:));
cumprob2 = cumprob(1:end-1);
sample = sum(R > cumprob2)+1;
  
end

