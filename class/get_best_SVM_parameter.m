function [ bestt bestc bestg beste bestd ] = get_best_SVM_parameter( labels,data, n_fold,t,cFrom,cTo,cStep,gFrom,gTo,gStep,eFrom,eTo,eStep,dFrom,dTo,dStep )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

    bestcv = 0;
    sizKern=size(t,2);
    %leave-one-out
    if n_fold==0
        v=size(data,1);
    else
        v=n_fold;
    end
        
% 	0 -- linear: u'*v
% 	1 -- polynomial: (gamma*u'*v + coef0)^degree
% 	2 -- radial basis function: exp(-gamma*|u-v|^2)
% 	3 -- sigmoid: tanh(gamma*u'*v + coef0)

    
    for k=1:sizKern,%kernelt
        
        for c = cFrom:cStep:cTo, %penalize parameter
            
              if t(k)==0 
                      gFromTemp=1;
                      gToTemp=1;
                      gStepTemp=1; 
              else
                     gFromTemp=gFrom;
                     gToTemp=gTo;
                     gStepTemp=gStep; 
              end
          
           for g = gFromTemp:gStepTemp:gToTemp, %gamma  
               
                  if t(k)~=1 
                          dFromTemp=1;
                          dToTemp=1;
                          dStepTemp=1; 
                  else
                         dFromTemp=dFrom;
                         dToTemp=dTo;
                         dStepTemp=dStep; 
                  end
                  
             for d = dFromTemp:dStepTemp:dToTemp, %degree
                      
                 for e = eFrom:eStep:eTo, %tollerance
                  
                 
                        cmdTmp = ['-e ', num2str(e),' -t ', num2str(t(k)),' -coef0 0 -d ', num2str(d),' -v ', num2str(v),' -c ', num2str(c), ' -g ', num2str(g)];
                        cv = svmtrain(labels, data, cmdTmp);
                        disp(cmdTmp);
                        if (cv >= bestcv),
                            bestcv = cv;
                            bestt = t(k);
                            bestc = c;
                            bestg = g;
                            beste = e;
                            bestd = d;                            
                        end
                        
                        if cv==100 
                            break;
                        end
                 end
                  
                if bestcv==100 
                        break;
                end
             end
              if bestcv==100 
                  break;
              end
          end
          if bestcv==100 
              break;
          end
        end
        if bestcv==100 
             break;
        end
    end


end

