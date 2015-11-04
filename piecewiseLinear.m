function yq = piecewiseLinear( x, y, xq )
% PIECEWISELINEAR - a piecewise linear interpolation
% piecewiseLinear( x, y, xq ) interpolates the data points (x,y) and provides the values
% obtained when evaluating the interpolation at the points xq
   n = length(x);

      mx = circshift(x',-1)'- x;
      my = circshift(y',-1)'- y;
      m = my ./ mx;
      
   for i = 1:length(xq)
      xqi = xq(i);
      j = length( x( x < xqi ) );
      yq(i) = m(j) * ( xq(i) - x(j) ) + y(j);
   end
end