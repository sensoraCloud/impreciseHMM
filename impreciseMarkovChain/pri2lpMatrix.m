% Generates lower probability matrix from 
% lower 'Lpri' and upper 'Upri' PRI matrices. 
% If only 'Lpri' is given then the lower transition 
% matrix is calculated by the natural extension.
function retlpM = pri2lpMatrix (Lpri, Upri)
n = length(Lpri(1, :));
flp = fnalsLP(n);
if nargin == 1	
	for i=1:length(Lpri(:, 1))
       rlp(i, :) = pri2lp(Lpri(i,:), ones(1, n));
    end
else
    for i=1:length(Lpri(:, 1))
       rlp(i, :) = pri2lp(Lpri(i,:), Upri(i, :));
    end
end
retlpM = rlp;

