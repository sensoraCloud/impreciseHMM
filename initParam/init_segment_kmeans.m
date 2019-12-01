function [Pi, A,Mu, Sigma,mixmat] =  init_segment_kmeans(data, M, N)
% INIT_MHMM Compute initial param. estimates for an HMM with Gaussian outputs using segment k-means.
% [init_state_prob, transmat, obsmat, mixmat, mu, Sigma] = init_mhmm(data, Q, M, cov_type, left_right)
%
% Inputs:
% data(:,t,l) = observation vector at time t in sequence l
% M = num. mixture components
% N = num. hidden states
% eps threshold for duration (positive near zero es. 0.2 )
%
% Outputs:
% Pi = Pr(Q(1) = i)
% A = Pr(Q(t+1)=j | Q(t)=i)
% Mu  = mean of Y(t) given Q(t)=j
% Sigma  var. of Y(t) given Q(t)=j
% mixmat(j,k) = Pr(M(t)=k | Q(t)=j) where M(t) is the mixture component at
% time t

if M > 1
  mixmat = mk_stochastic(rand(N,M));
else
  mixmat = ones(N, 1);
end

F=size(data,1);

%trovo medie e varianze
[PiInit, AInit, mixmat, Mu, SigmaInitDiag] =  init_mhmm(data, N , M , 'diag', 1);

% PiInit = normalise(ones(N,1));
% AInit = mk_stochastic(ones(N,N));
% [Mu, SigmaInitDiag] = mixgauss_init(N*M, data, 'diag','kmeans');
% Mu = reshape(Mu, [(F) N M]);
% SigmaInitDiag = reshape(SigmaInitDiag, [(F) (F) N M]);

Sigma=zeros(F,N,M);

 for s=1:N
    for f=1:F      
        for m=1:M
            Sigma(f,s,m)=SigmaInitDiag(f,f,s,m);
        end
    end
 end

%trovo la massima sequenza degli stati dalle medie e transizioni uniformi
%[seqQ loglik] = viterbi_path(PiInit2, AInit2,obs, MuInit2,newSigmaSegKmeans2);
[seqQ loglik] = viterbi_path(PiInit, AInit,data,Mu,Sigma,mixmat);

%stimo tramite ML le prob di transizione
Pi=zeros(N,1);
for s=1:N
    if seqQ(1,1)==s
        Pi(s,1)=1;
    end
end

A=zeros(N,N);
seqStr=num2str(seqQ);
idx= ~isspace(seqStr);
seqStr=seqStr(idx);

Num_A=zeros(N,N);
Den_A=zeros(N,N);

for i=1:N
    for j=1:N
   
        Num_A(i,j)=size(findstr(seqStr,[num2str(i),num2str(j)]),2);
        
        Den_A(i,j)=size(findstr(seqStr(1:size(seqStr,2)-1),num2str(i)),2);
        
        A(i,j)=Num_A(i,j) / Den_A(i,j);
    end
end

end
