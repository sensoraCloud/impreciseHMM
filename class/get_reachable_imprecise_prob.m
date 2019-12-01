function [ lowerR,upperR ] = get_reachable_imprecise_prob( lower,upper )
%get_reachable_imprecise_prob 
%INPUT 
%lower [l1 .. lN] imprecise interval  probabilities 
%upper [u1 .. uN] imprecise interval  probabilities 
%
%OUTPUT
%lower [l1 .. lN] imprecise interval reachable probabilities 
%upper [u1 .. uN] imprecise interval reachable probabilities


N=size(lower,2);

lowerR=zeros(1,N);
upperR=zeros(1,N);

for i=1:N 
    lowerR(1,i)=round2(lower(1,i),0.0001);
    upperR(1,i)=round2(upper(1,i),0.0001)+0.0001;
end

memLowerR=lowerR;
memUpperR=upperR;

for i=1:N 
    app=memUpperR;
    app2=memLowerR;
    app(1,i)=0;
    lowerR(1,i)=max(lowerR(1,i),1-sum(app,2));
    app2(1,i)=0;
    upperR(1,i)=min(upperR(1,i),1-sum(app2,2));
end


end

