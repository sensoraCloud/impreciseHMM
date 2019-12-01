function [ class  ] = probabilisticHMM_classify_model(  models_train , O  )




cls=size(models_train,1);
mdl=size(models_train,2);


%calculate distance models training to model test 
maxProb=-inf;
class=1;
for c=1:cls
        
    for m=1:mdl
        
        if isempty(models_train{c,m})==0
        
            model_train=models_train{c,m};
                        
            prob=log_probObs( model_train{1},model_train{2},O,model_train{3},model_train{4},[]);
            
            if prob > maxProb
                maxProb=prob;
                class=c;
            end
                
        
        end
        
    end
end

end