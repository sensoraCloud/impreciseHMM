function [ accuracy confusion_matrix ] = cross_validation_HSD( n_fold,N,F,M,s,datasetName,q,alpha,L,multi_features,minimum_value,type,cmd,normalize,findBestSVMparameter,t,cFrom,cTo,cStep,gFrom,gTo,gStep,eFrom,eTo,eStep,dFrom,dTo,dStep,bestFeatureSelection,featSelectDistOnModel,uniformTrans,typeClassification,k,distance,fun,typeGenerationMultiplePoints)
%cross_validation_KL_HSD computing accuracy and confusion matrix through
%learning HMM with N hidden states considering F features (F*2..) using
% HSD and KL distance.  K-NEAREST-NEIGHBOR to classify distance. Used n_fold - cross
% validation for testing dataset.
%INPUT      n_fold:  n_fold - cross validation (if n_fold=0 use Leave-one-out validation)
%               N : hidden states (for learning)
%               F : number of features for observation (F*2)  features[1-F][501+F]
%  FileDatasetName: file name contains features: {Class X Test} each
%                       Test { ( F x T) } example.
%                       'src\features\featuresSx.mat'
%                T: number of observations generated for calculate KL distance
%                k: the number of nearest neighbors used in the classification
%  multi_features : if 0 get sum of HSD distance calculated for each
%                   features and if 1 return distance of each features
%       q,alpha,L : for calculate HSD distance for continuos HHMs
%(q (for min max outcome accurary es. 3); alpha (for stationaries
%probabilities accuracy es. 1e-7); L (for distance HSD accuracy) )
%
%OUTPUT  accuracy_KL: mean of accuracy using cross validation with KL
%                     distance
%       accuracy_HSD: mean of accuracy using cross validation with HSD
%                     distance
%confusion_matrix_KL: compare misclassification of each class from other (KL)
%confusion_matrix_HSD: compare misclassification of each class from other
%(HSD)
%
%The procedure generates: 1) models file ({Class X Model} each
%                       Model { [ Pi , A, Mu, Sigma ] }) in
%(current_directory\src\models_(N)s_(F)f\models.mat)
%                         2) results file (KL nad HSD) ({accuracy,confusion_matrix,min_distance_matrix})
% in (current_directory\src\models_(N)s_(F)f\results_HSD_(L)_L.mat) (same for KL)
%                         3) graph misclassification percentage (KL , HSD)
%(current_directory\src\models_(N)s_(F)f\Misclassification_HSD_(L)_L.jpg)

%create directory


dirName=fullfile(datasetName,['models_','',num2str(N),'','N_','',num2str(F),'','F_',num2str(M),'M_',num2str(s),'s']);

FileDatasetName=fullfile('src','features',[datasetName,'.mat']);

if exist(fullfile('src',dirName),'dir') ~= 7
    mkdir('src',dirName);
end

modelsFileNameImprecise=fullfile('src',dirName,'modelsImprecise.mat');
modelsFileNamePrecise=fullfile('src',dirName,'modelsPrecise.mat');

if exist(modelsFileNameImprecise,'file') ~= 2
    %learn models and generates models file learnModels(
    %featuresFileName,modelsFileName,N,F,C,varargin )
    featSelec=[];
    
    if featSelectDistOnModel==1
        
        setFeatureFileName=fullfile('src',dirName,'feature_selection.mat');
        
        if exist(setFeatureFileName,'file') ~= 2
            error('Feature Selection File not exist!!');
        else
            results = importdata(setFeatureFileName);
            featSelec=results{1,3};
        end
        
    end
    
    [ modelsPrecise modelsImprecise  ] =learnModels(FileDatasetName,modelsFileNamePrecise,modelsFileNameImprecise,N,F,M,1,featSelec,s);
else
    modelsPrecise =importdata(modelsFileNamePrecise);
    modelsImprecise =importdata(modelsFileNameImprecise);
end


% if uniformTrans==1
%
%     cls=size(models,1);
%     mdl=size(models,2);
%
%     Pi=ones(N,1) ./ N;
%     A=ones(N,N) ./ N;
%
% %     Mu=zeros(F,N);
% %     for f=1:F
% %         for s=1:N
% %             Sigma(f,s)=999999999;
% %         end
% %     end
%
%     for c=1:cls
%          for m=1:mdl
%
%              modelTemp=models{c,m};
%
%               if ~isempty(modelTemp)
%
%                  modelTemp{1}=Pi;
%                  modelTemp{2}=A;
%
%                  models{c,m}=modelTemp;
%
%               end
%
%          end
%     end
%
% end

