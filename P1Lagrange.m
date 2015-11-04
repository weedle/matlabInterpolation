function yq = P1Lagrange( x, y, xq )
% P1LAGRANGE - a polynomial interpolating using the Lagrange polynomials
% P1Lagrange( x, y, xq ) interpolates the data points (x,y) and provides the values
% obtained when evaluating the interpolation at the points xq,using the
% barycentric form of the Lagrange interpolation
   i = 1;
   for xqi = xq
      b = bary( x, xqi );
      yq( i ) = b*y';
      i = i + 1;
   end
end
function b = bary(xk, x)
    for i = ( 1:length( xk ) )
       b( i ) = w( xk, x ) * sum( 1 / ( ( x - xk( i ) ) * dw( xk, xk(i) ) ) );
    end
end

function w = w(xk, x)
    w = prod( x - xk );
end

function dw = dw(xk, x)
    dw = 0;
    for i = ( 1:length( xk ) )
        p = prod( x- xk( [1:i-1, i+1:end] ) );
        dw = dw + p;
    end
end