% Generates linear functionals corresponding to indicator functions of subsets of {1,...,n}
% The result is a matrix whose rows correspond to indicator functions of
% subsets
function retfnals = fnalsLP (n)
	% matrika
	for i=1:2^n-2
		a(i,:) = genset(n, i);
    end
retfnals = a;
