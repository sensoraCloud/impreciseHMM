addpath('class');
addpath('libsvm-mat-3.0-1');
addpath('initParam');
addpath('hmmTool');

N=14;
F=32;
M=1;
s=10;

%1 snippet(500 + 500),2 istogrammi
typeFeatures=2;


%TEST
datasetName='Triplicate-dataset-robust-Norm-Smooth5';

dirName=fullfile(datasetName,['models_','',num2str(N),'','N_','',num2str(F),'','F_',num2str(M),'M_',num2str(s),'s']);
 
FileDatasetName=fullfile('src','features',[datasetName,'.mat']);

if exist(fullfile('src',dirName),'dir') ~= 7
    mkdir('src',dirName);
end

% modelsFileNameImprecise=fullfile('src',dirName,'modelsImprecise.mat');
% modelsFileNamePrecise=fullfile('src',dirName,'modelsPrecise.mat');
% 
% if exist(modelsFileNameImprecise,'file') ~= 2
%     %learn models and generates models file learnModels(
%     %featuresFileName,modelsFileName,N,F,C,varargin )
%         
%     [ modelsPrecise modelsImprecise  ] =learnModels(FileDatasetName,modelsFileNamePrecise,modelsFileNameImprecise,N,F,M,1,[],s,typeFeatures);
% else
%     modelsPrecise =importdata(modelsFileNamePrecise);
%     modelsImprecise =importdata(modelsFileNameImprecise);
% end

%TRAIN
datasetName='Triplicate-Features-wei-hof';

dirName=fullfile(datasetName,['models_','',num2str(N),'','N_','',num2str(F),'','F_',num2str(M),'M_',num2str(s),'s']);
 
FileDatasetNameTrain=fullfile('src','features',[datasetName,'.mat']);

if exist(fullfile('src',dirName),'dir') ~= 7
    mkdir('src',dirName);
end

modelsFileNameImprecise=fullfile('src',dirName,'modelsImprecise.mat');
modelsFileNamePrecise=fullfile('src',dirName,'modelsPrecise.mat');

if exist(modelsFileNameImprecise,'file') ~= 2
    %learn models and generates models file learnModels(
    %featuresFileName,modelsFileName,N,F,C,varargin )
    
    [ modelsPreciseTrain modelsImpreciseTrain  ] =learnModels(FileDatasetNameTrain,modelsFileNamePrecise,modelsFileNameImprecise,N,F,M,1,[],s,typeFeatures);
else
    modelsPreciseTrain =importdata(modelsFileNamePrecise);
    modelsImpreciseTrain =importdata(modelsFileNameImprecise);
end



typeClassification=3;

if typeClassification==3 %interval dominance

    %confusion_matrix_imprecise_precise=zeros(cls,cls); 
%     confusion_matrix_imprecise_single=zeros(cls,cls);
%     confusion_matrix_imprecise_multiple=zeros(cls,cls);
%     confusion_matrix_precise_single=zeros(cls,cls);
%     confusion_matrix_precise_multiple=zeros(cls,cls);
    countSample=1;
%     %numberOfclasses=zeros(1,cls*mdl);
%     countNumClass=0;
%     numberSingleClass=0;
    
        
else

    %confusion_matrix_imprecise=zeros(cls,cls);  

end

%confusion_matrix_precise=zeros(cls,cls);     

fts=importdata(FileDatasetName);

mdl=size(fts,2);
cls=size(fts,1);

n_fold=0;

%Leave-one-out
if n_fold==0
    
        for c=1:cls

                 for m=1:mdl
                     
                     %walk
                     realClass=7;  
                     %realClass=c;  
                     
                     
                    %O=[fts{c,m}(1:F,:) ; fts{c,m}(501:(500+F),:)];
                    O=fts{c,m}(1:F,:);                    
                    
                    [ classPrecise ] = probabilisticHMM_classify_model( modelsPreciseTrain , O );
                    
                    [ classImprecise ] = probabilisticImprecise_HMM_classify_model( modelsImpreciseTrain ,O,typeClassification );                    
                    
                    
                    if typeClassification==3 %interval dominance
                        
                        
                        classification_classes_results{1,1}(countSample,1)=realClass;
                        classification_classes_results{1,2}(countSample,1)=classPrecise;
                        classification_classes_results{1,3}{countSample,1}=classImprecise;
                        
