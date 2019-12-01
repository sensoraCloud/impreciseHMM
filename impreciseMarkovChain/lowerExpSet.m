% Calculates the lower expectation of X with respect to generalised lower probability L 
% The set taken is of the form E_p f >= L(f)
function [retl, retprob] = lowerExpSet (L, fnals, X)
%	L and X must be columns
	n = length(X);	
	options = optimset('Display', 'off');
    [xmin, fmin] = linprog(X, -fnals, -L, ones(1, n),1,[],[],[],options);  
	retl = fmin;
	retprob = xmin;