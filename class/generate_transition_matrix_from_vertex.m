function [ transition_matrices ] = generate_transition_matrix_from_vertex( vertex_transition )
%GENERATE TRASITION MATRIX FROM VERTEX get all permutation of trasition
%matrices from vertex of transition parobabilities ditribution of iHMM

%create multi sets
N=size(unique(vertex_transition(:,end)),1);

%sets of indexes
sets=cell(1,N);

for s=1:N

    sets{1,s}=find(vertex_transition(:,end)==s);
    
end

%get all permutations of transition probabilities vertex
perm=cartprod(sets);

sizPerm=size(perm,1);

transition_matrices=cell(1,sizPerm);

transition_m=zeros(N,N);

for p=1:sizPerm
   
    for s=1:N
       
       transition_m(s,:)= vertex_transition(perm(p,s),1:end-1);
        
    end
    
    transition_matrices{1,p}=transition_m;
    
end

end

