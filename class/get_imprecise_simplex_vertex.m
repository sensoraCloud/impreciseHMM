function [ vertex ] = get_imprecise_simplex_vertex( lower_subset , subset_index )
%get_imprecise_simplex_vertex 
%INPUT 
%lower_subset [l1 .. l] lower subsets probabilties 
%subset_index binary matrix that identify subset
%
%OUTPUT
% vertex (vertices X N) 

%number of singleton
N=sum(sum(subset_index,2)==1);
%N=size(lower,2);

if N<2
    error(' N must be >=2 !! ');
elseif N==2
        
    %lower
    contr = get_binary_control(1,N,0);
    idx   = get_index_control( subset_index,contr );
    lower1=lower_subset(1,idx);
    
    %upper
    contr = get_binary_control(1,N,1);
    idx   = get_index_control( subset_index,contr );
    upper1=1-lower_subset(1,idx);
    
    %lower
    contr = get_binary_control(2,N,0);
    idx   = get_index_control( subset_index,contr );
    lower2=lower_subset(1,idx);
    
    %upper
    contr = get_binary_control(2,N,1);
    idx   = get_index_control( subset_index,contr );
    upper2=1-lower_subset(1,idx);
    
    vertex(1,:)=[lower1 upper2];
    vertex(2,:)=[upper1 lower2];
    
else
    
    %A x <= b
    
    %truncate value at 3 decimals and get reachable
    %[ lower,upper ] = get_reachable_imprecise_prob( lower,upper );
    
    %remove the last variable
    A=subset_index(:,1:end-1) - repmat(subset_index(:,end),1,N-1);
    
    lower_subset=lower_subset'-subset_index(:,end);    
    
    %change sign
    A=A*-1;
    
    lower_subset=lower_subset*-1;
    
    %get variables  sum 1
    A=[A;ones(1,N-1)];    
    lower_subset=[lower_subset;1];

    [V,nr]=con2vert(A,lower_subset);
    
    vertex=[V ones(size(V,1),1)-sum(V,2)];

    if sum(sum(vertex,1))~=size(vertex,1)
        disp('Warning some vertex doesn t sum to 1 !!!!');	  	
	    disp(vertex);
        disp(sum(sum(vertex,1)));
        vertex=mk_stochastic(vertex);
    end

end


end

