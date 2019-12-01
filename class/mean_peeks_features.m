function [ N ] = mean_peeks_features( featuresFileName )
%MEAN PEEKS FEATURES get mean of number of MAX local peeks over each
%features of each model

fts=importdata(featuresFileName);

cls=size(fts,1);
mdls=size(fts,2);


minpeakdist=0.1;
minpeakh=-99999999999999;

i=1;

for c=1:cls
 
    for m=1:mdls

             if ~isempty(fts{c,m})    
                
                 F=size(fts{c,m},1);
                 
                 %F=15;
                 
                 for f=1:F 
                 
                    [locsMAX pksMAX locsMIN pksMIN]=peakseek(fts{c,m}(f,:),minpeakdist,minpeakh); 
                    
                    eps=0.1;
                    differentPeeks=[];
                    count=1;
                    for p=1:size(pksMAX,2)

                        discard=0;
                        for d=1:size(differentPeeks,2)

                            if  (( (differentPeeks(1,d) - eps) <= pksMAX(1,p) ) && (pksMAX(1,p) <= (differentPeeks(1,d) + eps) ) )
                                discard=1;
                            end

                        end

                        if discard==0
                            differentPeeks(1,count)=pksMAX(1,p);
                            count=count+1;
                        end

                    end
                    plot(fts{c,m}(f,:))
                    numPeeks(1,i)=size(differentPeeks,2);
                    
                    i=i+1;
                    
                 end

             end

    end
        
end

N=round(sum(numPeeks)/size(numPeeks,2));


end

