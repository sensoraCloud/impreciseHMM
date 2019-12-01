function [ classes ] = classification( models_test , minimum_value ,label_group , relative_distances , multi_features , type,k,distance,fun,cmd, varargin  )
%K-NEAREST-NEIGHBOR Classify data using nearest neighbor method. Calculate
%for each models train the distance HSD (paper. "A new distance measure for Hidden Markov Models" Jianping Zeng,... ) from model test and get class with minimum dustance from model test using knn alg.
%INPUT models_test : models will be classified  { [ Pi , A, Mu, Sigma ] } or
%                   { [ Pi , A, B ] } or Distances Ref vector of (HSD 1XF)
%      minimum_value  : reference model with calculate distance
%      label_group : label class of relative distances model
%      relative_distance : relative distances from reference model
%      k: 	the number of nearest neighbors used in the classification
%  multi_features : if 0 get sum of HSD distance calculated for each
%                   features and if 1 return distance of each features
%OPIONAL    alpha (for stationaries probabilities accuracy)    for discrete HMMs
%        or q,alpha,L     for continuos HHMs 
%(q (for min max outcome accurary es. 3); alpha (for stationaries
%probabilities accuracy es. 1e-7); L (for distance HSD accuracy) )
%OUTPUT class : predict class number

if (size(varargin,2)>1)   
    q=varargin{1};
    alpha=varargin{2};
    L=varargin{3};    
    C=1;    
else    
    alpha=varargin{1};  
    C=0;   
end 

if type~=3

    siz=size(models_test,1);

    for i=1:siz

        %if model_test is model then calculate HSD relative
        if iscell(models_test)==1

            model_test=models_test{i,1};

            %calculate distance 
             if C==1

                  [ hsdDist(i,:) ] = distance_HSD_approximate(model_test{1},model_test{2},model_test{5},multi_features,minimum_value,model_test{3},model_test{4},q,alpha,L );


             else

                  [ hsdDist(i,:) ] = distance_HSD_approximate(model_test{1},model_test{2},model_test{5},multi_features,minimum_value,model_test{3},alpha );

             end
        else
            hsdDist(i,:)=models_test(i,:);
        end


    end

else
    
    %interval kernel
    
    %min train distance
    distance_test_min=models_test{1,1}; 
    %max train distance
    distance_test_max=models_test{1,2}; 
    
    %min test distance
    distance_train_min=relative_distances{1,1};
    %max test distance
    distance_train_max=relative_distances{1,2};
    
    gammaKernel=0.5; %RBF interval kernel    
    mNorm=1; %normalized kernel
    typeDist=1; %1 Hausdorff Distance, 2 min , 3 max , 4 mean
    distanceKernel='euclidean'; 
    
    learn_kernel = get_interval_kernel( distance_train_min , distance_train_max, distance_train_min , distance_train_max, gammaKernel ,mNorm,typeDist,distanceKernel );
    
    %for LIBSVM tool
    learn_kernel=[(1:size(learn_kernel,1))' , learn_kernel];
      
    test_kernel = get_interval_kernel( distance_test_min , distance_test_max ,distance_train_min , distance_train_max,gammaKernel,mNorm,typeDist,distanceKernel  );    
       
    test_kernel=[ (1:size(test_kernel,1))' , test_kernel];
    
end

switch logical(true)
    %KNN
    case type==0, classes = knnclassify(hsdDist, relative_distances , label_group, k,distance);
        %Discriminant function
    case type==1, [classes,err,post,logl,str]= classify(hsdDist,relative_distances , label_group,fun);
        %SVM
    case type==2, model = svmtrain(label_group, relative_distances, cmd);
        [classes, accuracy, decision_values] = svmpredict(ones(size(hsdDist,1),1),hsdDist,model);
        %interval kernel SVM
    case type==3, model = svmtrain(label_group, learn_kernel ,  '-t 4' ); % can set also e and c parameter '-e 0.001 -c 10' 
        [classes, accuracy, decision_values] = svmpredict(ones(size(test_kernel,1),1),test_kernel,model);
        %interval dominance imprecise
    case type==4,         
        
        min_ref=inf;
        max_ref=-inf;
        
        train_dist_size=size(label_group,1);
        test_dist_size=size(hsdDist,1);
        intervals=cell(1,train_dist_size);
        
        for i=1:train_dist_size
            
            dists=[];
            
            for j=1:test_dist_size
                
                d=pdist2(hsdDist(j,:),relative_distances{1}(relative_distances{1}(:,end)==relative_distances{2}(i,1),1:end-1),'euclidean');
                
                dists=[dists d];
                
            end            
            
            intervals{1,i}(1,1)=min(dists);
            intervals{1,i}(1,2)=max(dists);
            
            if intervals{1,i}(1,1)<min_ref
                min_ref=intervals{1,i}(1,1);
                max_ref=intervals{1,i}(1,2);
            end
            
        end
        
        count=1;
        
        for i=1:train_dist_size
            
            if intervals{1,i}(1,1)<=max_ref
                classes(1,count)=label_group(i,1);
                count=count+1;                
            end
                        
        end        
        
        classes=unique(classes);
        
        %interval dominance precise == K-NN con k=1
    case type==5,         
        
         classes = knnclassify(hsdDist, relative_distances , label_group, k,distance);
        
end


end