relativeDistFileName=fullfile('src',dirName,['relative_distances_',num2str(typeGenerationMultiplePoints),'_typeGenerationMultiplePoints.mat']);

if exist(relativeDistFileName,'file') ~= 2
    %get relative distance presice, imprecise and interval
    relative = get_relative_distance_approximate( modelsPrecise,modelsImprecise,multi_features,minimum_value,relativeDistFileName,typeGenerationMultiplePoints,q,alpha,L );
else
    relative = importdata(relativeDistFileName);
end

%precise and interval labels
group_single=relative{1};
%imprecise labels (more point for each model)
group_multiple=relative{2};
relative_distances_precise=relative{3};
%each model more point learned from iHMM
relative_distances_imprecise=relative{4};
%interval point learned from iHMM
relative_distances_min=relative{5};
relative_distances_max=relative{6};


%normalize dataset
if normalize==1
    
    relative_distances_precise = (relative_distances_precise -repmat(min(relative_distances_precise,[],1),size(relative_distances_precise,1),1))*spdiags(1./(max(relative_distances_precise,[],1)-min(relative_distances_precise,[],1))',0,size(relative_distances_precise,2),size(relative_distances_precise,2));
    
    index=relative_distances_imprecise(:,end);
    
    relative_distances_imprecise=relative_distances_imprecise(:,1:end-1);
    
    relative_distances_imprecise = (relative_distances_imprecise -repmat(min(relative_distances_imprecise,[],1),size(relative_distances_imprecise,1),1))*spdiags(1./(max(relative_distances_imprecise,[],1)-min(relative_distances_imprecise,[],1))',0,size(relative_distances_imprecise,2),size(relative_distances_imprecise,2));
    
    relative_distances_imprecise=[relative_distances_imprecise index];
    
    relative_distances_min = (relative_distances_min -repmat(min(relative_distances_min,[],1),size(relative_distances_min,1),1))*spdiags(1./(max(relative_distances_min,[],1)-min(relative_distances_min,[],1))',0,size(relative_distances_min,2),size(relative_distances_min,2));
    relative_distances_max = (relative_distances_max -repmat(min(relative_distances_max,[],1),size(relative_distances_max,1),1))*spdiags(1./(max(relative_distances_max,[],1)-min(relative_distances_max,[],1))',0,size(relative_distances_max,2),size(relative_distances_max,2));
    
end

%find best parameter
if findBestSVMparameter==1
    
    %precise
    
    [bestt bestc bestg beste bestd ] = get_best_SVM_parameter( group_single,relative_distances_precise, n_fold,t,cFrom,cTo,cStep,gFrom,gTo,gStep,eFrom,eTo,eStep,dFrom,dTo,dStep );
    
    cmd_precise= ['-e ', num2str(beste),' -t ', num2str(bestt),' -coef0 0 -d ', num2str(bestd),' -c ', num2str(bestc), ' -g ', num2str(bestg)];
    
    disp(['Best cmd imprecise: ',cmd_precise]);
    
    cmd_imprecise=cmd_precise;
    
    
    %van tolte le occorrenze multiple di ogni classe
    %     if typeClassification==1
    %
    %         [bestt bestc bestg beste bestd ] = get_best_SVM_parameter( group_multiple(:,1:end-1),relative_distances_imprecise(:,1:end-1), n_fold,t,cFrom,cTo,cStep,gFrom,gTo,gStep,eFrom,eTo,eStep,dFrom,dTo,dStep );
    %
    %         cmd_imprecise= ['-e ', num2str(beste),' -t ', num2str(bestt),' -coef0 0 -d ', num2str(bestd),' -c ', num2str(bestc), ' -g ', num2str(bestg)];
    %
    %         disp(['Best cmd imprecise: ',cmd_imprecise]);
    %
    %         cmd_precise=cmd_imprecise;
    %
    %     end
    
else
    cmd_precise=cmd;
    cmd_imprecise=cmd;
end

%Best Feature Selection on precise case
if bestFeatureSelection==1 || bestFeatureSelection==2
        
    %calculate best set feature
    setFeatureFileName=fullfile('src',dirName,'feature_selection.mat');
    
    if exist(setFeatureFileName,'file') ~= 2
        results = get_set_feature_selection(  cmd_precise,group_single,relative_distances_precise,n_fold,setFeatureFileName  );
    else
        results = importdata(setFeatureFileName);
    end
    
    theBestFeatureIndex=results{1,3};
    
    relative_distances_precise=relative_distances_precise(:,theBestFeatureIndex);
    relative_distances_imprecise=[relative_distances_imprecise(:,theBestFeatureIndex) relative_distances_imprecise(:,end)];
    
    %recalculate best SVM parameter on new dataset
    if bestFeatureSelection==2
        [bestt bestc bestg beste bestd ] = get_best_SVM_parameter( group_single,relative_distances_precise, n_fold,t,cFrom,cTo,cStep,gFrom,gTo,gStep,eFrom,eTo,eStep,dFrom,dTo,dStep );
        cmd_precise= ['-e ', num2str(beste),' -t ', num2str(bestt),' -coef0 0 -d ', num2str(bestd),' -c ', num2str(bestc), ' -g ', num2str(bestg)];
        disp(['Best cmd imprecise (Feat. Sel.): ',cmd_imprecise]);
        cmd_imprecise=cmd_precise;
    end
    
    
    
end

cls=size(modelsImprecise,1);

confusion_matrix_precise=zeros(cls,cls);

%Leave-one-out
if n_fold==0
    c = cvpartition(group_single,'leaveout');
else
    c = cvpartition(group_single,'k',n_fold);
end

cp = classperf(group_single); % initializes the CP object


%typeClassification:

%get one class
%    1 precise. Learn: use multiple points(SVM). Test: use one point 
%    2 precise. Learn: use interval points(SVM_intervalKernel). Test: use
%    interval points
%    5 precise. Learn: use mean of intervals to generate(SVM). Test: use mean of interval points 
%    6 precise. Learn: use mean of intervals to generate(SVM). Test: use one point 

%get more class
%    3 imprecise. Learn: use interval points to generate lower and upper classificator (SVM_LOW - SVM_UP). Test: use one point (classified with each low up SVM) 
%    7 imprecise. Learn: use interval points to generate lower and upper classificator (SVM_LOW - SVM_UP). Test: use mean of interval points 
%    4 imprecise. Learn: use multiple points (SVM). Test: use multiple point (each point is classified with SVM)
%    8 imprecise. Learn: use single point(SVM). Test: use multiple points
%    (each point is classified with SVM)
%    9 imprecise. Learn: use multiple points. Test: use multiple points
%    Interval Dominance

if ((typeClassification==1) || (typeClassification==2)|| (typeClassification==5)|| (typeClassification==6))
    preciseClassification=1;
else
    preciseClassification=0;
end


if preciseClassification==0 %can get more class
    
    %confusion_matrix_imprecise_precise=zeros(cls,cls);
    confusion_matrix_imprecise_single=zeros(cls,cls);
    confusion_matrix_imprecise_multiple=zeros(cls,cls);
    confusion_matrix_precise_single=zeros(cls,cls);
    confusion_matrix_precise_multiple=zeros(cls,cls);
    countSample=0;
    numberOfclasses=[];
    meanClasses=[];
    accuracyImpreciseMultiple=[];
    accuracyPreciseMultiple=[];
    countNumClass=0;
    numberSingleClass=0;
    
else
    
    confusion_matrix_imprecise=zeros(cls,cls);
    
end

for i = 1:c.NumTestSets
    
    testIdx = test(c,i);
    trainIdx = training(c,i);
    testGroup=group_single(testIdx,1);
    test_indxs=find(testIdx==1);
    train_indexes=find(trainIdx==1);
    
    classes_imprecise=[];
    
    
    switch logical(true)
        
        %    1 precise. Learn: use multiple point(SVM). Test: use one point
        case typeClassification==1,
            
            %precise
            
            for point=1:size(test_indxs,1)
                
                classes_imprecise{point}  = classification( relative_distances_precise(test_indxs(point),:) , minimum_value , group_multiple(group_multiple(:,end)~=test_indxs(point),1:end-1) , relative_distances_imprecise(relative_distances_imprecise(:,end)~=test_indxs(point),1:end-1) , multi_features,type,k,distance,fun,cmd_imprecise,q,alpha,L  );
                
            end
            
            
            %    2 precise. Learn: use interval point(SVM_intervalKernel).
            %    Test: use interval point
        case typeClassification==2,
            
            %precise
            
            %precomputed interval kernel
            typeTemp=3;
            
            %min train distance
            distance_train{1,1}=relative_distances_min(trainIdx,:);
            %max train distance
            distance_train{1,2}=relative_distances_max(trainIdx,:);
            
            %min test distance
            distance_test{1,1}=relative_distances_min(testIdx,:);
            %max test distance
            distance_test{1,2}=relative_distances_max(testIdx,:);
            
            clses = classification( distance_test , minimum_value , group_single(trainIdx,1) , distance_train , multi_features,typeTemp,k,distance,fun,cmd_imprecise,q,alpha,L  );
            
            classes_imprecise=cell(1,size(clses,1));
            
            for cl=1:size(clses,1)
                
                classes_imprecise{1,cl}=clses(cl,1);
                
            end
            
            % 3 imprecise. Learn: use interval point to generate lower and upper classificator (SVM_LOW - SVM_UP). Test: use one point (classified with each low up SVM)
        case typeClassification==3,
            
            %imprecise
            for point=1:size(test_indxs,1)
                
                
                classes1  = classification( relative_distances_precise(test_indxs(point),:) , minimum_value , group_single(trainIdx,1) , relative_distances_min(trainIdx,:) , multi_features,type,k,distance,fun,cmd_imprecise,q,alpha,L  );
                
                
                classes2  = classification( relative_distances_precise(test_indxs(point),:) , minimum_value , group_single(trainIdx,1) , relative_distances_max(trainIdx,:) , multi_features,type,k,distance,fun,cmd_imprecise,q,alpha,L  );
                
                classes_imprecise{point}=[classes1 classes2];
                
                %delete ugual class
                classes_imprecise{point}=unique(classes_imprecise{point});
                
            end
            
            
            %    4 imprecise. Learn: use multiple point (SVM). Test: use
            %    multiple point (each point is classified with SVM)
        case typeClassification==4,
            
            
            %imprecise
            for point=1:size(test_indxs,1)
                classes_imprecise{point} = classification( relative_distances_imprecise(relative_distances_imprecise(:,end)==test_indxs(point),1:end-1) , minimum_value , group_multiple(group_multiple(:,end)~=test_indxs(point),1:end-1) , relative_distances_imprecise(relative_distances_imprecise(:,end)~=test_indxs(point),1:end-1) , multi_features,type,k,distance,fun,cmd_imprecise,q,alpha,L  );
                
                %delete ugual class
                classes_imprecise{point}=unique(classes_imprecise{point});
            end
            
            
            %    5 precise. Learn: use mean of interval to generate(SVM).
            %    Test: use mean of interval point
        case typeClassification==5,
            
            
            %precise
            
            %mean interval
            distance_train=(relative_distances_max(trainIdx,:) + relative_distances_min(trainIdx,:))./2;
            
            distance_test=(relative_distances_max(testIdx,:) + relative_distances_min(testIdx,:))./2;
            
            
            for point=1:size(distance_test,1)
                
                classes_imprecise{point}  = classification( distance_test(point,:) , minimum_value , group_single(trainIdx,1) , distance_train , multi_features,type,k,distance,fun,cmd_imprecise,q,alpha,L  );
                
            end
            
            
            %    6 precise. Learn: use mean of interval to generate(SVM).
            %    Test: use one point
        case typeClassification==6,
            
            
            %precise
            
            %mean interval
            distance_train=(relative_distances_max(trainIdx,:) + relative_distances_min(trainIdx,:))./2;
            
            for point=1:size(test_indxs,1)
                
                classes_imprecise{point}  = classification( relative_distances_precise(test_indxs(point),:) , minimum_value , group_single(trainIdx,1) , distance_train , multi_features,type,k,distance,fun,cmd_imprecise,q,alpha,L  );
                
            end
            
            
            %    7 imprecise. Learn: use interval point to generate lower
            %    and upper classificator (SVM_LOW - SVM_UP). Test: use mean of interval point
        case typeClassification==7,
            
            
            %mean interval
            distance_train=(relative_distances_max(trainIdx,:) + relative_distances_min(trainIdx,:))./2;
            
            distance_test=(relative_distances_max(testIdx,:) + relative_distances_min(testIdx,:))./2;
            
            
            for point=1:size(distance_test,1)
                
                classes_imprecise{point}  = classification( distance_test(point,:) , minimum_value , group_single(trainIdx,1) , distance_train , multi_features,type,k,distance,fun,cmd_imprecise,q,alpha,L  );
                
            end
            
            
            
            %imprecise
            for point=1:size(test_indxs,1)
                
                %mean of interval
                testP=((relative_distances_max(test_indxs(point),:) + relative_distances_min(test_indxs(point),:))./2);
                
                classes1  = classification(  testP , minimum_value , group_single(trainIdx,1) , relative_distances_min(trainIdx,:) , multi_features,type,k,distance,fun,cmd_imprecise,q,alpha,L  );
                
                
                classes2  = classification( testP , minimum_value , group_single(trainIdx,1) , relative_distances_max(trainIdx,:) , multi_features,type,k,distance,fun,cmd_imprecise,q,alpha,L  );
                
                classes_imprecise{point}=[classes1 classes2];
                
                %delete ugual class
                classes_imprecise{point}=unique(classes_imprecise{point});
                
            end
            
            
            
            %    8 imprecise. Learn: use single point(SVM). Test: use multiple point
            %    (each point is classified with SVM)
        case typeClassification==8,
            
            
            %imprecise
            for point=1:size(test_indxs,1)
                classes_imprecise{point} = classification( relative_distances_imprecise(relative_distances_imprecise(:,end)==test_indxs(point),1:end-1) , minimum_value , group_single(trainIdx,1) , relative_distances_precise(trainIdx,:) , multi_features,type,k,distance,fun,cmd_imprecise,q,alpha,L  );
                
                %delete ugual class
                classes_imprecise{point}=unique(classes_imprecise{point});
            end
            
            
            %    9 imprecise. Learn: use multiple point. Test: use multiple point
            %    Interval Dominance
        case typeClassification==9,
            
            
            %imprecise
            for point=1:size(test_indxs,1)
                
                classes_imprecise{point} = classification( relative_distances_imprecise(relative_distances_imprecise(:,end)==test_indxs(point),1:end-1) , minimum_value , group_single(trainIdx,1) , [ {relative_distances_imprecise(relative_distances_imprecise(:,end)~=test_indxs(point),:)} {train_indexes} ], multi_features,4,k,distance,fun,cmd_imprecise,q,alpha,L  );
                
            end
            
            
    end
    
    %interval dominance precise (== K-NN with k=1)
    if typeClassification==9
    
        distance='euclidean';
        classes_precise  = classification( relative_distances_precise(testIdx,:) , minimum_value , group_single(trainIdx,1) , relative_distances_precise(trainIdx,:) , multi_features,5,k,distance,fun,cmd_precise,q,alpha,L  );
        
    else
        
        %classes_precise=1;
        classes_precise  = classification( relative_distances_precise(testIdx,:) , minimum_value , group_single(trainIdx,1) , relative_distances_precise(trainIdx,:) , multi_features,type,k,distance,fun,cmd_precise,q,alpha,L  );

    end
    
    if preciseClassification==0%more class
        
                
        %for each test point
        for point=1:c.TestSize(i)
            
            countSample=countSample+1;
            
            classification_classes_results{1,1}(countSample,1)=testGroup(point,1);
            classification_classes_results{1,2}(countSample,1)=classes_precise(point);
            classification_classes_results{1,3}{countSample,1}=classes_imprecise{point};
            
            numClass=size(classes_imprecise{point},2);
                        
            if numClass>1%more class
                
                countNumClass=countNumClass+1;
                numberOfclasses(1,countNumClass)=numClass;
                
                %if one class is correct
                if sum(classes_imprecise{point}==testGroup(point,1))>0
                    
                    confusion_matrix_imprecise_multiple(testGroup(point,1),testGroup(point,1))=confusion_matrix_imprecise_multiple(testGroup(point,1),testGroup(point,1))+1;
                    
                else %set random class of the set
                    
                    confusion_matrix_imprecise_multiple(testGroup(point,1),classes_imprecise{point}(1,1))=confusion_matrix_imprecise_multiple(testGroup(point,1),classes_imprecise{point}(1,1))+1;
                    
                end
                
                confusion_matrix_precise_multiple(testGroup(point,1),classes_precise(point))=confusion_matrix_precise_multiple(testGroup(point,1),classes_precise(point))+1;
                
                
            else%single class
                
                for point=1:c.TestSize(i)
                    
                    numberSingleClass=numberSingleClass+1;
                    confusion_matrix_imprecise_single(testGroup(point,1),classes_imprecise{point})=confusion_matrix_imprecise_single(testGroup(point,1),classes_imprecise{point})+1;
                    confusion_matrix_precise_single(testGroup(point,1),classes_precise(point))=confusion_matrix_precise_single(testGroup(point,1),classes_precise(point))+1;
                    
                end
                
            end
            
            
            
        end
        
        
    else %one class
        
        
        %for each test point
        for point=1:c.TestSize(i)
            
            confusion_matrix_imprecise(testGroup(point,1),classes_imprecise{point})=confusion_matrix_imprecise(testGroup(point,1),classes_imprecise{point})+1;
            
        end
        
        
        
    end
    
    %for each test point
    for point=1:c.TestSize(i)
        
        confusion_matrix_precise(testGroup(point,1),classes_precise(point,1))=confusion_matrix_precise(testGroup(point,1),classes_precise(point,1))+1;
        
    end
    
    classperf(cp,classes_precise,testIdx);
    
end

cp.CorrectRate % queries for the correct classification rate


s=sum(confusion_matrix_precise,2);

for i=1:size(s,1)
    
    confusion_matrix_precise(i,:)=confusion_matrix_precise(i,:) * 1/s(i,1);
    
end

accuracy_precise=sum(diag(confusion_matrix_precise)) * 1 / cls;

display([dirName,' precise HSD : ',num2str(accuracy_precise)]);

if preciseClassification==0%more class
    
    display(['numberSingleClass: ',num2str(numberSingleClass),' / ', num2str(size(group_single,1))  ]);
    
    if countNumClass>0
        
        meanClasses=sum(numberOfclasses,2) / countNumClass;
        display(['meanClasses: ',num2str(meanClasses),' / ', num2str(cls)  ]);        
        
    end
    
    s=sum(confusion_matrix_imprecise_single,2);
    
    for i=1:size(s,1)
        
        if s(i,1)~=0
            confusion_matrix_imprecise_single(i,:)=confusion_matrix_imprecise_single(i,:) * 1/s(i,1);
        end
        
    end
    
    accuracyImpreciseSingle=sum(diag(confusion_matrix_imprecise_single)) * 1 / cls;
    
    display(accuracyImpreciseSingle);
    
    s=sum(confusion_matrix_precise_single,2);
    classValued=0;
    for i=1:size(s,1)
        if s(i,1)~=0
            confusion_matrix_precise_single(i,:)=confusion_matrix_precise_single(i,:) * 1/s(i,1);
            classValued=classValued+1;
        end
    end
    
    accuracyPreciseSingle=sum(diag(confusion_matrix_precise_single)) * 1 / classValued;
    
    display(accuracyPreciseSingle);
    
    
    s=sum(confusion_matrix_imprecise_multiple,2);
    classValued=0;
    for i=1:size(s,1)
        
        if s(i,1)~=0
            
            confusion_matrix_imprecise_multiple(i,:)=confusion_matrix_imprecise_multiple(i,:) * 1/s(i,1);
            classValued=classValued+1;
        end
        
    end
    
    accuracyImpreciseMultiple=sum(diag(confusion_matrix_imprecise_multiple)) * 1 / classValued;
    
    display(accuracyImpreciseMultiple);
    
    
    s=sum(confusion_matrix_precise_multiple,2);
    classValued=0;
    for i=1:size(s,1)
        if s(i,1)~=0
            confusion_matrix_precise_multiple(i,:)=confusion_matrix_precise_multiple(i,:) * 1/s(i,1);
            classValued=classValued+1;
        end
    end
    
    accuracyPreciseMultiple=sum(diag(confusion_matrix_precise_multiple)) * 1 / classValued;
    
    display(accuracyPreciseMultiple);
    
else
    
    s=sum(confusion_matrix_imprecise,2);
    
    for i=1:size(s,1)
        
        confusion_matrix_imprecise(i,:)=confusion_matrix_imprecise(i,:) * 1/s(i,1);
        
        
    end
    
    accuracyImprecise=sum(diag(confusion_matrix_imprecise)) * 1 / cls;
    
    display([dirName,' imprecise HSD  : ',num2str(accuracyImprecise)]);
end


%classification parameter
% switch logical(true)
%     %KNN
%     case type==0,
%         results_precise{1,3}=['k: ',num2str(k),' , distance: ',distance];
%
%         resultsFileName=fullfile('src',dirName,['results_HSD_',num2str(L),'_L_KNN_type_',num2str(k),'_k_',distance,'_dist_',num2str(n_fold),'_fold_',num2str(normalize),'_norm_',num2str(uniformTrans),'_uniformA.mat']);
%         figName=fullfile('src',dirName,['Misclassification_HSD_',num2str(L),'_L_KNN_type_',num2str(k),'_k_',distance,'_dist_',num2str(n_fold),'_fold_',num2str(normalize),'_norm_',num2str(uniformTrans),'_uniformA']);
%         log=[num2str(L),'_L_KNN_type_',num2str(k),'_k_',distance,'_dist_',num2str(n_fold),'_fold_',num2str(normalize),'_norm_',num2str(uniformTrans),'_uniformA'];
%         %Discriminant function
%     case type==1,
%         results_precise{1,3}=['fun: ',fun];
%
%         resultsFileName=fullfile('src',dirName,['results_HSD_',num2str(L),'_L_DiscrFunc_type_',fun,'_function_',num2str(n_fold),'_fold_',num2str(normalize),'_norm_',num2str(uniformTrans),'_uniformA.mat']);
%         figName=fullfile('src',dirName,['Misclassification_HSD_',num2str(L),'_L_DiscrFunc_type_',fun,'_function_',num2str(n_fold),'_fold_',num2str(normalize),'_norm_',num2str(uniformTrans),'uniformA']);
%         log=[num2str(L),'_L_DiscrFunc_type_',fun,'_function_',num2str(n_fold),'_fold_',num2str(normalize),'_norm_',num2str(uniformTrans),'_uniformA'];
%         %SVM
%     case type==2,

results_precise{1,3}=['cmd: ',cmd_precise];
idx= ~isspace(cmd_precise);
cmdstr=cmd(idx);
cmdstr=strrep(cmdstr, '.', ',');
resultsFileName_precise=fullfile('src',dirName,['results_Precise_HSD_',num2str(L),'_L_',cmdstr,'_cmd_',num2str(n_fold),'_fold_',num2str(bestFeatureSelection),'_FSel_',num2str(normalize),'_norm_',num2str(uniformTrans),'_unifA.mat']);
figName_precise=fullfile('src',dirName,['Misclassification_Precise_HSD_',num2str(L),'_L',cmdstr,'_cmd_',num2str(n_fold),'_fold_',num2str(bestFeatureSelection),'_FSel_',num2str(normalize),'_norm_',num2str(uniformTrans),'_unifA']);
log_precise=[num2str(L),'_L_',cmdstr,'_cmd_',num2str(n_fold),'_fold_',num2str(bestFeatureSelection),'_FSel_',num2str(normalize),'_norm_',num2str(uniformTrans),'_unifA'];

if preciseClassification==0
    results_imprecise{1,12}=['cmd: ',cmd_imprecise];
else
    results_imprecise{1,3}=['cmd: ',cmd_imprecise];
end

idx= ~isspace(cmd_imprecise);
cmdstr=cmd(idx);
cmdstr=strrep(cmdstr, '.', ',');
resultsFileName_imprecise=fullfile('src',dirName,['results_HSD_',num2str(L),'_L_',cmdstr,'_cmd_',num2str(n_fold),'_fold_',num2str(bestFeatureSelection),'_FSel_',num2str(normalize),'_norm_',num2str(uniformTrans),'_unifA_',num2str(typeClassification),'_typeC.mat']);
figName_imprecise=fullfile('src',dirName,['Misclassification_imprecise_HSD_',num2str(L),'_L_',cmdstr,'_cmd_',num2str(n_fold),'_fold_',num2str(bestFeatureSelection),'_FSel_',num2str(normalize),'_norm_',num2str(uniformTrans),'_unifA_',num2str(typeClassification),'_typeC']);
%log_imprecise=[num2str(L),'_L_',cmdstr,'_cmd_',num2str(n_fold),'_fold_',num2str(bestFeatureSelection),'_FSel_',num2str(normalize),'_norm_',num2str(uniformTrans),'_unifA_',num2str(typeClassification),'_typeC'];


% end



%save precise results

results_precise{1,1}=confusion_matrix_precise;
results_precise{1,2}=accuracy_precise;

fid = fopen(fullfile('src',dirName,'LogAccuracy.txt'), 'a');
fprintf(fid, '%s  Accuracy: %s\r\n', log_precise , num2str(accuracy_precise));
fclose(fid);

save(resultsFileName_precise,'results_precise');

%plot misclassification
plotTests=(ones(1,cls) - diag(confusion_matrix_precise)')* 100;

figure(1);
plot(1:1:cls,plotTests,'r+','linewidth',3);
title(['Misclassification precise HSD percentage. Accuracy:',' ',num2str(accuracy_precise)]);
xlabel('Class');
ylabel('Percentage');

%save graph
saveas(1,figName_precise,'jpg');

%plot confusion matrix
f = figure('Position',[100 200 790 190]);
names=cell(1,cls);
for i=1:cls
    names{1,i}=num2str(i);
end

t = uitable('Parent',f,'Data',confusion_matrix_precise,'ColumnName',names,'RowName',names,'Position',[0 0 785 190]);
title('Precise confusion matrix');
tabName=fullfile('src',dirName,'confusion_matrix_precise_PROB');

%save table
saveas(f,tabName,'jpg');


%save results imprecise

if preciseClassification==0
    
    resultsImprecise{1,1}=numberSingleClass;
    
    resultsImprecise{1,2}=countSample - numberSingleClass;
    
    resultsImprecise{1,3}=meanClasses;
        
    resultsImprecise{1,4}=confusion_matrix_imprecise_single;
    resultsImprecise{1,5}=confusion_matrix_imprecise_multiple;
    resultsImprecise{1,6}=confusion_matrix_precise_single;
    resultsImprecise{1,7}=confusion_matrix_precise_multiple;
    
    resultsImprecise{1,8}=accuracyImpreciseSingle;
    resultsImprecise{1,9}=accuracyImpreciseMultiple;
    resultsImprecise{1,10}=accuracyPreciseSingle;
    resultsImprecise{1,11}=accuracyPreciseMultiple;
    
    resultsImprecise{1,12}=classification_classes_results;  
    
    resultsImprecise{1,13}=size(confusion_matrix_precise_single,1);  
    
    resultsImprecise{1,14}={'numberSingleClass' 'numberMultipleClass' 'meanClasses' 'confusion_matrix_imprecise_single' 'confusion_matrix_imprecise_multiple' 'confusion_matrix_precise_single' 'confusion_matrix_precise_multiple' 'accuracyImpreciseSingle' 'accuracyImpreciseMultiple' 'accuracyPreciseSingle' 'accuracyPreciseMultiple' 'classification_classes_results' 'numberOflabels'};
        
    save(resultsFileName_imprecise,'resultsImprecise');
    
else
    
    resultsImprecise{1,1}=confusion_matrix_imprecise;
    resultsImprecise{1,2}=accuracyImprecise;
    
    save(resultsFileName_imprecise,'resultsImprecise');
    
    %plot misclassification
    plotTests=(ones(1,cls) - diag(confusion_matrix_imprecise)')* 100;
    
    figure(3);
    plot(1:1:cls,plotTests,'r+','linewidth',3);
    title(['Misclassification imprecise HSD percentage. Accuracy:',' ',num2str(accuracyImprecise)]);
    xlabel('Class');
    ylabel('Percentage');
    
    
    %save graph
    saveas(3,figName_imprecise,'jpg');
    
    %plot confusion matrix
    g = figure('Position',[100 200 790 190]);
    names=cell(1,cls);
    for i=1:cls
        names{1,i}=num2str(i);
    end
    
    t2 = uitable('Parent',g,'Data',confusion_matrix_imprecise,'ColumnName',names,'RowName',names,'Position',[0 0 785 190]);
    title('Imprecise confusion matrix');
    tabName=fullfile('src',dirName,['confusion_matrix_imprecise_PROB_typeClassification_',num2str(typeClassification)]);
    
    %save table
    saveas(g,tabName,'jpg');
    
end


end
