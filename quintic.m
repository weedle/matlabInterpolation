function yq = quintic( x, y, xq )
% An algorithm for the interpolation of functions using quintic splines
% E.H. Mund, P. Hallet, J.P. Hennart
   alpha = sqrt(64/3);
   n = length(x);
   A = 0*ones(2,2,n);
   B = A;
   h = circshift( x, [0 -1] ) - x;
   g = h.^-1;
   k = 0*ones( 2, n );
   M = 0*ones( 2*n, 2*n );
   
   gm = circshift( g, [0 1] );
   gp = circshift( g, [0 -1] );
   ym = circshift( y, [0 1] );
   yp = circshift( y, [0 -1] );
   gm(1) = 0;
   gp(n) = 0;
   
   for i = 1:n
      A(1,1,i) = 64*(gm(i)^3 + g(i)^3);
      A(1,2,i) = 12*alpha*(gm(i)^2 - g(i)^2) * g(i);
      A(2,1,i) = A(1,2,i);
      A(2,2,i) = 3*alpha^2*(gm(i) + g(i))*g(i)^2;
      
      B(1,1,i) = -56*g(i)^3;
      B(1,2,i) = -8*alpha*g(i)^2*gp(i);
      B(2,1,i)= 8*alpha*g(i)^3;
      B(2,2,i) = alpha^2*g(i)^2*gp(i);
      
      k(1,i) = ( -120*g(i)^4*( yp(i) - y(i) ) - 120*gm(i)^4*( y(i) - ym(i) ) );
      k(2,i) = 20*alpha*g(i)^4 * ( yp(i) - y(i) ) - 20*alpha*gm(i)^3*g(i)*(y(i)-ym(i));
   end
   
   for i = 1:2:n
       M(i:i+1, i:i+1) = A(1:2,1:2,i);
   end
   for i = 1:2:n-1
       M(i:i+1,i+2:i+3) = -B(1:2,1:2,i);
       M(i+2:i+3,i:i+1) = -B(1:2,1:2,i)';
   end

   H(1:2,1:2,1) = inv(A(1:2,1:2,1)) * B(1:2,1:2,1);
   P(1:2,1) = inv(A(1:2,1:2,1)) * k(1:2,1);
   
   for i = 2:n
       z = inv(A(1:2,1:2,i) - B(1:2,1:2,i-1)'*H(1:2,1:2,i-1));
       H(1:2,1:2,i) = z * B(1:2,1:2,i);
       P(1:2,i) = z * (k(1:2,i) + B(1:2,1:2,i-1)' * P(1:2,i-1));
   end

   Z(1:2,n) = P(1:2,n);
   for i = n-1:-1:1
      Z(1:2,i) = P(1:2,i) + H(1:2,1:2,i) * Z(1:2,i+1);
   end

   yprime = y;
   ydoubleprime = y;
   
   for i = 1:n
      yprime(i) = Z(1,i) * -1;
      ydoubleprime(i) = Z(2,i) * alpha * g(i);
   end
   yprimep = circshift( yprime, [0 -1] );
   ydoubleprimep = circshift( ydoubleprime, [0 -1] );
   %yprimeapprox = ( y - ym ) ./ h;
   %ydoubleprimeapprox = ( yp + ym - 2*y ) ./ h.^2;

%    figure;
%    hold on;
%    plot( x, y, 'b-' );
%    plot( x, yprimeapprox, 'g-' );
%    plot( x, ydoubleprimeapprox, 'r-' );
%    legend( 'f', 'fp', 'fpp' );
%    title( 'functions' );
%    
%    figure;
%    hold on;
%    plot( x, y, 'b-' );
%    plot( x, 4.*cos(x./2), 'g-' );
%    plot( x, -2.*sin(x./2), 'r-' );
%    legend( 'f', 'fp', 'fpp' );
%    title( 'approxes' );
%    
%    figure;
%    hold on;
%    plot( x, y, 'b-' );
%    plot( x, yprime, 'g-' );
%    plot( x, ydoubleprime, 'r-' );
%    legend( 'f', 'fp', 'fpp' );
%    title( 'calculated' );
   
   
   eta = @(xq,xi,hi) ( xq - xi ) / hi;
   s0 = @(e) ( 1 - e )^3 * ( 1 + 3*e + 6*e^2 );
   s1 = @(e) e * ( 1 - e )^3 * ( 1 + 3*e );
   s2 = @(e) e^2 * ( 1 - e )^3 / 2;
   yq = xq;
   for i = 1:length(xq)
      xqi = xq(i);
      j = length( x( x <= xqi ) );
      e = eta( xqi, x(j), h(j) );
      d0 = y(j) * s0( e ) + yp(j) * s0( 1 - e );
      d1 = yprime(j) * s1(e) - yprimep(j) * s1( 1 - e );
      d2 = ydoubleprime(j) * s2(e) + ydoubleprimep(j) * s2( 1 - e );
      yq(i) = d0 + h(j) * d1 + h(j)^2 * d2;
   end
end