function [ seq_prob_cont seq_prob_cont_mix  ] = eval_pdf_cont( O,Mu,Sigma,mixmat,t,varargin )
%EVAL PDF CONTINUOS returns for each time the probability of each state having
%observed O (o_t sample by normal distribution)
%INPUT O : observations (F X T)
%      Mu : (FxN) o (FxNxM) (num.features x states) (num.features x states x mixture)
%      Sigma : (FxN) o (F X N X M) (num.features x states) o (num.features x states x mixture)  
%      mixmat : (N x M) mixture probabilities 
%      t : eval util time t of the sequence 
%      Optional st state, if set st return only the probability of state s
%      at time t 
%OUTPUT seq_prob_cont matrix (N x T) (states X sequence)
%       seq_prob_cont(i,t) = Pr(O(t)| Q(t)=i) 
%       seq_prob_cont_mix (N x M x T) = Pr(O(t) | Q(t)=i, M(t)=k) 


T=size(O,2);
F=size(O,1);
M=size(Mu,3);

if (t>T)
    error('t must be less than the number of observations');
end

if (size(varargin,2)>0)
    st=varargin{1};
    seq_prob_cont=1;
    seq_prob_cont_mix=zeros(1,M,1);
    
    if M==1
        for f=1:F
            seq_prob_cont=seq_prob_cont*normpdf(O(f,t),Mu(f,st),sqrt(Sigma(f,st)));            
        end
        
    else
                
        for f=1:F
            
            muTmp=zeros(M,1);
            sigmaTmp=zeros(1,1,M);
            mix=zeros(1,M);                    
            
            for m=1:M
                muTmp(m,1)=Mu(f,st,m);
                sigmaTmp(:,:,m)=sqrt(Sigma(f,st,m));
                mix(1,m)=mixmat(st,m);
                
                seq_prob_cont_mix(1,m,1)=normpdf(O(f,t),Mu(f,st,m),sqrt(Sigma(f,st,m)));            
            end
            
           contrZero=find(mix~=0);
           sizDivZer=size(contrZero,2);
            
           if sizDivZer~=M
               
                muTmp=zeros(sizDivZer,1);
                sigmaTmp=zeros(1,1,sizDivZer);
                mix=zeros(1,sizDivZer);
                
                for m=1:sizDivZer                           
                            muTmp(m,1)=Mu(f,st,contrZero(m));
                            sigmaTmp(:,:,m)=sqrt(Sigma(f,st,contrZero(m)));
                            mix(1,m)=mixmat(st,contrZero(m));                            
                end
                        
                objDis = gmdistribution(muTmp,sigmaTmp,mix);            
                seq_prob_cont=seq_prob_cont*pdf(objDis,O(f,t));
                                                
           else
                        
                 objDis = gmdistribution(muTmp,sigmaTmp,mix);            
                 seq_prob_cont=seq_prob_cont*pdf(objDis,O(f,t));
                    
           end
            
            
            
        end
    end
    
    
else
   
    N=size(Mu,2);
    seq_prob_cont=zeros(N,t);
    seq_prob_cont_mix=zeros(N,M,t);    
    
    if M==1
        
        for t2=1:t
            for s=1:N
                seq_prob_cont(s,t2)=1;
                for f=1:F
                    seq_prob_cont(s,t2)=seq_prob_cont(s,t2)*normpdf(O(f,t2),Mu(f,s),sqrt(Sigma(f,s)));
                end
            end

        end
        
    else        

        for t2=1:t
            for s=1:N
                
                seq_prob_cont(s,t2)=1;     
                
                for f=1:F
                    
                    muTmp=zeros(M,1);
                    sigmaTmp=zeros(1,1,M);
                    mix=zeros(1,M);
                    
                    for m=1:M
                        muTmp(m,1)=Mu(f,s,m);
                        sigmaTmp(:,:,m)=sqrt(Sigma(f,s,m));
                        mix(1,m)=mixmat(s,m);
                        seq_prob_cont_mix(s,m,t2)=normpdf(O(f,t2),Mu(f,s,m),sqrt(Sigma(f,s,m)));
                    end
                    
                    %disp(mix);
                    
                    contrZero=find(mix~=0);
                    sizDivZer=size(contrZero,2);
                    
                    if sizDivZer~=M
                        
                        muTmp=zeros(sizDivZer,1);
                        sigmaTmp=zeros(1,1,sizDivZer);
                        mix=zeros(1,sizDivZer);
                        
                        for m=1:sizDivZer                           
                            muTmp(m,1)=Mu(f,s,contrZero(m));
                            sigmaTmp(:,:,m)=sqrt(Sigma(f,s,contrZero(m)));
                            mix(1,m)=mixmat(s,contrZero(m));                            
                        end
                        
                        objDis = gmdistribution(muTmp,sigmaTmp,mix);            
                        seq_prob_cont(s,t2)=seq_prob_cont(s,t2)*pdf(objDis,O(f,t2));
                                                
                    else
                        
                        objDis = gmdistribution(muTmp,sigmaTmp,mix);            
                        seq_prob_cont(s,t2)=seq_prob_cont(s,t2)*pdf(objDis,O(f,t2));
                    
                    end
                    
                    
                    
                end                
                
            end

        end
        
    
    end
    
    
end

end

