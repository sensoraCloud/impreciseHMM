function [locsMAX pksMAX locsMIN pksMIN]=peakseek(x,minpeakdist,minpeakh)
% Alternative to the findpeaks function.  This thing runs much much faster.
% It really leaves findpeaks in the dust.  It also can handle ties between
% peaks.  Findpeaks just erases both in a tie.  Shame on findpeaks.
%
% x is a vector input (generally a timecourse)
% minpeakdist is the minimum desired distance between peaks (optional, defaults to 1)
% minpeakh is the minimum height of a peak (optional)
%
% (c) 2010
% Peter O'Connor
% peter<dot>ed<dot>oconnor .AT. gmail<dot>com

if size(x,2)==1, x=x'; end

% Find all maxima and ties
locsMAX=find(x(2:end-1)>=x(1:end-2) & x(2:end-1)>=x(3:end))+1;

locsMIN=find(x(2:end-1)<=x(1:end-2) & x(2:end-1)<=x(3:end))+1;

if nargin<2, minpeakdist=1; end % If no minpeakdist specified, default to 1.

if nargin>2 % If there's a minpeakheight
    locsMAX(x(locsMAX)<=minpeakh)=[];
    locsMIN(x(locsMIN)<=minpeakh)=[];    
end

if minpeakdist>1
    
    %MAX
    while 1

        del=diff(locsMAX)<minpeakdist;

        if ~any(del), break; end

        pksMAX=x(locsMAX);

        [garb mins]=min([pksMAX(del) ; pksMAX([false del])]); %#ok<ASGLU>

        deln=find(del);

        deln=[deln(mins==1) deln(mins==2)+1];

        locsMAX(deln)=[];

    end
    
    %MIN
    while 1

        del=diff(locsMIN)<minpeakdist;

        if ~any(del), break; end

        pksMIN=x(locsMIN);

        [garb mins]=min([pksMIN(del) ; pksMIN([false del])]); %#ok<ASGLU>

        deln=find(del);

        deln=[deln(mins==1) deln(mins==2)+1];

        locsMIN(deln)=[];

    end
    
end

if nargout>1,
    pksMAX=x(locsMAX);
    pksMIN=x(locsMIN);    
end


end