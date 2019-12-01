function [init_state_prob, transmat, mixmat, mu, Sigma] =  init_peakseek_mhmm(data, Q, M, cov_type, left_right,locsMIN)
% INIT_MHMM Compute initial param. estimates for an HMM with mixture of Gaussian outputs.
% [init_state_prob, transmat, obsmat, mixmat, mu, Sigma] = init_mhmm(data, Q, M, cov_type, left_right)
%
% Inputs:
% data(:,t,l) = observation vector at time t in sequence l
% Q = num. hidden states
% M = num. mixture components
% cov_type = 'full', 'diag' or 'spherical'
% left_right = 1 if the model is a left-to-right HMM, 0 otherwise
%
% Outputs:
% init_state_prob(i) = Pr(Q(1) = i)
% transmat(i,j) = Pr(Q(t+1)=j | Q(t)=i)
% mixmat(j,k) = Pr(M(t)=k | Q(t)=j) where M(t) is the mixture component at time t
% mu(:,j,k) = mean of Y(t) given Q(t)=j, M(t)=k
% Sigma(:,:,j,k) = cov. of Y(t) given Q(t)=j, M(t)=k

O = size(data, 1);
T = size(data, 2);
nex = size(data, 3);
data = reshape(data, [O T*nex]);
init_state_prob = normalise(ones(Q,1));
transmat = mk_stochastic(ones(Q,Q));
mixmat=1;


step=size(locsMIN,2)+1;

stateData=cell(1,step);

for seg=1:step
   
    if seg==1
       stateData{1,seg}=data(:,1:(locsMIN(seg)));
    elseif   seg==step
        stateData{1,seg}=data(:,locsMIN(seg-1)+1:end);
    else
        stateData{1,seg}=data(:,(locsMIN(seg-1)+1):locsMIN(seg));
    end
    
end

numIntState=round(step/Q);
current=1;

for s=1:Q
   
    if s==Q
        for st=1:((step-current)+1)
            if st==1 
                obs=stateData{1,current};
                 disp(current)
            else
                obs=[obs stateData{1,current+1}];
                disp(current+1)
            end
        end
    else
        for st=1:numIntState
            if st==1 
                obs=stateData{1,current};
                disp(current)
            else
                obs=[obs stateData{1,current+1}];
                disp(current+1)
            end
        end
    end
    
    current=current+numIntState;
    
    % Initialize using K-means, where K = Q*M
    % We should really segment the sequence uniformly into Q strips,
    % and run M-means on each segment.
    mix = gmm(O, 1, cov_type);
    options = foptions;
    max_iter = 50;
    options(14) = max_iter;
    mix = gmminit(mix, obs', options);
    mu(:,s) = reshape(mix.centres', [O 1 1]);
    
    switch cov_type
      case 'diag',
	Sigma(:,:,s,1) = diag(mix.covars(1,:));
      case 'full',
	Sigma(:,:,s,1) = mix.covars(:,:,1);
      case 'spherical',
	Sigma(:,:,s,1) = mix.covars(1) * eye(O);
    end
    
end