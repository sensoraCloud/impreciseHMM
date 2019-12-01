function [ vertex ] = get_imprecise_simplex_vertex_from_low_up( lower,upper )
%get_imprecise_simplex_vertex 
%INPUT 
%lower [l1 .. lN] imprecise interval (reachable) probabilities 
%upper [u1 .. uN] imprecise interval (reachable) probabilities 
%
%OUTPUT
% vertex (vertices X N) 

N=size(lower,2);

if N<2
    error(' N must be >=2 !! ');
elseif N==2
    
    vertex(1,:)=[lower(1,1) upper(1,2)];
    vertex(2,:)=[upper(1,1) lower(1,2)];
    
else
    
    %truncate value at 3 decimals and get reachable
    [ lower,upper ] = get_reachable_imprecise_prob( lower,upper );
    
    A=[eye(N-1,N-1);eye(N-1,N-1)*-1;ones(1,N-1);ones(1,N-1)*-1];
    
    b=[upper(1,1:(end-1)) (lower(1,1:(end-1))*-1) -lower(1,end)+1 upper(1,end)-1 ];
    
%     for i=1:N
%         b(1,i)=upper(1,count);
%         b(1,i+1)=lower(1,count) * -1;
%         count=count+1;
%     end
%     
%     A=zeros(N*2,N-1);
%     b=zeros(1,N*2);
%     count=1;
%     
%     for i=1:+2:((N-1)*2)
%         row=zeros(1,N-1);
%         row2=row;
%         row2(1,count)=1;
%         A(i,:)=row2;
%         row2=row;
%         row2(1,count)=-1;
%         A(i+1,:)=row2;        
%         b(1,i)=upper(1,count);
%         b(1,i+1)=lower(1,count) * -1;
%         count=count+1;
%     end
%     
%     A(((count-1)*2)+1,:)=ones(1,N-1)*-1;
%     A(((count-1)*2)+2,:)=ones(1,N-1);
%     b(1,((count-1)*2)+1)=upper(1,count)-1;
%     b(1,((count-1)*2)+2)=(lower(1,count) * -1) +1;  
%     
    [V,nr]=con2vert(A,b');
    
    vertex=[V ones(size(V,1),1)-sum(V,2)];
	
    if sum(sum(vertex,1))~=size(vertex,1)
        disp('Warning some vertex doesn t sum to 1 !!!!');	  	
	    disp(vertex);
        disp(sum(sum(vertex,1)));
        vertex=mk_stochastic(vertex);
    end


end


end

