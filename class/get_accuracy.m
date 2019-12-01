function [ accuracy ] = get_accuracy( confusion_matrix )
%ACCURACY get accuracy from confusion matrix

   s=sum(confusion_matrix,2);
   
    classValued=0;
    for i=1:size(s,1)
        if s(i,1)~=0
            confusion_matrix(i,:)=confusion_matrix(i,:) * 1/s(i,1);
            classValued=classValued+1;
        end
    end
    
    accuracy=sum(diag(confusion_matrix)) * 1 / classValued;

end

