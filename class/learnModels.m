function [ modelsPrecise modelsImprecise  ] = learnModels( featuresFileName,modelsFileNamePrecise,modelsFileNameImprecise,N,F,M,C,featSelect,s,typeFeatures,varargin )
%LEARN MODELS Find the parameters of HMMs with continuos outputs using EM
%INPUT featuresFileName : name file features: ( Class X Test ) each Test: (Features X Time)
%      N : hidden states
%      F : number of features considered (F*2)  features[1-F][501+F]
%      C : learn discrete model C=0 or continuos model C=1
%      featSelect: set of feature index (if empty don't use it)
%OPTIONAL M (number of possible output value) if discrete learning
%OUTPUT models: ( Class X models) each
%models ( [ Pi , A, Mu, Sigma ] ) and write file with name modelsFileName
%contains models

%init

if (size(varargin,2)>0)
    M=varargin{1};
end

fts=importdata(featuresFileName);

cls=size(fts,1);
mdls=size(fts,2);

%take max log-likelihood of n different init learning
n=3;
max_EM_iterations=30;

max_modelPrecise=[];
max_modelImprecise=[];



for c=1:cls
    
    countEmpty=0;
    
    for m=1:mdls
        
        %discrete DA RISISTEMARE come CONTINUO!!
        if C==0
            
            %take first f features (shape features) and 500 + F features (movement features)
            obs=[fts{c,m}(1:F,:) ; fts{c,m}(501:(500+F),:)];
            
            F=size(obs,1);
            
            if ~isempty(featSelect)
                obs=obs(featSelect);
            end
            
            [ PiInit,AInit,BInit ] = hmmGenerator( N, 0 , F  , M );
            
            [ iPiInit,iAInit,BInit ] = hmm_EM( obs,PiInit,AInit,max_EM_iterations,s,BInit );
            
            models{c,m}=[ {PiInit} {AInit} {BInit} ];
            
        else %continuos
            
            if  ~isempty(fts{c,m})
                typeFeatures = 2;
                %snippet
                if typeFeatures==1                
                    %snippet
                    obs=[fts{c,m}(1:F,:) ; fts{c,m}(501:(500+F),:)];
                else
                    obs=fts{c,m}(1:F,:);
                end
                
                %obs=[fts{c,m}(1:F,:) ; fts{c,m}(201:(200+F),:)];
                
                %obs=fts{c,m}(1:F,:);
                
                %obs=[fts{c,m}(1:F,:) ; fts{c,m}(223:(222+F),:)];
                
                %all features
                %obs=fts{c,m};
                
                %only movement
                %obs=fts{c,m}(501:(500+F),:);
                
            else
                obs=[];
                countEmpty=countEmpty+1;
            end
            
            if  ~isempty(obs)
                
                if ~isempty(featSelect)
                    obs=obs(featSelect,:);
                end
                
                max_log_lik=-inf;
                
                F2=size(obs,1);
                
                correct=0;
                
                numMaxCorrect=0;
                
                while correct==0,
                    
                    numNan=0;
                    
                    numMaxCorrect=numMaxCorrect+1;
                    
                    typeInit=0;
                    
                    for i=1:n
                        
                        if numMaxCorrect<2
                            
                            if typeInit<2
                                
                                [PiInit, AInit, MuInit, SigmaInit,mixmatInit] =  init_segment_kmeans(obs,M, N);
                                
                                consistent  = consistentHMM( PiInit,AInit );
                                
                                if consistent==0
                                    %uniform
                                    PiInit=ones(N,1) ./ N;
                                    AInit=ones(N,N) ./ N;
                                end
                                
                            elseif typeInit<3
                                
                                [PiInit, AInit, MuInit, SigmaInit,mixmatInit] =  init_segment_kmeans(obs,M, N);
                                %uniform
                                PiInit=ones(N,1) ./ N;
                                AInit=ones(N,N) ./ N;
                                
                            else
                                
                                %random
                                [MuInit SigmaInit]=init_Mu_Sigma( obs ,N,M );
                                PiInit=ones(N,1) ./ N;
                                AInit=ones(N,N) ./ N;
                                
                                typeInit=0;
                                
                            end
                            
                            
                        else
                            %random
                            [MuInit SigmaInit]=init_Mu_Sigma( obs ,N,M );
                            PiInit=ones(N,1) ./ N;
                            AInit=ones(N,N) ./ N;
                            
                        end
                        
                        [ iPiInit,iAInit,Pi,A,mixmat,MuInit,SigmaInit,log_lik ] = hmm_EM( obs,PiInit,AInit,mixmatInit,max_EM_iterations,s,MuInit,SigmaInit );
                        
                        if (isnan(log_lik)) || (log_lik==-inf)
                            numNan=numNan+1;
                        end
                        
                        modelsTestImprecise{i}=[ {iPiInit} {iAInit} {MuInit} {SigmaInit} {mixmat} ];
                        modelsTestPrecise{i}=[ {Pi} {A} {MuInit} {SigmaInit} {mixmat} ];
                        
                        %log_lik is log-likelihood of precise model
                        if log_lik>max_log_lik
                            max_log_lik=log_lik;
                            max_modelPrecise=modelsTestPrecise{i};
                            max_modelImprecise=modelsTestImprecise{i};
                        end
                        
                        
                    end
                    
                    if (numNan==n) && (numMaxCorrect<4)
                        correct=0;
                    else
                        correct=1;
                    end
                    
                    
                end
                
                if (isnan(max_log_lik)) || (max_log_lik==-inf)
                    error('Can not learn model! always -inf likelihood');
                end
                
                
                modelsImprecise{c,m-countEmpty}=max_modelImprecise;
                modelsPrecise{c,m-countEmpty}=max_modelPrecise;
                
                disp(['model: ',num2str(c),',',num2str(m-countEmpty),' learned! log-lik: ', num2str(max_log_lik)]);
                
            end
            
            
        end
        
        
    end
    
end

save(modelsFileNamePrecise,'modelsPrecise');
save(modelsFileNameImprecise,'modelsImprecise');

end

