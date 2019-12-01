function [ idx ] = get_index_control( f_matrix,control )
%GET INDEX CONTROL 

N=size(f_matrix,2);

found=0;

idx=0;

while found==0,

    idx=idx+1;
    
    if sum(f_matrix(idx,:)==control)==N
        found=1;
    end
    
end

