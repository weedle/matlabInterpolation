function yq = cubicComplete( x, y, xq, fpo, fpn )
% CUBICSPLINE - A complete cubic spline interpolation
% cubicSpline( x, y, xq, fpo, fpn ) interpolates the data points (x,y) and provides 
% the values obtained when evaluating the interpolation at the points xq
% fpo and fpn are the derivative values at x0 and xn, respectively
% This interpolation follows the implementation described in the
% Burden-Faires text (p148)
   n = length(x);

   for i = 1:n-1
      h(i) = x(i+1) - x(i);
   end
  
   alpha(1) = 3*( y(2) - y(1) ) / h(1) - 3*fpo;
   alpha(n) = 3*fpn - 3*( y(n) - y(n-1) ) / h(n-1);
   
   for i = 2:n-1
      alpha(i) = ( 3/h(i) ) * ( y(i+1) - y(i) ) - ( 3/h(i-1) ) * ( y(i) - y(i-1) );
   end
   
   l(1) = 2*h(1);
   u(1) = 0.5;
   z(1) = alpha(1) / l(1);
   
   for i = 2:n-1
      l(i) = 2*( x(i+1) - x(i-1) ) - h(i) * u(i-1);
      u(i) = h(i) / l(i);
      z(i) = ( alpha(i) - h(i-1) * z(i-1) ) / l(i);
   end
   
   l(n) = h(n-1) * ( 2 - u(n-1) );
   z(n) = ( alpha(n) - h(n-1) * z(n-1) ) / l(n);
   c(n) = z(n);
   
      
   for j = 1:n-1
      j = n - j;
      c(j) = z(j) - u(j) * c(j+1);
      b(j) = ( y(j+1) - y(j) ) / h(j) - h(j) * ( c(j+1) + 2 * c(j) ) / 3;
      d(j) = ( c(j+1) - c(j) ) / ( 3 * h(j) );
   end
   
   for i = 1:length(xq)
      xqi = xq(i);
      j = length( x( x < xqi ) );
      %fprintf( '%d %d %d\n', x(j), xqi, x(j+1) );
      yq(i) = y(j) + b(j) * ( xqi - x(j) ) + c(j) * ( xqi - x(j) )^2 + d(j) * ( xqi - x(j) )^3;
   end
end