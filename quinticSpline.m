function quinticSpline
   f = @(x) exp( 3*x ) .* sin( 200*x.^2 )
   x = linspace( 0, 1, 10 );
   y = f(x);
   xq = 0:1e-3:1;
   yq = quinticInterp( x, y, xq );
end

function yq = quinticInterp( x, y, xq )
   % yq = A + B(x-xq) + C(x-xq)^2 + D(x-xq)^3 + E(x-xq)^4 + F(x-xq)^5
   A = y';
   n = length(x);
   yL = circshift( y', -1)';
   yR = circshift( y', -1)';
   xL = circshift( x', -1)';
   xR = circshift( x', 1)';
   xL(n) = 0;
   yL(n) = 0;
   xR(1) = 0;
   yR(1) = 0;
   h = xL - x;
   h(n) = h(1);
   hR = circshift( h', 1)';
   hL = circshift( h', -1)';
   
   z(1) = 0;
   for i = 1:1:n-1
      z(2*i+1) = 5 * ( ( ( yL(i) - y(i) ) / h(i).^2 ) - ( ( y(i) - yR(i) ) / hR(i).^2 ) );
      z(2*i+2) = 15 * ( ( ( yL(i) - y(i) ) / h(i)^3 ) - ( ( y(i) - yR(i) ) / hR(i)^3 ) );
   end
   z(2*n-1) = 0;
   z = circshift( z', -1 )'
   z = z(2:length(z)-1);
   size(z);
   % x in form of ( C1 B1 C2 B2 ... )

   for i = 2:n-1
      M(2*i-1,i) = -1/(2*hR(i)); %C1
      M(2*i-1, i+1) = -2 / hR(i)^2; %B1
      M(2*i-1, i+2) = 3/2*( ( 1 / hR(i) ) + ( 1 / h(i) ) ); %C2
      M(2*i-1, i+3) = -3*( ( 1 / hR(i)^2 ) - ( 2 / h(i)^2 ) ); %B2
      M(2*i-1, i+4) = -1 / (2*h(i)); %C3
      M(2*i-1, i+5)= 2 / h(i)^2; %B3           
       
      M(2*i,i) = 2/hR(i)^2; %C1
      M(2*i,i+1) = 7 / hR(i)^3; %B1
      M(2*i,i+2) = -3*( ( 1 / hR(i)^2 ) - ( 1 / h(i)^2 ) ); %C2
      M(2*i,i+3) = 8*( ( 1 / hR(i)^3 ) + ( 1 / h(i)^3 ) ); %B2
      M(2*i,i+4) = -2 / h(i)^2; %C3
      M(2*i,i+5)= 7 / h(i)^3; %B3
   end

   BC = M \ z; %should give all Cn and Bn in form [ C2, B2, C3, B3 ... CN-1, BN-1 ]
   C = 0 * ones(1, length(z)+2 );
   B = 0 * ones(1, length(z)+2 );
   for i = 1:2:length(z)
      C(i+1) = BC(i);
      C(i+2) = BC(i+1);
   end
   
   yq = 0;
end