%                         numClass=size(classImprecise,2);
%                         
%                         if numClass>1%more class
%                             
%                             countNumClass=countNumClass+1;
%                             numberOfclasses(1,countNumClass)=numClass;                            
%                             
%                             if sum(classImprecise==c)>0 
%                                 confusion_matrix_imprecise_multiple(realClass,realClass)=confusion_matrix_imprecise_multiple(realClass,realClass)+1; 
%                             else
%                                 confusion_matrix_imprecise_multiple(realClass,classImprecise(1,1))=confusion_matrix_imprecise_multiple(realClass,classImprecise(1,1))+1; 
%                             end
%                             
%                              confusion_matrix_precise_multiple(realClass,classPrecise)=confusion_matrix_precise_multiple(realClass,classPrecise)+1;
%                             
%                         else%single class
%                             numberSingleClass=numberSingleClass+1;
%                             confusion_matrix_imprecise_single(realClass,classImprecise)=confusion_matrix_imprecise_single(realClass,classImprecise)+1; 
%                             confusion_matrix_precise_single(realClass,classPrecise)=confusion_matrix_precise_single(realClass,classPrecise)+1;
%                         end
%                        
                        
                        countSample=countSample+1;
                        
                    else
                        %confusion_matrix_imprecise(realClass,classImprecise)=confusion_matrix_imprecise(realClass,classImprecise)+1; 
                    end
                    
                   
                    %confusion_matrix_precise(realClass,classPrecise)=confusion_matrix_precise(realClass,classPrecise)+1;                     
               

                 end
        end        
  
     
     
    
end

resultsFileName=fullfile('src',dirName,'classification_classes_results.mat');
  
save(resultsFileName,'classification_classes_results');


