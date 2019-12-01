function [ Mat_Rel_Dist_Normalized ] = NormalizeRelativeDistance( Mat_Rel_Dist )
%NORMALIZE [0 1] Normalize matrix on features to range [0 1]

F=size(Mat_Rel_Dist,2);
Mdl=size(Mat_Rel_Dist,1);

Mat_Rel_Dist_Normalized=zeros(Mdl,F);

for f=1:F
   
    obs_f=Mat_Rel_Dist(:,f);
    Mat_Rel_Dist_Normalized(:,f)=normalizationVector(obs_f);
        
end

end

