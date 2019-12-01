function [ Pi_New,A_New,varargout ] = hmm_SASEM( O,Pi0,A0,Tinit,Tend,Trials,maxTempDec,a,varargin )
%SASEM Find the parameters of an HMM with discrete or continuos outputs using SASEM ( "A stochastic version of Expectation Maximization algorithm for better estimation
% of Hidden Markov Model" Shamsul Huda , John Yearwood , Roberto Togneri ) 
%INPUT O : observations (F X T)
%      Pi0 : prior probability
%      A0 :  transition matrix  
%      Tinit: Start temperature for SA
%      Tend:  Final temperature for SA
%     Trials: number of iteration for generate Neighborhood search point
%      Optional Mu0,Sigma0 if continuos observation or B0 if discrete observation 
%OUTPUT  Pi stimed prior; A stimed transition matrix ,
%Mu,Sigma stimed Gaussians parameter for conitnuos outputs; B stimed emission
%probabilities for discrete outputs

%init

F=size(O,1);
N=size(A0,1);

if (size(varargin,2)>1)
    Mu0=varargin{1};
    Sigma0=varargin{2};
    
    C=1;    
else 
%     B0=varargin{1};
%     M=size(B0,2);   
%     C=0;   
end 

converged=0;

iter = 0;

tp=1;

Temp=Tinit;

if C==1
    %Pavg_Current=Pavg( Pi0,A0,O,Mu0,Sigma0);
    Pavg_Current=log_probObs( Pi0,A0,O,Mu0,Sigma0 );
    
    Pi_Current=Pi0;
    A_Current=A0;
    Mu_Current=Mu0;
    Sigma_Current=Sigma0;
               
else
%     Pavg0=Pavg( Pi0,A0,O,B0);
%     Pi_New=Pi0;
%     A_New=A0;
%     B_New=Mu0;    
end

accCrit=1;

PavgControl=Pavg_Current;

%if likelihood next = likelihood prec
convergedLikelihoodInc=0;
maxConvergedLikelihood=10;

%if likelihood next = -inf
newLikelihoodInfInc=0;
maxLikelihoodInf=10;

%if likelihood next is not accepted
notAcceptedInc=0;
maxNotAccepted=10;

Pavg_max=-inf;  
max_temp=Temp;
Pavg_Next=-inf;

positiveDiff=0;

incrEM=0;

%if current search point not change
Pavg_old=Pavg_Current;
maxPavgCurrentConvergence=5;
incCurrentConvergenze=0;

while converged==0,
        
    for tr=1:Trials    
         
        consistent=0;
        
        iterCons=0;
        
        if tr==1
            mixParam= (1 * (  1 - (tp/maxTempDec) )^a);
            mixDec=mixParam/Trials;
        else
            %if positive the direction its true and i can do more EM in the
            %next step
            if positiveDiff>0 
                
                mixParam=mixParam-( mixDec*exp(-(1/positiveDiff)) );
                
            elseif incrEM==1
                
                mixParam=mixParam-mixDec;
                incrEM=0;
                
            end
        end
        
        %display(mixParam);
        
%         figure(1);
%         hold on;
%         plot(iter,mixParam,'--ys');
%         title('mixParam');
                
        while consistent==0,            
        
            if (iter>0 && iterCons==0)
                 Pi_Old=Pi_EM;
                 A_Old=A_EM;
                 Mu_Old=Mu_EM;
                 Sigma_Old=Sigma_EM;
                 %xi_Old=xi_EM;
                 gamma_Old=gamma_EM;
                 xi_summed_Old=xi_summed_EM;
            end
                           
            %Generate a neighbor        
            
            [ Pi_EM,A_EM,loglik,beta_EM,alpha_EM,gamma_EM,xi_summed_EM,xi_EM,Mu_EM,Sigma_EM] = em_step( O,Pi_Current,A_Current,Mu_Current,Sigma_Current);
            
            %Pavg_EM=Pavg( Pi_EM,A_EM,O,Mu_EM,Sigma_EM);
            Pavg_EM=log_probObs( Pi_EM,A_EM,O,Mu_EM,Sigma_EM); 
            
            if iter==0
                 
                %Pavg_Current=Pavg_EM;
                 if Pavg_EM>Pavg_Current
                     
                    Pavg_max=Pavg_EM;
                    max_model=[ {Pi_EM} {A_EM} {Mu_EM} {Sigma_EM}];
                    
                 else
                     
                    Pavg_max=Pavg_Current;
                    max_model=[ {Pi_Current} {A_Current} {Mu_Current} {Sigma_Current}];
                    
                    Pi_Current=Pi_EM;
                    A_Current=A_EM;
                    Mu_Current=Mu_EM;
                    Sigma_Current=Sigma_EM;
                    Pavg_Current=Pavg_EM;
                                         
                 end
                 
            end
            
            %control if generate model is consistent (if the observation is highly unlikely give init model, it may happen that the model result is too inconsistent)
            consistent  = consistentHMM( Pi_EM,A_EM );   
            
            if (consistent==0 && iter>0)
                
                %perturbe init 
                seqQ = sequenceHiddenStateGenerator( Pi_Old,A_Old,size(O,2));               
                
                [Pi_Current,A_Current,Mu_Current,Sigma_Current]=get_SASEM_HMM(Pi_Old,A_Old,gamma_Old,xi_summed_Old,Mu_Old,Sigma_Old,seqQ,O,mixParam);
                
            end
        
            
            if ( (iter==0 && (Pavg_EM==-inf || consistent==0 ) ) || (iterCons>4))
           
                %reinit random EM
                [ Pi_Current,A_Current,Mu_Current,Sigma_Current ] = hmmGenerator( N, 1 , F);     
                %random interval init
                [Mu_Current Sigma_Current]=init_Mu_Sigma( O , N );
                
                consistent=0;
                
                iterCons=1;
                
            end  
            
            iterCons=iterCons+1;
            
        end
                    
        %generate sample of hidden state on distribution xi
        seqQ = sequenceHiddenStateGenerator( Pi_EM,A_EM,size(O,2)); 

        %find SASEM parameter of neighbor (using ML estimation on seqQ and
        %O (using count method))        
                
        [Pi_SASEM,A_SASEM,Mu_SASEM,Sigma_SASEM]=get_SASEM_HMM(Pi_EM,A_EM,gamma_EM,xi_summed_EM,Mu_EM,Sigma_EM,seqQ,O,mixParam);
        
        %Pavg_Next=Pavg( Pi_SASEM,A_SASEM,O,Mu_SASEM,Sigma_SASEM);
        Pavg_Next=log_probObs( Pi_SASEM,A_SASEM,O,Mu_SASEM,Sigma_SASEM);
        
        %inf new search point have loglik -inf try random model
        if Pavg_Next==-inf
            [ Pi_SASEM,A_SASEM,Mu_SASEM,Sigma_SASEM ] = hmmGenerator( N,C,F ); 
            Pavg_Next=log_probObs( Pi_SASEM,A_SASEM,O,Mu_SASEM,Sigma_SASEM);
        end
        
%         diffPavg(iter+1)=abs(Pavg_Next-Pavg_Current);        
        
        positiveDiff=Pavg_Next-Pavg_Current;
        
%         display(positiveDiff);
        
%         figure(2);
%         hold on;
%         plot(iter,Pavg_Next-Pavg_Current,'--rs');
%         title('Diff likelihood');
                
        if Pavg_Next~=-inf
            
            newLikelihoodInfInc=0;
           
             if Pavg_Next>Pavg_Current
                 
                %accepted
                notAcceptedInc=0;
                Pi_Current=Pi_SASEM;
                A_Current=A_SASEM;
                Mu_Current=Mu_SASEM;
                Sigma_Current=Sigma_SASEM;
                Pavg_Current=Pavg_Next;
                
                if Pavg_Next>Pavg_max
                        Pavg_max=Pavg_Next;
                        max_model=[ {Pi_SASEM} {A_SASEM} {Mu_SASEM} {Sigma_SASEM}];
                        max_temp=Temp;
                end 
                
             else

                rn=rand(1,1);

                if Pavg_Next==Pavg_Current
                    
                    accCrit=1;
                    
                    if Pavg_Next==PavgControl
                        convergedLikelihoodInc=convergedLikelihoodInc+1;
                    else
                        convergedLikelihoodInc=0;
                    end
                    
                    %stop
                    if convergedLikelihoodInc>maxConvergedLikelihood
                       tp=maxTempDec;
                       break;
                    end
                    
                    PavgControl=Pavg_Next;
    
                else                
                    accCrit=exp(-( (Pavg_Current - Pavg_Next)/Temp ));  
                end

%                 display(accCrit);
%                 
%                 figure(4);
%                 hold on;
%                 plot(iter,accCrit,'--gs');
%                 title('accCrit');

                if min(1,accCrit)>=rn
                    %accepted
                    notAcceptedInc=0;
                    Pi_Current=Pi_SASEM;
                    A_Current=A_SASEM;
                    Mu_Current=Mu_SASEM;
                    Sigma_Current=Sigma_SASEM;
                    Pavg_Current=Pavg_Next;   
                else
                    %not accepted
                    
                    notAcceptedInc=notAcceptedInc+1;
                    
                    %stop
                    if notAcceptedInc>maxNotAccepted
                       tp=maxTempDec;
                       break;
                    end
                    
                    if Pavg_EM>=Pavg_Current
                 
                        incrEM=1;
                        notAcceptedInc=0;
                        
                        Pi_Current=Pi_EM;
                        A_Current=A_EM;
                        Mu_Current=Mu_EM;
                        Sigma_Current=Sigma_EM;
                        Pavg_Current=Pavg_EM;
                        
                        if Pavg_EM>Pavg_max
                                Pavg_max=Pavg_EM;
                                max_model=[ {Pi_EM} {A_EM} {Mu_EM} {Sigma_EM}];
                                max_temp=Temp;
                        end 

                    else
                        incrEM=0;
                    end
                    
                end

            end
                        
        else
            
           newLikelihoodInfInc=newLikelihoodInfInc+1;
           
           %stop
           if newLikelihoodInfInc>maxLikelihoodInf
              tp=maxTempDec;
              break;
           end
                
           if Pavg_EM>=Pavg_Current
               
                incrEM=1;
                newLikelihoodInfInc=0; 
                notAcceptedInc=0;
                
                Pi_Current=Pi_EM;
                A_Current=A_EM;
                Mu_Current=Mu_EM;
                Sigma_Current=Sigma_EM;
                Pavg_Current=Pavg_EM;
                
                if Pavg_EM>Pavg_max
                        Pavg_max=Pavg_EM;
                        max_model=[ {Pi_EM} {A_EM} {Mu_EM} {Sigma_EM}];
                        max_temp=Temp;
                end 
                
           else
                incrEM=0;
           end
           
           
        end
        
        iter = iter + 1;
    
%         figure(3);
%         hold on;
%         plot(iter,Pavg_Current,'--bs');
%         title('Pavg_Current');
                
        
        if Pavg_old==Pavg_Current
        
            incCurrentConvergenze=incCurrentConvergenze+1;

            %stop
            if incCurrentConvergenze>maxPavgCurrentConvergence
                 tp=maxTempDec;
                 break;
            end

        else
                
            incCurrentConvergenze=0;  
            
        end


        Pavg_old=Pavg_Current; 
                
        
    end
   
        
    %inizialmente decade lentamente poi sempre piu velocemente a amplifica
    %la discesa. se tp=maxTempDec --> Temp=0
    Temp=Tinit * (  1 - (tp/maxTempDec) )^a; 
    
%     display(Temp);
    
    tp = tp + 1;
    
%     display(tp);
    
    
    if (Temp<=Tend)
        converged=1;
    end
    
end

% display(sum(diffPavg) / size(diffPavg,2)); 

% display(max_temp);

display(['SASEM Learned in ',num2str(iter),' iterations!']);

%do EM on max model founded
[ Pi_EM,A_EM,Mu_EM,Sigma_EM,log_lik_EM ] = hmm_EM( O,max_model{1},max_model{2},15,max_model{3},max_model{4} );


if C==1
 
%     Pi_New=max_model{1};
%     A_New=max_model{2};
%     varargout{1}=max_model{3};
%     varargout{2}=max_model{4};

    if ( (Pavg_max<log_lik_EM) && (consistentHMM( Pi_EM,A_EM )==1))
        
        Pi_New=Pi_EM;
        A_New=A_EM;
        varargout{1}=Mu_EM;
        varargout{2}=Sigma_EM;
        varargout{3}=log_lik_EM;
        
    else
        Pi_New=max_model{1};
        A_New=max_model{2};
        varargout{1}=max_model{3};
        varargout{2}=max_model{4};
        varargout{3}=Pavg_max;
    end
    
    %varargout{1}=Mu_New;
    %varargout{2}=Sigma_New;
    %varargout{3}=new_log_lik;
else
    varargout{1}=B_New;
    %varargout{2}=new_log_lik;
end
    
end