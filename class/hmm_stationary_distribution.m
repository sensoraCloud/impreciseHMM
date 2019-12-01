function [ stat_distr ] = hmm_stationary_distribution( Pi,A,alpha )
%HMM stationary distribution 
%INPUT  Pi: prior HMM probability
%        A: transition matrix
%    alpha: stationary threshold (es. 1e-7)
%OUTPUT stat_distr (1 X N) stationary distribution of each hidden states

N=size(A,1);

Pi=Pi';

alp =zeros(1,N);
delta = zeros(1,N);

for s=1:N
    
    alp(1,s)= alpha;
    delta(1,s)= inf;
    
end
 
iter=1;

stat_distr=zeros(1,N);

old_stat_distr=zeros(1,N);

maxiter=500;

while sum(delta>alp)~=0 && iter<maxiter

    if iter==1
        stat_distr=Pi * A;
    else
        stat_distr=stat_distr * A;
    end
    
    delta= abs(stat_distr - old_stat_distr );
    
    old_stat_distr=stat_distr;
     
    %disp([num2str(iter),' : ',num2str(stat_distr),' delta: ', num2str(delta) ]);

    iter=iter+1;
    
end

%normalize
stat_distr=normalize(stat_distr);

end

