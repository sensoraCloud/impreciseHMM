function [path loglik] = viterbi_path(Pi, A,O, varargin)
% VITERBI Find the most-probable (Viterbi) path through the HMM state trellis.
% path = viterbi(prior, transmat, obslik)
%
% Inputs:
% Pi prior(i) = Pr(Q(1) = i)
% A transmat(i,j) = Pr(Q(t+1)=j | Q(t)=i)
% O Observations
% Optional Mu0,Sigma0,mixmat if continuos observation or B0 if discrete
%      observation 
% Outputs:
% path(t) = q(t), where q1 ... qT is the argmax of the above expression.
% loglik 

% delta(j,t) = prob. of the best sequence of length t-1 and then going to state j, and O(1:t)
% psi(j,t) = the best predecessor state, given that we ended up in state j at t


   
    N=size(A,1);
    T=size(O,2);

    if (size(varargin,2)>1)
        Mu=varargin{1};
        Sigma=varargin{2};   
        mixmat=varargin{3};
        F=size(Mu,1);
        M=size(Mu,3);
        C=1;    
    else 
        B=varargin{1};         
        C=0;   
    end 


    if C==1
        %seq_prob=eval_pdf_cont( O,Mu,Sigma,mixmat,T);   
        SigmaTool=zeros(F,F,N,M);
        
        for s=1:N
              for f=1:F      
                   for m=1:M
                        SigmaTool(f,f,s,m)=Sigma(f,s,m);
                   end
              end
         end
        
        [seq_prob, seq_prob_mix] = mixgauss_prob(O, Mu, SigmaTool, mixmat );
        
    else
        seq_prob=eval_pdf_dis( O,B,T );       
    end


    scaled = 1;

    % T = size(obslik, 2);
    % prior = prior(:);
    % Q = length(prior);

    delta = zeros(N,T);
    psi = zeros(N,T);
    path = zeros(1,T);
    scale = ones(1,T);


    t=1;
    delta(:,t) = Pi(:) .* seq_prob(:,t);

    if scaled
      [delta(:,t), n] = normalize(delta(:,t));
      scale(t) = 1/n;
    end

    psi(:,t) = 0; % arbitrary value, since there is no predecessor to t=1

    for t=2:T
      for j=1:N
        [delta(j,t), psi(j,t)] = max(delta(:,t-1) .* A(:,j));
        delta(j,t) = delta(j,t) * seq_prob(j,t);
      end
      if scaled
        [delta(:,t), n] = normalize(delta(:,t));
        scale(t) = 1/n;
      end
    end
    [p, path(T)] = max(delta(:,T));
    for t=T-1:-1:1
      path(t) = psi(path(t+1),t+1);
    end

    % If scaled==0, p = prob_path(best_path)
    % If scaled==1, p = Pr(replace sum with max and proceed as in the scaled forwards algo)
    % Both are different from p(data) as computed using the sum-product (forwards) algorithm
  
    if scaled
      loglik = -sum(log(scale));
      %loglik = prob_path(prior, transmat, obslik, path);
    else
      loglik = log(p);
    end
    
end
