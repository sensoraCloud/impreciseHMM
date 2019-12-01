addpath('class');
addpath('libsvm-mat-3.0-1');
addpath('initParam');
addpath('hmmTool');

N=14;
F=32;
M=1;

%HSD
multi_features=1;
q=12;
alpha=1e-7;
L=70;
minimum_value=-300;% -2500(kth) , -20(weiz), -5000 , -150(weiz simple)

bestFeatureSelection=1;

normalize=1;

%TEST
datasetName='Triplicate-dataset-robust-Norm-Smooth5';

dirNameTest=fullfile(datasetName,['models_','',num2str(N),'','N_','',num2str(F),'','F_',num2str(M),'M']);
 
FileDatasetName=fullfile('src','features',[datasetName,'.mat']);

if exist(fullfile('src',dirNameTest),'dir') ~= 7
    mkdir('src',dirNameTest);
end

modelsFileName=fullfile('src',dirNameTest,'models.mat');

featSelectDistOnModel=0;

if exist(modelsFileName,'file') ~= 2
    %learn models and generates models file learnModels(
    %featuresFileName,modelsFileName,N,F,C,varargin )
    featSelec=[];
    
    if featSelectDistOnModel==1
        
        setFeatureFileName=fullfile('src',dirNameTest,'feature_selection.mat');

        if exist(setFeatureFileName,'file') ~= 2    
            error('Feature Selection File not exist!!');
        else
            results = importdata(setFeatureFileName);
            featSelec=results{1,3};
        end  
        
    end
    
    modelsTest=learnModels(FileDatasetName,modelsFileName,N,F,M,1,featSelec);
else
    modelsTest=importdata(modelsFileName);
end

%relative distance TEST
relativeDistFileName=fullfile('src',dirNameTest,'relative_distances.mat');

if exist(relativeDistFileName,'file') ~= 2    
    relative = get_relative_distance_approximate( modelsTest,multi_features,minimum_value,relativeDistFileName,q,alpha,L  );
else
    relative = importdata(relativeDistFileName);
end

groupTest=relative{1};
relative_distancesTest=relative{2};


%TRAIN

datasetName='TriplicateFeatures-wei-hof-Smooth5';

dirName=fullfile(datasetName,['models_','',num2str(N),'','N_','',num2str(F),'','F_',num2str(M),'M']);
 
FileDatasetName=fullfile('src','features',[datasetName,'.mat']);

if exist(fullfile('src',dirName),'dir') ~= 7
    mkdir('src',dirName);
end

modelsFileName=fullfile('src',dirName,'models.mat');

featSelectDistOnModel=0;

if exist(modelsFileName,'file') ~= 2
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
    
    modelsTrain=learnModels(FileDatasetName,modelsFileName,N,F,M,1,featSelec);
else
    modelsTrain=importdata(modelsFileName);
end

%relative distance TEST
relativeDistFileName=fullfile('src',dirName,'relative_distances.mat');

if exist(relativeDistFileName,'file') ~= 2    
    relative = get_relative_distance_approximate( modelsTrain,multi_features,minimum_value,relativeDistFileName,q,alpha,L  );
else
    relative = importdata(relativeDistFileName);
end

groupTrain=relative{1};
relative_distancesTrain=relative{2};


%Best Feature Selection 
if bestFeatureSelection==1
    
    %calculate best set feature 
    setFeatureFileName=fullfile('src',dirName,'feature_selection.mat');

    if exist(setFeatureFileName,'file') ~= 2    
        results = get_set_feature_selection(  cmd,group,relative_distances,n_fold,setFeatureFileName  );
    else
        results = importdata(setFeatureFileName);
    end
    
   theBestFeatureIndex=results{1,3};  
     
   relative_distancesTrain=relative_distancesTrain(:,theBestFeatureIndex);  
   
   relative_distancesTest=relative_distancesTest(:,theBestFeatureIndex);  
   
end



%normalize dataset

trainSize=size(relative_distancesTrain,1);
totalDataset=[relative_distancesTrain;relative_distancesTest];

