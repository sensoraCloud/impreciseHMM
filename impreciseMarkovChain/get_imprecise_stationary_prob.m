function [ lower  upper stat_distr  f] = get_imprecise_stationary_prob( iPi,iA,alpha )
%GET IMPRECISE STATIONARY DISTRIBUTION of imprecise Markov chain
%INPUT  iPi: prior interval iHMM probability
%        iA: imprecise transition matrix 
%    alpha: stationary threshold (es. 1e-6)
%OUTPUT lower (1 X N) upper (1 X N) stationary distribution of each hidden states
%       stat_distr: lower subset probabilities   f: binary subset index

N=size(iA,1);
Lpri=zeros(N,N);
Upri=zeros(N,N);


if iscell(iA(1,1))
    %imprecise
    for i=1:N
        for j=1:N
            Lpri(i,j)=iA{i,j}(1,1);
            Upri(i,j)=iA{i,j}(1,2);
        end
    end
else
    %precise
    for i=1:N
        for j=1:N
            Lpri(i,j)=iA(i,j);
            Upri(i,j)=iA(i,j);
        end
    end
end



% lower probability interval (PRI) transition matrix
% Lpri = [.2 .7 0 0
%         .1 .6 .1 0
%         0 .2 .4 .2
%         0 0 .2 .8];
% 
% % upper PRI transition matrix
% Upri=[.4 .9 .3 .3
%     .5 .9 .5 .3
%     .3 .6 .8 .6
%     0 0 .2 .8];


    

initLPri=zeros(1,N);
initUPri=zeros(1,N);

if iscell(iPi(1,1))

    %imprecise
    for i=1:N

        initLPri(1,i)=iPi{i,1}(1,1);
        initUPri(1,i)=iPi{i,1}(1,2);

    end

else
    
    %precise
    for i=1:N

        initLPri(1,i)=iPi(i,1);
        initUPri(1,i)=iPi(i,1);

    end
    
end

% initial lower PRI
% initLPri = [0.1 0.3 0.2 0.1];
% 
% % initial upper PRI
% initUPri = [0.3 0.5 0.5 0.2];

% N=3
% Lpri = [.2 .3 .3
%         .3 .2 .3
%         .3 .3 .2];
% 
% % upper PRI transition matrix
% Upri=[.2 .5 .5 
%     .5 .2 .5
%     .5 .5 .2];
% %initial lower PRI
% initLPri = [0 1 0];
% 
% % initial upper PRI
% initUPri = [0 1 0];



% the number of states
n = length(initLPri);

% the indicator functions of all subsets of 
% the set of the size n
% Example ( n=3 ):
% f =
% 
%      1     0     0
%      0     1     0
%      1     1     0
%      0     0     1
%      1     0     1
%      0     1     1
f = fnalsLP(n);

% generate initial lower probability
Linitial = pri2lp(initLPri, initUPri);

% generate lower transition matrix
L = pri2lpMatrix(Lpri, Upri);

subsets=size(f,1);

alp =zeros(1,subsets);
delta = zeros(1,subsets);

for s=1:subsets
    
    alp(1,s)= alpha;
    delta(1,s)= inf;
    
end
 
iter=1;

stat_distr=zeros(1,subsets);

old_stat_distr=zeros(1,subsets);

maxiter=50;

% %10 iter
% stat_distr = markovSteps ( f, Linitial, L, 10);
% lower=zeros(1,N);
% upper=zeros(1,N);
% for i=1:N
%    
%     %lower
%     contr = get_binary_control(i,N,0);
%     idx   = get_index_control( f,contr );
%     lower(1,i)=stat_distr(1,idx);
%     
%     %upper
%     contr = get_binary_control(i,N,1);
%     idx   = get_index_control( f,contr );
%     upper(1,i)=1-stat_distr(1,idx);
%         
% end
% disp(lower);
% disp(upper);

while sum(delta>alp)~=0 && iter<maxiter
    
%     f,    Linitial,  L,      iter
%     fnals, initL, transL, nsteps
        
    if iter==1
       Lw = L;
    end
   
    for i = 1:length(L(:, 1))
        for j = 1:length(L(1, :))
                    X = Lw(:, j);
                    [l, p] = lowerExpSet(L(i,:)', f, X);
                    Lnew(i, j) = l;
        end
    end

    Lw = Lnew;        
        
    for j = 1:length(L(1, :))
            X = Lw(:, j);
            [l, p] = lowerExpSet(Linitial', f, X);
            Ln(j) = l;
    end
    
    stat_distr = Ln;
    
    %3 decimal precision    
    delta= abs(round2(stat_distr,0.001) - round2(old_stat_distr,0.001));
    
    old_stat_distr=stat_distr;
     
    disp([num2str(iter),' : ',num2str(stat_distr),' delta: ', num2str(delta) ]);

    iter=iter+1;
    
end

lower=zeros(1,N);
upper=zeros(1,N);

for i=1:N
   
    %lower
    contr = get_binary_control(i,N,0);
    idx   = get_index_control( f,contr );
    lower(1,i)=stat_distr(1,idx);
    
    %upper
    contr = get_binary_control(i,N,1);
    idx   = get_index_control( f,contr );
    upper(1,i)=1-stat_distr(1,idx);
        
end

end

