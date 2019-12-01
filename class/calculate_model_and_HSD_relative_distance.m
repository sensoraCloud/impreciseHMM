function [ ] = calculate_model_and_HSD_relative_distance( N,F,FileDatasetName,q,alpha,L,multi_features,minimum_value )

%create directory
dirName=['models_','',num2str(N),'','s_','',num2str(F),'','f'];

mkdir('src',dirName);

modelsFileName=fullfile('src',dirName,'models.mat');

if exist(modelsFileName,'file') ~= 2
    %learn models and generates models file
    models=learnModels(FileDatasetName,modelsFileName,N,F,1);
else
    models=importdata(modelsFileName);
end

relativeDistFileName=fullfile('src',dirName,'relative_distances.mat');

if exist(relativeDistFileName,'file') ~= 2    
    get_relative_distance_approximate( models,multi_features,minimum_value,relativeDistFileName,q,alpha,L);
end

display([dirName,' Done! ']);

end

