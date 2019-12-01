function [ kernel ] = get_interval_kernel( relative_distances_min1 , relative_distances_max1 , relative_distances_min2 , relative_distances_max2 ,gamma,m,typeDist,distance )
% Hausdorff distance Kernel RBF exp(-gamma*dhd^2)
% The Hausdorff Distance between two sets of points, P and Q
% (which could be two trajectories) in two dimensions. Sets P and Q must,
% therefore, be matricies with an equal number of columns (dimensions),
% though not necessarily an equal number of rows (observations).
%
% The Directional Hausdorff Distance (dhd) is defined as:
% dhd(P,Q) = max p c P [ min q c Q [ ||p-q|| ] ].
% Intuitively dhd finds the point p from the set P that is farthest from any
% point in Q and measures the distance from p to its nearest neighbor in Q.d
% 
% The Hausdorff Distance is defined as max{dhd(P,Q),dhd(Q,P)}

cls1=size(relative_distances_min1,1);
cls2=size(relative_distances_min2,1);

kernel=zeros(cls1,cls2);

relative_distances_min_tr=relative_distances_min2';
relative_distances_max_tr=relative_distances_max2';



for c1=1:cls1
    for c2=1:cls2
   
        if typeDist==1
        
            kernel(c1,c2)=  exp(- (gamma/m) *(HausdorffDist([relative_distances_min1(c1,:);relative_distances_max1(c1,:)],[relative_distances_min_tr(:,c2)';relative_distances_max_tr(:,c2)']))^2) ;
        
        elseif typeDist==2 %min distance
            
            kernel(c1,c2)=  exp(- (gamma/m) *(pdist2(relative_distances_min1(c1,:),relative_distances_min_tr(:,c2)',distance))^2) ;
            
        elseif typeDist==3 %max distance
            
           kernel(c1,c2)=  exp(- (gamma/m) *(pdist2(relative_distances_max1(c1,:),relative_distances_max_tr(:,c2)',distance))^2) ;
                         
        else %mean of interval
            
            kernel(c1,c2)=  exp(- (gamma/m) *(pdist2((relative_distances_max1(c1,:) + relative_distances_min1(c1,:))./2,(relative_distances_max_tr(:,c2)'+relative_distances_min_tr(:,c2)')./2,distance))^2) ;
                         
        end
        
    end
end


end

% 'euclidean'	
% 
% Euclidean distance (default).
% 'seuclidean'	
% 
% Standardized Euclidean distance. Each coordinate difference between rows in X and Y is scaled by dividing by the corresponding element of the standard deviation computed from X, S=nanstd(X). To specify another value for S, use D = PDIST2(X,Y,'seuclidean',S).
% 'cityblock'	
% 
% City block metric.
% 'minkowski'	
% 
% Minkowski distance. The default exponent is 2. To compute the distance with a different exponent, use D = pdist2(X,Y,'minkowski',P), where the exponent P is a scalar positive value.
% 'chebychev'	
% 
% Chebychev distance (maximum coordinate difference).
% 'mahalanobis'	
% 
% Mahalanobis distance, using the sample covariance of X as computed by nancov. To compute the distance with a different covariance, use D = pdist2(X,Y,'mahalanobis',C) where the matrix C is symmetric and positive definite.
% 'cosine'	
% 
% One minus the cosine of the included angle between points (treated as vectors).
% 'correlation'	
% 
% One minus the sample correlation between points (treated as sequences of values).
% 'spearman'	
% 
% One minus the sample Spearman's rank correlation between observations, treated as sequences of values.
% 'hamming'	
% 
% Hamming distance, the percentage of coordinates that differ.
% 'jaccard'	
% 
% One minus the Jaccard coefficient, the percentage of nonzero coordinates
% that differ.

