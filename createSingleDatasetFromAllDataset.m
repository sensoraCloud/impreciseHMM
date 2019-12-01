featuresFileName=fullfile('src','features','dataset.mat');

newFeaturesFileName=fullfile('src','features','WeizSimpleFeature5.mat');

fts=importdata(featuresFileName);

d=fts.data;

cls=size(d,1);
mdls=size(d,2);

newfts=cell(cls,mdls);

for c=1:cls
    
    for m=1:mdls
        
         if ~isempty(d{c,m})    
        
            newfts{c,m} = [d{c,m}.features_normalized_smooth5; d{c,m}.features_normalized_smooth5_diff1];
    
            %apply rumur for zero over time problem
            newfts{c,m}=newfts{c,m}+rand(size(newfts{c,m}))/10000;
            
         end
        
    end
    
end

save(newFeaturesFileName,'newfts');

