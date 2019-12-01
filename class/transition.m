function [ next_state ] = transition( current_state , A )
%TRANSITION returns a state according to the distribution matrix A

next_state = generates_state(A(current_state,:));

end

