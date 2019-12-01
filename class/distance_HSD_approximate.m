function [ hsd ] = distance_HSD_approximate( Pi,A,mixmat,multi_features,minimum_value,stat_distr,varargin )
%GET HSD distance from HMM_1 and HMM_ref(that have F_ref(x) higher then F_hmm1(x) for each x ) (paper. "A new distance measure for Hidden Markov Models" Jianping Zeng,... )
%INPUT Pi: priors 
%      A: transition matrix
%      multi_features : if 0 get sum of distance calculated for each
%                       features and if 1 return distance of each features
%      minimum_value: minimum value considered for HMMs outcome 
%      stat_distr: [] if is empty calculate distance from precise model(calculate stationary
%      dist from Pi,A). If valued calculate distance from imprecise hidden layer
%      and use stationary dist in input stationary_prob

%OPIONAL B,alpha (for stationaries probabilities accuracy) for discrete HMM or Mu,Sigma,q,alpha,L for continuos
%HMM (q (for min max outcome accurary es. 6); alpha (for stationaries probabilities accuracy es. 1e-7); L (for distance HSD accuracy) )
%OUTPUT hsd distance. if multi_features=0 only distance value if
%multi_features=1 (1 X F) HSD distance for each features of HMMs

if (size(varargin,2)>2)
    Mu=varargin{1};
    Sigma=varargin{2};
    q=varargin{3};
    alpha=varargin{4};
    L=varargin{5};   
    F=size(Mu,1);
    C=1;    
else 
    B=varargin{1};
    alpha=varargin{2};    
    F=size(B,3);
    C=0;   
end 

%discerete  !! da sistemare.... non è forse il caso di approssimare la HSD
%discreta visto che possiamo calcolarci tutte le cumulate
if C==0

    
    %get min max HMM outcomes   
    [ min max ] = get_min_max_value( B );
    
    %get stationaries probabilities
    if isempty(stationary_prob)==1    
        [ stat_distr ] = hmm_stationary_distribution( Pi,A,alpha);        
    end
    
    
    
    
    %calculate probabilities of each outcome for each features of each
    %model p(x)= sum_(s=1..N) { Pstationary_s * p_emm_s(x) }
    
    %prob (1 X F) each (1 X M)
    prob=cell(1,F);
    
    for f=1:F
        prob{1,f}=stat_distr*B(:,:,f);
    end
    
    %calculate Cumulative
    M=size(B,2);
    Fcum=zeros(F,M);
    
    for f=1:F
        for m=1:M
            if m==1
                Fcum(f,m)=prob{1,f}(1,m);
            else
                Fcum(f,m)=Fcum(f,(m-1))+prob{1,f}(1,m);
            end            
        end
    end
    
    %calculate HSD distance
    dist=zeros(1,F);
    for f=1:F
        for m=1:M
           
           dist(1,f)=dist(1,f)+Fcum(f,m);
           
        end
         dist(1,f)=(min-minimum_value) + (max-min) - dist(1,f);
    end
    
    if (multi_features==0)
        hsd=sum(dist);
    else
        hsd = dist;
    end
        
    
else %continuos
   
    %get min max HMM outcomes   
    [ min max ] = get_min_max_value( Mu , Sigma ,  q );
        
    %get stationaries probabilities
    if isempty(stat_distr)==1
        [ stat_distr ] = hmm_stationary_distribution( Pi,A,alpha);
    end
    
    %disp(stat_distr);
    
    %dist=vpa(zeros(1,F),10);
    dist=zeros(1,F);
    
    N=size(Mu,2);
    M=size(Mu,3);
    
    %calculte comulate F_hmm(x) for   min<x<max
    for f=1:F
    
        x=min(1,f);
        
        step=(max(1,f)-min(1,f)) / L;        
        
        for i=1:L-1
            
            x=min(1,f)+i*step;
              
            %calculate stationary cumulative function
            F_x=0;
            
             if M==1
            
                %F_s(x)=sum_{i=1}^N Pi_s * int_-inf^x b_i(x)
                for s=1:N

                    F_x = F_x + stat_distr(1,s) * normcdf(x,Mu(f,s),sqrt(Sigma(f,s)));  

                end
            
             else
                 
                
                for s=1:N

                     muTmp=zeros(M,1);
                     sigmaTmp=zeros(1,1,M);
                     mix=zeros(1,M);

                     for m=1:M

                            muTmp(m,1)=Mu(f,s,m);
                            sigmaTmp(:,:,m)=sqrt(Sigma(f,s,m));
                            mix(1,m)=mixmat(s,m);

                     end

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
                            %F_s(x)=sum_{i=1}^N Pi_s * int_-inf^x b_i(x)
                            F_x = F_x + stat_distr(1,s) * cdf(objDis,x);
                            
                      else

                            objDis = gmdistribution(muTmp,sigmaTmp,mix);     
                            %F_s(x)=sum_{i=1}^N Pi_s * int_-inf^x b_i(x)
                            F_x = F_x + stat_distr(1,s) * cdf(objDis,x);

                     end
                
                end      
                 
                 
             end
                     
            dist(1,f)= dist(1,f) + F_x; 
            
        end  
        
        %F(max)
         F_max=0;
         
         if M==1
                 for s=1:N

                        F_max = F_max + stat_distr(1,s)*normcdf(max(1,f),Mu(f,s),sqrt(Sigma(f,s))); 

                 end
         else
             
                      
               for s=1:N

                     muTmp=zeros(M,1);
                     sigmaTmp=zeros(1,1,M);
                     mix=zeros(1,M);

                     for m=1:M

                            muTmp(m,1)=Mu(f,s,m);
                            sigmaTmp(:,:,m)=sqrt(Sigma(f,s,m));
                            mix(1,m)=mixmat(s,m);

                     end

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
                            F_max = F_max + stat_distr(1,s)*cdf(objDis,max(1,f));
                            
                            
                      else

                            objDis = gmdistribution(muTmp,sigmaTmp,mix);     
                            F_max = F_max + stat_distr(1,s)*cdf(objDis,max(1,f));

                     end
                
                end  
             
             
             
         end
         
         
         
         
         F_min=0;
         %F(min)
         if M==1
                 for s=1:N

                        F_min = F_min + stat_distr(1,s)*normcdf(min(1,f),Mu(f,s),sqrt(Sigma(f,s))); 

                 end
         else
             
                      
               for s=1:N

                     muTmp=zeros(M,1);
                     sigmaTmp=zeros(1,1,M);
                     mix=zeros(1,M);

                     for m=1:M

                            muTmp(m,1)=Mu(f,s,m);
                            sigmaTmp(:,:,m)=sqrt(Sigma(f,s,m));
                            mix(1,m)=mixmat(s,m);

                     end

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
                            F_min = F_min + stat_distr(1,s)*cdf(objDis,min(1,f));
                                                        
                      else

                            objDis = gmdistribution(muTmp,sigmaTmp,mix);     
                            F_min = F_min + stat_distr(1,s)*cdf(objDis,min(1,f));
                            
                     end
                
                end  
             
             
         end
                  
        
        ret=min(1,f) - minimum_value;
        
        if ret<0
            disp(['WARNING!!! minimum value is not minimum. minF: ',num2str(min(1,f)), ' minimum: ', num2str(minimum_value) ]);
        end
        
        %the composite trapezoidal rule
        dist(1,f)= ret + (max(1,f) - min(1,f)) - ( (step/2)*(F_min+F_max) + step * dist(1,f) );
        
    end

    if (multi_features==0)
        hsd=sum(dist);
    else
        hsd = dist;
    end
    
    
end


end

