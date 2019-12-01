function [ results ] = get_set_feature_selection( cmd,labels,data,n_fold,setFeatureFileName )
%FEATURE SELECTION find best set of features that maximize accuracy with
%n-fold classification only for SVM (sequential forward selection(SFS))
%OUTPUT results: (also write results file in setFeatureFileName )
% results{1,1}=featuresIndex; (ordered feature SFS selection)
% results{1,2}=festAcc; (accuracy of each step selection)
% results{1,3}=theBestFeatureIndex;  (the best minor accuracy set feature) 
% results{1,4}=theBestCV; (accuracy of the best set feature) 
% results{1,5}=cmd; (cmd used for cross validation) 

numFeat=size(data,2);

dFadd=[];
%featuresIndex=zeros(1,numFeat);
festAcc=zeros(1,numFeat);
theBestCV=-inf;
theBestFeatureIndex=[];
%leave-one-out
if n_fold==0
   cmd = [cmd,' -v ', num2str(numFeat)];        
else
   cmd = [cmd,' -v ', num2str(n_fold)];
end

index=1:numFeat;

oldBestCV=-inf;
incBestCVugual=0;

for f=1:numFeat
    
    disp(num2str(f));
    
    bestcv=-inf;
    
    sizIndex=size(index,2);
    
    for j=1:sizIndex
        
        dTemp=[ dFadd data(:,index(j))];
        
        cv = svmtrain(labels, dTemp , cmd);    
        
        if (cv > bestcv),
            
          bestcv = cv;
          bestF = index(j);  
          bestFindex=j;
          
          featuresIndex(1,f)=index(j);
          festAcc(1,f)=bestcv;
          
          if bestcv>=theBestCV
              
              theBestCV=bestcv;
              theBestFeatureIndex=featuresIndex;
              
              disp(['Best Accuracy: ',num2str(theBestCV),' Feature Index: ', num2str(featuresIndex) ] );
              
          end
          
        end        
        
    end
    
   
    dFadd=[ dFadd data(:,bestF)];
    
    index(bestFindex)=[];    
       
     if theBestCV==oldBestCV 
          incBestCVugual=incBestCVugual+1;
     else
         incBestCVugual=0;
     end
        
    oldBestCV=theBestCV;
    
    if incBestCVugual>10 
          break;
    end
        
%     if bestcv==100 
%           break;
%     end
    
end

disp(theBestFeatureIndex);

results{1,1}=featuresIndex;
results{1,2}=festAcc;
results{1,3}=theBestFeatureIndex;
results{1,4}=theBestCV;
results{1,5}=cmd;

save(setFeatureFileName,'results');

end

