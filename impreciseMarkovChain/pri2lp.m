% generates a lower probability from 
% a lower 'Lpri' and upper 'Upri' PRI functions 
function retlp = pri2lp (Lpri, Upri)
	% number of states
    n = length(Lpri);     
    % indicator functions corresponding to subsets
	flp = fnalsLP(n); 
    % generate lower probability from PRI using
    % Weichselberger's formula (page 300)
	for i = 1:length(flp(:, 1)) 
		low = 0;
		up  = 0;
		for j = 1:length(Lpri);
			if flp(i, j) == 1 
				low = low + Lpri(j);
			else
				up = up + Upri(j);
            end
        end
		rlp(i) = max(low, 1-up);
    end
	retlp = rlp;
