function [ initial_state ] = init_state( Pi )
%INIT STATE returns the initial state according to the distribution Pi
%   Pi discrete distribution of the states 1,..,N

initial_state = generates_state(Pi);

end

