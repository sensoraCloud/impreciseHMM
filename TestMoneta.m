    clear all
    
    F=1;
    N=2;
    M=1;
    s=2;
    
    PiTest=[.5 .5]';
    ATest=[ 0.7 0.3; 0.5 0.5];
    MuTest=[ 1 -1];
    SigmaTest=[ 0.1  0.1];
       
    
    NumTrials=15;
    k=8;
    T=5;
    
    lowerValue=zeros(1,NumTrials);
    upperValue=zeros(1,NumTrials);    
    preciseValue=zeros(1,NumTrials);
    
    
    %ATest
           
    Tinit=200;
    [ obsInit ] = sequenceGenerator( PiTest,ATest,Tinit,MuTest,SigmaTest,ones(N,1));

    %random gaussiane
    [MuInit SigmaInit]=init_Mu_Sigma( obsInit ,N,M );
    PiInit=ones(N,1) ./ N;
    AInit=ones(N,N) ./ N;
    
    %k means
   % [PiInit, AInit, MuInit, SigmaInit,mixmatInit] = init_segment_kmeans(obsInit,M, N);
    
    %a mano
%     PiInit=[1 0]';
%     AInit=[ 0.9 0.1; 0.3 0.7];
%     MuInit=[ 1 -1];
%     SigmaInit=[ 0.5  0.5];
       
    
    for trial=1:NumTrials
        
        for km=1:k
        
            [ obs ] = sequenceGenerator( PiTest,ATest,T,MuTest,SigmaTest,ones(N,1));
            
            [ iPiInit,iAInit,Pi,A,mixmat,MuInit,SigmaInit,log_lik ] = hmm_EM( obs,PiInit,AInit,ones(N,1),100,s,MuInit,SigmaInit );


            %select minor
            if A(1,1)>A(1,2)

                lowerValue(1,km)=iAInit{1,1}(1,1);
                upperValue(1,km)=iAInit{1,1}(1,2);

                preciseValue(1,km)=A(1,1);

            else

                lowerValue(1,km)=iAInit{1,2}(1,1);
                upperValue(1,km)=iAInit{1,2}(1,2);

                preciseValue(1,km)=A(1,2);

            end

        end
        
        T=T+8;
        
        lowerValueF(1,trial)=sum(lowerValue(1,:),2)/k;
        upperValueF(1,trial)=sum(upperValue(1,:),2)/k;
        
        preciseValueF(1,trial)=sum(preciseValue(1,:),2)/k;
              
        
        realValue(1,trial)=ATest(1,1);
        
    end
    
    %P
    %A        
        
    close all
    plot(lowerValueF,'x-y');
    hold on
    plot(upperValueF,'x-b');
    hold on
    plot(preciseValueF,'x-g');
    hold on
    plot(realValue,'x-r');   
    

% use sprintf to convert the numeric data to text, using %e
lll = sprintf('%e\t',lowerValueF);
uuu = sprintf('%e\t',upperValueF);
ppp = sprintf('%e\t',preciseValueF);
rrr = sprintf('%e\t',realValue);


% use strrep to replace exponent prefix with shorter version
%a_str = strrep(a_str,'e+0','e+');
%a_str = strrep(a_str,'e-0','e-');

% call fprintf to print the updated text strings
fid = fopen('plotto.tkz','w');
for i=1:NumTrials,
fprintf(fid, '\\fill[color=blue](%6.2f,%6.2f) circle(.4pt);\n', i/10,lll(i)/100);
fprintf(fid, '\\fill[color=red](%6.2f,%6.2f) circle(.4pt);\n', i/10,uuu(i)/100);
fprintf(fid, '\\fill[color=green](%6.2f,%6.2f) circle(.4pt);\n', i/10,ppp(i)/100);
fprintf(fid, '\\fill[color=black](%6.2f,%6.2f) circle(.4pt);\n', i/10,rrr(i)/100);
end
fclose(fid);

% view the contents of the file
type plotto.txt

 
