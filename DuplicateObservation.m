featuresFileName=fullfile('src','features','PCAWeizSimpleFeature5.mat');
newFeaturesFileName=fullfile('src','features','TriplicatePCAWeizSimpleFeature5.mat');
fts=importdata(featuresFileName);

cls=size(fts,1);
mdls=size(fts,2);

newfts=cell(cls,mdls);

for c=1:cls
    
    for m=1:mdls
        
         if ~isempty(fts{c,m})    
        
            newfts{c,m} = [ fts{c,m} fts{c,m} fts{c,m}];
    
         end
        
    end
    
end

save(newFeaturesFileName,'newfts');