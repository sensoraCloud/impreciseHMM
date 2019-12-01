% calculates the (generalised) lower probability if initial lower probability initL and lower transition matrix are given
% t is the type of calculation t="f": forward; t="b": bacward calculation
function retL = markovSteps(fnals, initL, transL, nsteps)
retL = initL;
Lw = transL;
for st = 1:(nsteps-1)
    
    for i = 1:length(transL(:, 1))
        for j = 1:length(transL(1, :))
            X = Lw(:, j);
            [l, p] = lowerExpSet(transL(i,:)', fnals, X);
            Lnew(i, j) = l;
        end
    end
    
    Lw = Lnew;
    
end
%then multiply the result with initL
for j = 1:length(transL(1, :))
    X = Lw(:, j);
    [l, p] = lowerExpSet(initL', fnals, X);
    Ln(j) = l;
end
retL = Ln;