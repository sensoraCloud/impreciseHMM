function [ PiNew,ANew,loglik,beta,alpha,gamma,xi_summed,varargout ] = em_step( O,Pi0,A0,varargin )
%EMSTEP Find the parameters of an HMM with discrete or continuos outputs using EM step 
%INPUT O : observations (F X T)
%      Pi0 : prior probability
%      A0 :  transition matrix  
%      loglik: P(O|new model)
%      Optional Mu0,Sigma0 if continuos observation or B0 if discrete observation 
%OUTPUT  PiNew; re-stimed prior; ANew: re-stimed transition matrix ,
%MuNew,SigmaNew: re-stimed Gaussians parameter for conitnuos outputs; Bnew re-stimed emission
%probabilities for discrete outputs

%init

F=size(O,1);
N=size(A0,1);
T=size(O,2);


if (size(varargin,2)>1)
    Mu0=varargin{1};
    Sigma0=varargin{2};
    MuNew=zeros(F,N);
    SigmaNew=zeros(F,N);
    C=1;    
else 
    B0=varargin{1};
    M=size(B0,2);
    Bnew=zeros(N,M,F);
    C=0;   
end 

gamma=zeros(N,T);
alpha = zeros(N,T);
beta = zeros(N,T);
xi_summed = zeros(N,N);

% scale(t) = Pr(O(t) | O(1:t-1)) = 1/c(t) as defined by Rabiner (1989).
scale = ones(1,T);

%get state probabilities for each t=1..t having O
 if C==1
        seq_prob=eval_pdf_cont( O,Mu0,Sigma0,T);   
 else
        seq_prob=eval_pdf_dis( O,B0,T );       
 end

    %Forwards

    t = 1;

    alpha(:,1) = Pi0(:) .* seq_prob(:,t);

    [alpha(:,t), scale(t)] = normalize(alpha(:,t));

    for t=2:T

        % sum_i { a_ij * alpha_j(t) } for each state
        m=A0' * alpha(:,t-1);
        % sum_i { a_ij * alpha_j(t) * b_j(t) } for each state
        alpha(:,t)=m(:) .* seq_prob(:,t);
        %set column sum to 1 for underflow problem
        [alpha(:,t), scale(t)] = normalize(alpha(:,t));

    end

    if any(scale==0)
       loglik = -inf;
    else
       loglik = sum(log(scale));
    end

    %Backwards

    beta(:,T) = ones(N,1);

    gamma(:,T) = normalize(alpha(:,T) .* beta(:,T));

    for t=T-1:-1:1

     b = beta(:,t+1) .* seq_prob(:,t+1);

     beta(:,t) = A0 * b;

     beta(:,t) = normalize(beta(:,t));

     gamma(:,t) = normalize(alpha(:,t) .* beta(:,t));

     xi_summed = xi_summed + normalize((A0 .* (alpha(:,t) * b')));

    end

    %PiNew
    PiNew = normalize(gamma(:,1));

    %ANew
    ANew = stochastic_matrix(xi_summed);  

    if C==0

        % Bnew
        
        for f=1:F
            if T < M
                  for t=1:T
                    m = O(f,t);
                    Bnew(:,m,f) = gamma(:,t) ./ (sum(gamma(:,:),2));
                 end
            else
               for m=1:M
                 indx = find(O(f,:)==m);
                 if ~isempty(indx)
                   Bnew(:,m,f) =  sum(gamma(:, indx), 2) ./ (sum(gamma(:,:),2));
                 end
               end
            end
             %Bnew(:,:,f) = stochastic_matrix(Bnew(:,:,f));
        end

    else

         % MuNew
        for f=1:F
            for s=1:N                
                MuNew(f,s)= (gamma(s,:) * O(f,:)') * ( 1 / sum(gamma(s,:)) );
            end
        end


        % SigmaNew
        for s=1:N
            for f=1:F
                SigmaNew(f,s)= sum( (O(f,:) - MuNew(f,s)).^2 .* gamma(s,:) ) * 1 / sum(gamma(s,:));     
                if SigmaNew(f,s)<0.0001,
                   SigmaNew(f,s)=0.0001;
                end;
            end
        end    
    end


if C==1
    varargout{1}=MuNew;
    varargout{2}=SigmaNew;
else
    varargout{1}=Bnew;
end

end
    
   

