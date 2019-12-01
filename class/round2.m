function z = round2(x,y)
%ROUND2 floor number to with n decimals y=0,0..0^(n)1.

error(nargchk(2,2,nargin))
error(nargoutchk(0,1,nargout))
if numel(y)>1
  error('Y must be scalar')
end

z = floor(x/y)*y;
