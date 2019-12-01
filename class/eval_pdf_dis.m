function [ seq_prob_dis ] = eval_pdf_dis( O,B,t,varargin )
%EVAL PDF DISCRETE returns for each time the probability of each state having
%observed O 
%INPUT O : observations (F X T)
%      B : emission probability (NxMxF) (states x obs.cardinality x num.features)
%      t : eval util time t of the sequence 
%      Optional st state, if set st return only the probability of state s at time t 
%OUTPUT seq_prob_dis matrix NxT (states X sequence) 
%       seq_prob_dis(i,t) = Pr(O(t)| Q(t)=i)

if (size(varargin,2)>0)
    st=varargin{1};
    F=size(O,1);
    seq_prob_dis=1;
    for f=1:F
        seq_prob_dis=seq_prob_dis*B(st,O(f,t),f);
    end 
else
    T=size(O,2);

    if (t>T)
        error('t must be less than the number of observations');
    end

    F=size(O,1);
    N=size(B,1);
    seq_prob_dis=zeros(N,t);

    for t2=1:t
        for s=1:N
            seq_prob_dis(s,t2)=1;
            for f=1:F
                seq_prob_dis(s,t2)=seq_prob_dis(s,t2)*B(s,O(f,t2),f);
            end
        end
    end
end

end

