function yq = cubicSpline( x, y, xq )
% CUBICSPLINE - A natural cubic spline interpolation
% cubicSpline( x, y, xq ) interpolates the data points (x,y) and provides the values
% obtained when evaluating the interpolation at the points xq
% This interpolation follows the implementation described in the
% Burden-Faires text (p146)
   n = length(x);

   for i = 1:n-1
      h(i) = x(i+1) - x(i);
   end
   h(length(y)) = h(1);
   
   yM = y - circshift(y',+1)';
   yP = circshift(y',-1)' - y;
   hM = circshift(h',+1)';
   
   a = (3./h) .* yP - (3./hM) .* yM;
   
   l(1) = 1;
   u(1) = 0;
   z(1) = 0;
   
   xP = circshift(x',-1)';
   xM = circshift(x',+1)';
   uM = circshift(u',+1)';
   hM = circshift(h',+1)';
   zM = circshift(z',+1)';
   
   for i = 2:n-1
      l(i) = 2 * ( x(i+1) - x(i-1) ) - h(i-1) * u(i-1);
      u(i) = h(i)/l(i);
      z(i) = ( a(i) - h(i-1) * z(i-1) ) / l(i);
   end
   %l = 2 * ( xP - xM ) - hM .* uM;
   %u = h ./ l;
   %z = ( a - ( hM .* zM ) ) ./ l;
   
   l(n) = 1;
   z(n) = 0;
   c(n) = 0;
   
   for j = n-1:-1:1
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