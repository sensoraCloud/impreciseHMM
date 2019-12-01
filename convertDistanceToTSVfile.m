addpath('impreciseMarkovChain');

%normalize
relative_distances{1,2} = (relative_distances{1,2} -repmat(min(relative_distances{1,2},[],1),size(relative_distances{1,2},1),1))*spdiags(1./(max(relative_distances{1,2},[],1)-min(relative_distances{1,2},[],1))',0,size(relative_distances{1,2},2),size(relative_distances{1,2},2));
   
sizeR=size(relative_distances{1,1},1);

fid = fopen('datasetKTH.TSV', 'a');

Nbit=size(unique(relative_distances{1,1}(:,1)),1);

for d=1:sizeR
   
    binaryClass = get_binary_control(relative_distances{1,1}(d,1),Nbit,0);

    classStr=sprintf('%g\t', binaryClass);

    fprintf(fid, '%s \t %s\r\n', sprintf('%g\t', relative_distances{1,2}(d,:)) ,classStr );
    
end

fclose(fid);



