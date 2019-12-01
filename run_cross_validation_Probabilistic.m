%addpath('class');
%addpath('initParam');
%addpath('hmmTool');
datasetName='Triplicate-Features-wei-hof';

% n_fold cross validation if 0 Leave-one-out
n_fold=0;

Nfrom=3;
Nto=3;

Ffrom=32;
Fto=32;

M=1; %mixtures
s=2;

%typeClassification:
%    1 max min
%    2 max max
%    3 interval dominance
typeClassification=3;

%not used for now
featSelectDistOnModel=0;

for f=Ffrom:5:Fto
    for n=Nfrom:Nto        
       %cross_validation_Probabilistic( n_fold,N,F,featuresFileName )
       cross_validation_Probabilistic( n_fold,n,f,M,datasetName,s,featSelectDistOnModel,typeClassification );
    end
end