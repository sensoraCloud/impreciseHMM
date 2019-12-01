addpath('class');
addpath('libsvm-mat-3.0-1');
addpath('initParam');
addpath('hmmTool');
addpath('impreciseMarkovChain');

close all;

%datasetName='Triplicate-Features-Norm-Smooth5-Full-Skip';
datasetName='Triplicate-Features-wei-hof';
%datasetName='Triplicate-KTH-SX-Scenario1';
%datasetName='QuadruplicateObsfeaturesSx';
%datasetName='TriplicateWeizSimpleFeature5FeatSel';
%datasetName='TriplicateKTH_SX_ALL';
%datasetName='TriplicateYeastData';

% FileDatasetName=fullfile('src','features',[datasetName,'.mat']);
% [ N ] = mean_peeks_features( FileDatasetName );

% n_fold cross validation if 0 Leave-one-out
n_fold=0;

Nfrom=3;
Nto=3;
Ffrom=32;
Fto=32;
M=1; %mixtures
s=2; %imprecision

%HSD
multi_features=1;
q=12;
alpha=1e-7;
L=70;
minimum_value=-300;% -2500(kth) , -20(weiz), -160 (weiz simple)

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
%    8 imprecise. Learn: use single point(SVM). Test: use multiple points (each point is classified with SVM)
%    9 imprecise. Learn: use multiple points. Test: use multiple points
%    Interval Dominance

typeClassification=3;

%typeGenerationMultiplePoints: 1 from stationary distribution,
%2 from transition matrix A
typeGenerationMultiplePoints=1;

%type Classificator: 0 k-nn, 1 discriminant function, 2 SVM 
%if typeClassification==9 precise do K-NN k=1
type=2;
%SVM
cmd='-e 0.3 -t 2 -coef0 0 -d 1 -c 100 -g 0.7';

%normalize [0,1] relative_distances 1 or not normalize 0 
%!! if the date is to sparse SVMtrain don't work well, need to normalize
%data
normalize=1;


%Classificator type: 
% type=2;
% 
% %type=0 K-NN (k=1,distance='euclidean') 
% 
% % distance:
% %               'euclidean'    Euclidean distance (default)
% %               'cityblock'    Sum of absolute differences, or L1
% %               'cosine'       One minus the cosine of the included angle
% %                              between points (treated as vectors)
% %               'correlation'  One minus the sample correlation between
% %                              points (treated as sequences of values)
% %               'Hamming'      Percentage of bits that differ (only
% %                              suitable for binary data)
% 
 k=3;
 distance='correlation';
% 
% %type=1 discriminant function (fun='linear')
% 
% % function:
% %       'linear', 'quadratic','diagLinear', 'diagQuadratic', or 'mahalanobis'.
% %        Linear discrimination fits a multivariate normal density to each group, with a pooled
% %        estimate of covariance.  Quadratic discrimination fits MVN densities
% %        with covariance estimates stratified by group.  Both methods use
% %        likelihood ratios to assign observations to groups.  'diagLinear' and
% %        'diagQuadratic' are similar to 'linear' and 'quadratic', but with
% %        diagonal covariance matrix estimates.  These diagonal choices are
% %        examples of naive Bayes classifiers.  Mahalanobis discrimination uses
% %        Mahalanobis distances with stratified covariance estimates.  TYPE
% %        defaults to 'linear'.
% 
 fun='mahalanobis';

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

%cmd='-e 0.001 -t 1 -coef0 0 -d 1 -c 180 -g 1';

%findBestSVMparameter(1 or not 0) find best parameter only for SVM classification (t(array with t kernel to try),cFrom=0.1,cTo=10,cStep=0.1,gFrom=0.1,gTo=10,gStep=0.1,eFrom=0.1,eTo=10,eStep=0.1,..)
findBestSVMparameter=0;

%kernel_type
t=[1];  

%cost
cFrom=100;
cStep=10;
cTo=200;

%gamma
gFrom=0.0001;
gStep=0.05;
gTo=3;

%epsilon
eFrom=0.00001;
eStep=0.1;
eTo=0.8;

%degree
dFrom=1;
dStep=0.2;
dTo=3;


if (findBestSVMparameter==1) && (type~=2)
    error('findBestSVMparameter only for SVM classification! (type=2)');
end

%bestFeatureSelection (1 feature selection or 2 fet. selec. plus re-optimization parameter on selection dataset or 0 no feature seceltion) find best set of features that maximize accuracy with n-fold classification only for SVM (sequential forward selection(SFS))
bestFeatureSelection=1;

if (bestFeatureSelection==1) && (type~=2)
    error('bestFeatureSelection only for SVM classification! (type=2)');
end

%featSelectDistOnModel (1 feature selection or 0 no feature seceltion)
%apply best set feature selection of relative distance to original feature
%for create hmm models (only for SVM classification)
featSelectDistOnModel=0;

if (featSelectDistOnModel==1) && (type~=2)
    error('bestFeatureSelection only for SVM classification! (type=2)');
end


%uniform transition (1 (uniform) or 0 normal)
uniformTrans=0;

for f=Ffrom:Fto
    for n=Nfrom:Nto        
      cross_validation_HSD( n_fold,n,f,M,s,datasetName,q,alpha,L,multi_features,minimum_value,type,cmd,normalize,findBestSVMparameter,t,cFrom,cTo,cStep,gFrom,gTo,gStep,eFrom,eTo,eStep,dFrom,dTo,dStep,bestFeatureSelection,featSelectDistOnModel,uniformTrans,typeClassification,k,distance,fun,typeGenerationMultiplePoints);
    end
end