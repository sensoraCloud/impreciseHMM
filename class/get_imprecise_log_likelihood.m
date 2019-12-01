function [ log_lik ] = get_imprecise_log_likelihood( O,FileModelName,FileDataName,C )
%GET IMPRECISE LOGLIKELIHOOD 

if C==0   
      
    outFile='out0.data'; 
    if exist(outFile,'file')==2 
        delete(outFile);
    end
    s = system(['./likelihood.exe',' ',FileModelName,' ',FileDataName,' ',outFile]);
    log_lik = importdata(outFile,' ');
    
        
else
    %???
end

end

