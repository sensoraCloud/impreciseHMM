function [ vertex_trans ] = get_vertex_transition( iA )
%VERTICES TRANSITION get vertices of simplex probabilities of each
%transition probabilities

N=size(iA,1);

Lpri=zeros(N,N);
Upri=zeros(N,N);

for i=1:N
        for j=1:N
            Lpri(i,j)=iA{i,j}(1,1);
            Upri(i,j)=iA{i,j}(1,2);
        end
end

vertex_trans=[];

for s=1:N
  
    vert = get_imprecise_simplex_vertex_from_low_up( Lpri(s,:),Upri(s,:) );
    
    vert=[vert (ones(size(vert,1),1)*s)];
    
    vertex_trans=[vertex_trans;vert]; 
    
    
end

end

