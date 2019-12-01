% generates the subset of {1,..., n} corresponding to 'num'
% genset(3, 5)=[1, 0, 1] because 5=1*2^2+0*2^1+1*2^0 
function retval = genset (n, num)
k=1; nu = num;
while k < n+1
	if floor(nu/2)*2 == nu 
		rset(k) = 0;
	else 
		rset(k) = 1;
    end
	nu = floor(nu/2);
	k = k+1;
end
retval = rset;