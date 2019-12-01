function [ classes  ] = probabilisticImprecise_HMM_classify_model(  models_train , O ,  typeClassification )
%typeClassification:
%    1 max min
%    2 max max
%    3 interval dominance (can return more of one class)

cls=size(models_train,1);
mdl=size(models_train,2);
%calculate distance models training to model test 
maxProb=-inf;
classes=1;

 if typeClassification==3 %interval dominance
    
     intervals=cell(1,(cls*mdl)-1);
     labels=ones(1,(cls*mdl)-1);
     i=1;
      
 end


 
for c=1:cls
        
    for m=1:mdl
        
        if isempty(models_train{c,m})==0
        
            model_train=models_train{c,m};
            
            %get discrete iHMM for Denis algorithm
            [ iB Odisc ] = discretizediImpreciseHmm( model_train{2},O,model_train{3},model_train{4});
            
            %generete input file for Denis algorithm
            generateFileModelData( model_train{1},model_train{2},Odisc,'mod',iB);
                
            log_lik=get_imprecise_log_likelihood( Odisc,'mod.model','mod.data',0 );
            
            if typeClassification==1 %max min
                prob=log_lik(1,1);
                
            elseif typeClassification==2 %max max
                prob=log_lik(1,2);
                
            else %interval dominance  
                prob=log_lik(1,1);     
                intervals{1,i}=log_lik;
                labels(1,i)=c;
                i=i+1;
            end
            
            if prob > maxProb
                maxProb=prob;
                classes(1,1)=c;
            end
           
             
            
        end
        
    end
end

 if typeClassification==3 %interval dominance
     siz=size(labels,2);
     count=2;
     for i=1:siz
         %if upper interval is greater than the max min founded.. 
         if intervals{1,i}(1,2)>maxProb
             %if sum(classes==labels(1,i))==0 
                classes(1,count)=labels(1,i);
                count=count+1;
            %end
         end
     end
     
     classes=unique(classes);
     
 end

end