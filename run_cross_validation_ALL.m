addpath('class');
addpath('libsvm-mat-3.0-1');
addpath('initParam');
addpath('hmmTool');
addpath('impreciseMarkovChain');

close all;

datasetName1='Triplicate-Features-wei-hof';
datasetName2='Triplicate-Wei-Snippet';

%datasetName1='Triplicate-Features-KTH-hof-Scenario2-Norm';
%datasetName2='Triplicate-KTH-SX-Scenario2';

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
minimum_value=-3000;% -2500(kth) , -20(weiz), -160 (weiz simple)

%SVM

%istogram
cmd_1='-e 0.3 -t 2 -coef0 0 -d 1 -c 100 -g 0.7';
%snippet
cmd_2='-e 0.7 -t 2 -coef0 0 -d 1 -c 150 -g 0.2';

%normalize [0,1] relative_distances 1 or not normalize 0 
%!! if the date is to sparse SVMtrain don't work well, need to normalize
%data
normalize=1;


for f=Ffrom:Fto
    for n=Nfrom:Nto        
      cross_validation_TEST_ALL( n_fold,n,f,M,s,datasetName1,datasetName2,q,alpha,L,multi_features,minimum_value,cmd_1,cmd_2,normalize)
    end
end