function [Pi_SASEM,A_SASEM,Mu_SASEM,Sigma_SASEM]=get_SASEM_HMM(Pi_EM,A_EM,gamma_EM,xi_summed_EM,Mu_EM,Sigma_EM,seqQ,O,mixParam)
%get_SASEM_HMM  find SASEM parameter of neighbor (using ML estimation on seqQ and
        %O (using count method))

F=size(O,1);
N=size(Pi_EM,1);
T=size(O,2);

Pi_SEM=zeros(N,1);
for s=1:N
    if seqQ(1,1)==s
        Pi_SEM(s,1)=1;
    end
end

Pi_SASEM=mixParam * Pi_SEM + (1-mixParam) * Pi_EM;  

seqStr=num2str(seqQ);
idx= ~isspace(seqStr);
seqStr=seqStr(idx);

Num_A_SEM=zeros(N,N);
Den_A_SEM=zeros(N,N);

for i=1:N
    for j=1:N
   
        Num_A_SEM(i,j)=size(findstr(seqStr,[num2str(i),num2str(j)]),2);
        
        Den_A_SEM(i,j)=size(findstr(seqStr(1:size(seqStr,2)-1),num2str(i)),2);
        
    end
end

A_SASEM=zeros(N,N);

for i=1:N
    for j=1:N
   
        A_SASEM(i,j)=( mixParam*Num_A_SEM(i,j) + (1-mixParam) * xi_summed_EM(i,j) ) / ( mixParam*Den_A_SEM(i,j) + (1-mixParam) * sum(gamma_EM(i,1:(T-1))) )  ; 
        
    end
end

%NAN control, if i staste don't exist in sample observation i copy its
%distribution from EM distribution
for i=1:N

    if isnan(sum(A_SASEM(i,:),2))
        A_SASEM(i,:)=A_EM(i,:);
    end
    
end


Num_Mu_SEM=zeros(F,N);
Den_Mu_SEM=zeros(F,N);

for f=1:F
    for s=1:N                
                Num_Mu_SEM(f,s)= sum(O(f,seqQ==s));
                
                Den_Mu_SEM(f,s)= sum(seqQ==s);
    end
end

Mu_SEM=Num_Mu_SEM ./ Den_Mu_SEM;

Mu_SASEM=zeros(F,N);

for f=1:F
    for s=1:N                
        Mu_SASEM(f,s)=( mixParam*Num_Mu_SEM(f,s) + (1-mixParam) * (gamma_EM(s,:) * O(f,:)') ) / ( mixParam*Den_Mu_SEM(f,s) + (1-mixParam) * sum(gamma_EM(s,:)) )  ; 
    end
end

%nan control
for i=1:N
    if isnan(sum(Mu_SASEM(:,i),1))
        Mu_SASEM(:,i)=Mu_EM(:,i);
    end
    
end

Num_Sigma_SEM=zeros(F,N);
Den_Sigma_SEM=Den_Mu_SEM;

for f=1:F
    for s=1:N                
        Num_Sigma_SEM(f,s)= sum( (O(f,seqQ==s) - Mu_SEM(f,s)).^2 );
    end
end

%Sigma_SASEM=Num_Sigma_SEM ./ Den_Sigma_SEM;
Sigma_SASEM=zeros(F,N);

for f=1:F
    for s=1:N                
        Sigma_SASEM(f,s)=( mixParam*Num_Mu_SEM(f,s) + (1-mixParam) * sum( (O(f,:) - Mu_EM(f,s)).^2 .* gamma_EM(s,:)) ) / ( mixParam*Den_Sigma_SEM(f,s) + (1-mixParam) * sum(gamma_EM(s,:)) )  ; 
        if Sigma_SASEM(f,s)<0.0001,
                   Sigma_SASEM(f,s)=0.0001;
        end;
    end
end

%nan control
for i=1:N
    if isnan(sum(Sigma_SASEM(:,i),1))
        Sigma_SASEM(:,i)=Sigma_EM(:,i);
    end
    
end
       
end

