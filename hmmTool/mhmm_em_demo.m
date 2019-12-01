
O = 2;          %Number of coefficients in a vector 
 
nex = 1;        %Number of sequences 
M = 2;          %Number of mixtures 
Q = 6;          %Number of states 

cov_type = 'diag';

%data = randn(O,T,nex);

fts=importdata('src\features\KTH_DX_scenario2.mat');

cls=size(fts,1);
mdls=size(fts,2);
    
% for m=1:mdls
%    
%         %take first f features (shape features) and 500 + F features (movement features)
%      data(:,:,m)=[fts{1,m}(1:F,:) ; fts{1,m}(501:(500+F),:)];
%         
%                      
% end

data=fts{2,1}(1:2,:);

T = size(data,2);         %Number of vectors in a sequence 

close all

%plot(data,'-r');

% initial guess of parameters
prior0 = normalise(rand(Q,1));
transmat0 = mk_stochastic(rand(Q,Q));

if 0
  Sigma0 = repmat(eye(O), [1 1 Q M]);
  % Initialize each mean to a random data point
  indices = randperm(T*nex);
  mu0 = reshape(data(:,indices(1:(Q*M))), [ (O*2) Q M]);
  mixmat0 = mk_stochastic(rand(Q,M));
else
  [mu0, Sigma0] = mixgauss_init(Q*M, data, cov_type);
  mu0 = reshape(mu0, [(O) Q M]);
  Sigma0 = reshape(Sigma0, [(O) (O) Q M]);
  mixmat0 = mk_stochastic(rand(Q,M));
end

[LL, prior1, transmat1, mu1, Sigma1, mixmat1] = ...
    mhmm_em(data, prior0, transmat0, mu0, Sigma0, mixmat0, 'max_iter', 20);

Sigma02=zeros(O,Q);
 for s=1:Q
      for f=1:O      
           for m=1:M
                Sigma02(f,s,m)=Sigma0(f,f,s,m);
           end
      end
 end

[ Pi2,A2,mixmat2,Mu2, Sigma2 ,likel2 ] = hmm_EM( data,prior0,transmat0,20,mixmat0,mu0, Sigma02 );

loglik = mhmm_logprob(data, prior1, transmat1, mu1, Sigma1, mixmat1);

disp(loglik);
disp(likel2);

%loglik2 = mhmm_logprob(data, Pi2, A2, Mu2, Sigma2, mixmat2);

disp(['Q: ',num2str(Q),' M: ',num2str(M),' lik: ',num2str(loglik)]);

[obs, hidden] = mhmm_sample(T, 1, prior1, transmat1, mu1, Sigma1, mixmat1);

%hold on

%plot(obs,'-b');