if normalize==1
    totalDataset = (totalDataset -repmat(min(totalDataset,[],1),size(totalDataset,1),1))*spdiags(1./(max(totalDataset,[],1)-min(totalDataset,[],1))',0,size(totalDataset,2),size(totalDataset,2));
end

relative_distancesTrain=totalDataset(1:trainSize,:);
relative_distancesTest=totalDataset(trainSize+1:end,:);

%VALIDATION   

%Classificator type: 
type=2;

%type=0 K-NN (k=1,distance='euclidean') 

% distance:
%               'euclidean'    Euclidean distance (default)
%               'cityblock'    Sum of absolute differences, or L1
%               'cosine'       One minus the cosine of the included angle
%                              between points (treated as vectors)
%               'correlation'  One minus the sample correlation between
%                              points (treated as sequences of values)
%               'Hamming'      Percentage of bits that differ (only
%                              suitable for binary data)

k=3;
distance='euclidean';

%type=1 discriminant function (fun='linear')

% function:
%       'linear', 'quadratic','diagLinear', 'diagQuadratic', or 'mahalanobis'.
%        Linear discrimination fits a multivariate normal density to each group, with a pooled
%        estimate of covariance.  Quadratic discrimination fits MVN densities
%        with covariance estimates stratified by group.  Both methods use
%        likelihood ratios to assign observations to groups.  'diagLinear' and
%        'diagQuadratic' are similar to 'linear' and 'quadratic', but with
%        diagonal covariance matrix estimates.  These diagonal choices are
%        examples of naive Bayes classifiers.  Mahalanobis discrimination uses
%        Mahalanobis distances with stratified covariance estimates.  TYPE
%        defaults to 'linear'.

fun='linear';

%type=2 SVM (cmd='-e 0.6 -t 1 -coef0 0 -d 1 -v 72 -c 1.8 -g 2.5')

% options:
% -s svm_type : set type of SVM (default 0)
% 	0 -- C-SVC
% 	1 -- nu-SVC
% 	2 -- one-class SVM
% 	3 -- epsilon-SVR
% 	4 -- nu-SVR
% -t kernel_type : set type of kernel function (default 2)
% 	0 -- linear: u'*v
% 	1 -- polynomial: (gamma*u'*v + coef0)^degree
% 	2 -- radial basis function: exp(-gamma*|u-v|^2)
% 	3 -- sigmoid: tanh(gamma*u'*v + coef0)
% -d degree : set degree in kernel function (default 3)
% -g gamma : set gamma in kernel function (default 1/num_features)
% -r coef0 : set coef0 in kernel function (default 0)
% -c cost : set the parameter C of C-SVC, epsilon-SVR, and nu-SVR (default 1)
% -n nu : set the parameter nu of nu-SVC, one-class SVM, and nu-SVR (default 0.5)
% -p epsilon : set the epsilon in loss function of epsilon-SVR (default 0.1)
% -m cachesize : set cache memory size in MB (default 100)
% -e epsilon : set tolerance of termination criterion (default 0.001)
% -h shrinking: whether to use the shrinking heuristics, 0 or 1 (default 1)
% -b probability_estimates: whether to train a SVC or SVR model for probability estimates, 0 or 1 (default 0)
% -wi weight: set the parameter C of class i to weight*C, for C-SVC (default 1)
% 
% The k in the -g option means the number of attributes in the input data.

cmd = '-e 0.3 -t 2 -coef0 0 -d 1 -c 100 -g 0.7';

cls=size(unique(groupTrain),1);
confusion_matrix=zeros(cls,cls);     

%confusion matrix
for t=1:size(relative_distancesTest,1)
   
     %walk
    action=7;
   
    class  = classification( relative_distancesTest(t,:) , minimum_value , groupTrain, relative_distancesTrain , multi_features,type,k,distance,fun,cmd,q,alpha,L  );
    
    confusion_matrix(action,class)=confusion_matrix(action,class)+1;   
    
end

s=sum(confusion_matrix,2);

for i=1:size(s,1)

    confusion_matrix(i,:)=confusion_matrix(i,:) * 1/s(i,1);
    
end

accuracy=confusion_matrix(7,7);
%accuracy=sum(diag(confusion_matrix)) * 1 / cls;

results{1,1}=confusion_matrix;
results{1,2}=accuracy;

display([dirName,' HSD robust: ',num2str(accuracy)]);

resultsFileName=fullfile('src',dirNameTest,'results_HSD_ROBUST');

save(resultsFileName,'results');


