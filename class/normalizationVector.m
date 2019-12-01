
function [xnorm] = normalizationVector(x)
%NORMALIZE [0 1] Normalize vector to range [0 1]
    xmin = min(x(:));
    xmax = max(x(:));
    if xmin == xmax
        % Constant matrix -- I choose to warn and return a NaN matrix
        warning('normalization:constantMatrix', 'Cannot normalize a constant matrix to the range [0, 1].');
        xnorm = nan(size(x));
    else
        xnorm = (x-xmin)./(xmax-xmin);
    end

end