% s=sum(confusion_matrix_precise,2);
% 
% for i=1:size(s,1)
% 
%     confusion_matrix_precise(i,:)=confusion_matrix_precise(i,:) * 1/s(i,1);
%     
% end
% 
% accuracyPrecise=sum(diag(confusion_matrix_precise)) * 1 / cls;
% display([dirName,' precise Tot Prob : ',num2str(accuracyPrecise)]);
% 
% if typeClassification==3 %interval dominance
%    
%    display(numberSingleClass); 
%     
%    meanClasses=sum(numberOfclasses,2) / countNumClass;
%    display(meanClasses);
%    
%     s=sum(confusion_matrix_imprecise_single,2);
% 
%     for i=1:size(s,1)
% 
%         if s(i,1)~=0
%             confusion_matrix_imprecise_single(i,:)=confusion_matrix_imprecise_single(i,:) * 1/s(i,1);
%         end
%         
%     end
%     
%     accuracyImpreciseSingle=sum(diag(confusion_matrix_imprecise_single)) * 1 / cls;
%     
%     display(accuracyImpreciseSingle);
%   
%     s=sum(confusion_matrix_imprecise_multiple,2);
%     classValued=0;
%     for i=1:size(s,1)
% 
%         if s(i,1)~=0
%             
%             confusion_matrix_imprecise_multiple(i,:)=confusion_matrix_imprecise_multiple(i,:) * 1/s(i,1);
%             classValued=classValued+1;
%         end
% 
%     end
%     
%     accuracyImpreciseMultiple=sum(diag(confusion_matrix_imprecise_multiple)) * 1 / classValued;
%   
%     display(accuracyImpreciseMultiple);
%     
%     s=sum(confusion_matrix_precise_single,2);
%     classValued=0;
%     for i=1:size(s,1)
%          if s(i,1)~=0
%             confusion_matrix_precise_single(i,:)=confusion_matrix_precise_single(i,:) * 1/s(i,1);
%             classValued=classValued+1;
%          end
%     end
%     
%     accuracyPreciseSingle=sum(diag(confusion_matrix_precise_single)) * 1 / classValued;
%     
%     display(accuracyPreciseSingle);
%     
%     s=sum(confusion_matrix_precise_multiple,2);
%     classValued=0;
%     for i=1:size(s,1)
%         if s(i,1)~=0
%             confusion_matrix_precise_multiple(i,:)=confusion_matrix_precise_multiple(i,:) * 1/s(i,1);
%             classValued=classValued+1;
%         end
%     end
%     
%     accuracyPreciseMultiple=sum(diag(confusion_matrix_precise_multiple)) * 1 / classValued;
%     
%    display(accuracyPreciseMultiple);
%    
% else
%     
%     s=sum(confusion_matrix_imprecise,2);
%    
%     for i=1:size(s,1)
%        
%             confusion_matrix_imprecise(i,:)=confusion_matrix_imprecise(i,:) * 1/s(i,1);
%             
%         
%     end
%     
%     accuracyImprecise=sum(diag(confusion_matrix_imprecise)) * 1 / cls;
%     
%     display([dirName,' imprecise Prob  : ',num2str(accuracyImprecise)]);
%            
% end
% 
% 
%  %save results precise
%  resultsPrecise{1,1}=confusion_matrix_precise;
%  resultsPrecise{1,2}=accuracyPrecise;
% 
%  resultsFileName=fullfile('src',dirName,['results_precise_PROB','.mat']);
%  
%  save(resultsFileName,'resultsPrecise');
%  
%  %plot misclassification 
%  plotTests=(ones(1,cls) - diag(confusion_matrix_precise)')* 100;
%  
%  figure(1);
%  plot(1:1:cls,plotTests,'r+','linewidth',3);  
%  title(['Misclassification precise PROB percentage. Accuracy:',' ',num2str(accuracyPrecise)]);
%  xlabel('Class');
%  ylabel('Percentage');
%  
%  figName=fullfile('src',dirName,'Misclassification_precise_PROB');
%  
%  %save graph
%  saveas(1,figName,'jpg');
%  
% %plot confusion matrix
% f = figure('Position',[100 200 790 190]);
% names=cell(1,cls);
% for i=1:cls
%     names{1,i}=num2str(i);
% end
% 
% t = uitable('Parent',f,'Data',confusion_matrix_precise,'ColumnName',names,'RowName',names,'Position',[0 0 785 190]);
% 
% tabName=fullfile('src',dirName,'confusion_matrix_precise_PROB');
% 
% %save table
% saveas(f,tabName,'jpg');
% 
% 
% 
%  %save results imprecise
% 
% 
%  if typeClassification==3
%      
%      resultsImprecise{1,1}=numberSingleClass;
%      
%      resultsImprecise{1,2}=(countSample-1) - numberSingleClass;
%      
%      resultsImprecise{1,3}=meanClasses; 
%      
%      resultsImprecise{1,4}=confusion_matrix_imprecise_single;
%      resultsImprecise{1,5}=confusion_matrix_imprecise_multiple;   
%      resultsImprecise{1,6}=confusion_matrix_precise_single;
%      resultsImprecise{1,7}=confusion_matrix_precise_multiple; 
%      
%      resultsImprecise{1,8}=accuracyImpreciseSingle;
%      resultsImprecise{1,9}=accuracyImpreciseMultiple;   
%      resultsImprecise{1,10}=accuracyPreciseSingle;
%      resultsImprecise{1,11}=accuracyPreciseMultiple;   
%      resultsImprecise{1,12}=classification_classes_results;   
%      
%      resultsImprecise{1,13}=cls;   
%           
%      resultsImprecise{1,14}={'numberSingleClass' 'numberMultipleClass' 'meanClasses' 'confusion_matrix_imprecise_single' 'confusion_matrix_imprecise_multiple' 'confusion_matrix_precise_single' 'confusion_matrix_precise_multiple' 'accuracyImpreciseSingle' 'accuracyImpreciseMultiple' 'accuracyPreciseSingle' 'accuracyPreciseMultiple' 'classification_classes_results' 'numberOflabels'}; 
%      
%      resultsFileName=fullfile('src',dirName,['results_imprecise_PROB_typeClassification_',num2str(typeClassification),'.mat']);
%  
%      save(resultsFileName,'resultsImprecise');
%      
%  else
%       resultsImprecise{1,1}=confusion_matrix_imprecise;
%       resultsImprecise{1,2}=accuracyImprecise;
%      
%       resultsFileName=fullfile('src',dirName,['results_imprecise_PROB_typeClassification_',num2str(typeClassification),'.mat']);
%  
%      save(resultsFileName,'resultsImprecise');
%      
%      %plot misclassification 
%      plotTests=(ones(1,cls) - diag(confusion_matrix_imprecise)')* 100;
% 
%      figure(3);
%      plot(1:1:cls,plotTests,'r+','linewidth',3);  
%      title(['Misclassification imprecise PROB percentage. Accuracy:',' ',num2str(accuracyImprecise)]);
%      xlabel('Class');
%      ylabel('Percentage');
% 
%      figName=fullfile('src',dirName,['Misclassification_imprecise_PROB_typeClassification_',num2str(typeClassification)]);
% 
%      %save graph
%      saveas(3,figName,'jpg');
% 
%     %plot confusion matrix
%     g = figure('Position',[100 200 790 190]);
%     names=cell(1,cls);
%     for i=1:cls
%         names{1,i}=num2str(i);
%     end
% 
%     t2 = uitable('Parent',g,'Data',confusion_matrix_imprecise,'ColumnName',names,'RowName',names,'Position',[0 0 785 190]);
% 
%     tabName=fullfile('src',dirName,['confusion_matrix_imprecise_PROB_typeClassification_',num2str(typeClassification)]);
% 
%     %save table
%     saveas(g,tabName,'jpg');
%       
%  end