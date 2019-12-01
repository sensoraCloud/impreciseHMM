function [ consistent ] = consistentHMM( Pi,A )
%consistentHMM verify is HMM parametr is consistent
%OUTPUT 1 if consistent 0 otherwise
N=size(A,1);

if sum(Pi,1) ~= 1
    consistent=0;
elseif sum( sum(A,2) ,1 )  ~= N
    consistent=0;    
else
    consistent=1;
end

end

