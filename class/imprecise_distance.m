function [ delta_lower delta_upper ] = imprecise_distance( O,FileModelName0,FileDataName0,FileModelName,FileDataName,C )
%DISTANCE get distance between two models of HMM
%INPUT 
%      O : observations from first model (F X T)
%      FileModelName: name of file Model for likelihood c++
%      FileModelData: name of file Data for likelihood c++
%      function
%      Optional iMu0,iSigma0,iMu,iSigma if continuos observation or iB0,iB if discrete observation 
%OUTPUT delta distance between the two models. R.Rabiner 1984 (Probabilitic distance for hmm)

%init

T=size(O,2);

if C==0   
      
    outFile='./out0.data'; 
    if exist(outFile,'file')==2 
        delete(outFile);
    end
    s = system(['./likelihood.exe',' ',FileModelName0,' ',FileDataName0,' ',outFile]);
    log_lik0 = importdata(outFile,' ');
    
    outFile='./out.data';
    if exist(outFile,'file')==2 
        delete(outFile);
    end
    s = system([ './likelihood.exe',' ',FileModelName,' ',FileDataName,' ',outFile]);
    log_lik = importdata(outFile,' ');    
    
else
    %???
end

delta_lower = (log_lik0(1,1) - log_lik(1,2)) * 1 / T;
delta_upper = (log_lik0(1,2) - log_lik(1,1)) * 1 / T;

end