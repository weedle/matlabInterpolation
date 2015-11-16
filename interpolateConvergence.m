function interpolateConvergence( fn ) %#ok<*DEFNU>
% INTERPOLATECONVERGENCE: Tests various convergent algorithms
% interpolateConvergence( fn ) runs the specified function fn through
% various interpolation methods, and plots the convergence rates of each
% algorithm.
% So far, the algorithms tested are:
% *************************************************************************
% UPDATE IF ADDING NEW ALGORITHM TO TEST PLAN
% piecewiseLinear - A piecewise linear interpolation
% spline - The native matlab cubic spline
% pchip - The matlab piecewise cubic hermite spline
% cubicSpline - A natural cubic spline
% *************************************************************************
   global fnCur;
   fnCur = str2func( fn );
   global wantRand;
   global wantHist;
   wantHist = 1;
   wantRand = 1;
   
   if( strcmp( fn, 'derivs' ) == 0 )
      figure();
      runRoutines( fnCur );
   else
      mid = 0.5;
      syms x a0(x) b0(x) a1(x) b1(x) a2(x) b2(x) a3(x) b3(x)
      a1(x) = 3 .* sin(20.*x) + 8;
      b1(x) = 2 .* cos(30.*x) +2;
      a0(x) = diff( a1(x) );
      b0(x) = diff( b1(x) );
      a2(x) = int( a1(x), 0, x );
      b2(x) = int( b1(x), mid, x ) + a2(mid);
      a3(x) = int( a2(x), 0, x );
      b3(x) = int( b2(x), mid, x ) + a3(mid);
      a4(x) = int( a3(x), 0, x );
      b4(x) = int( b3(x), mid, x ) + a4(mid);
      a5(x) = int( a4(x), 0, x );
      b5(x) = int( b4(x), mid, x ) + a5(mid);
      aFn0 = matlabFunction( a0(x) ); % base case (spline requires
      bFn0 = matlabFunction( b0(x) ); % derivative
      aFn1 = matlabFunction( a1(x) ); % Piecewise function with no valid
      bFn1 = matlabFunction( b1(x) ); % first derivative
      aFn2 = matlabFunction( a2(x) ); % integral of above, no second
      bFn2 = matlabFunction( b2(x) ); % derivative
      aFn3 = matlabFunction( a3(x) ); % no third derivative
      bFn3 = matlabFunction( b3(x) ); 
      aFn4 = matlabFunction( a4(x) ); % no fourth derivative
      bFn4 = matlabFunction( b4(x) );
      aFn5 = matlabFunction( a5(x) );
      bFn5 = matlabFunction( b5(x) );
      f0 = @(x) ( x <= mid ) .* aFn0(x) + ( x > mid ) .* bFn0(x);
      f1 = @(x) ( x <= mid ) .* aFn1(x) + ( x > mid ) .* bFn1(x);
      f2 = @(x) ( x <= mid ) .* aFn2(x) + ( x > mid ) .* bFn2(x);
      f3 = @(x) ( x <= mid ) .* aFn3(x) + ( x > mid ) .* bFn3(x);
      f4 = @(x) ( x <= mid ) .* aFn4(x) + ( x > mid ) .* bFn4(x);
      f5 = @(x) ( x <= mid ) .* aFn5(x) + ( x > mid ) .* bFn5(x);

      
      c1(x) = 3 .* sin(20.*x) + 8;
      d1(x) = 2 .* cos(30.*x) +2;
      c2(x) = int( c1(x), 0, x );
      d2(x) = int( d1(x), mid, x ) + c2(mid);
      c3(x) = int( c2(x), 0, x );
      d3(x) = int( d2(x), mid, x ) + c3(mid);
      c4(x) = int( c3(x), 0, x );
      d4(x) = int( d3(x), mid, x ) + c4(mid);
      c5(x) = int( c4(x), 0, x );
      d5(x) = int( d4(x), mid, x ) + c5(mid);
      cFn1 = matlabFunction( c1(x) ); % Piecewise function with no valid
      dFn1 = matlabFunction( d1(x) ); % first derivative
      cFn2 = matlabFunction( c2(x) ); % integral of above, no second
      dFn2 = matlabFunction( d2(x) ); % derivative
      cFn3 = matlabFunction( c3(x) ); % no third derivative
      dFn3 = matlabFunction( d3(x) ); 
      cFn4 = matlabFunction( c4(x) ); % no fourth derivative
      dFn4 = matlabFunction( d4(x) );
      cFn5 = matlabFunction( c5(x) );
      dFn5 = matlabFunction( d5(x) );
%       g0 = @(x) ( x <= mid ) .* cFn0(x) + ( x > mid ) .* dFn0(x);
      g1 = @(x) ( x <= mid ) .* cFn1(x) + ( x > mid ) .* dFn1(x);
      g2 = @(x) ( x <= mid ) .* cFn2(x) + ( x > mid ) .* dFn2(x);
      g3 = @(x) ( x <= mid ) .* cFn3(x) + ( x > mid ) .* dFn3(x);
      g4 = @(x) ( x <= mid ) .* cFn4(x) + ( x > mid ) .* dFn4(x);
      g5 = @(x) ( x <= mid ) .* cFn5(x) + ( x > mid ) .* dFn5(x);
      x = 0:0.01:1;
      
      fns = { f1, f2, f3, f4, f5 };
      %fns = { g1, g2, g3, g4, g5 };
      
      wantRand = 0;    
      for i = 1:length(fns);
         fnCur = fns{i};
         %figure();
         %plot( x, feval( fnCur, x ), 'r.-' );
         %title( func2str( fnCur ) );
         figure();
         runRoutines( fnCur );
      end
      
      wantRand = 1;
      for i = 1:length(fns);
         fnCur = fns{i};
         figure();
         runRoutines( fnCur );
      end
   end
end

function runRoutines( fn )
   range = 2.^(3:0.5:16);
   errorMean = ones( 1, length(range) );
   errorMax = errorMean;
   % xq is the set of query points
   xq = 0.1:0.01:1;
   yqCorrect = fn( xq );
   histErr = [];
   % ADD NEW INTERPOLATIONS TO TEST PLAN HERE
   types = { 'piecewiseLinear', 'spline', 'cubicSpline', 'pchip' };
   slopesMean = ones( 1, 4 );
   slopesMax = slopesMean;
   plotTypes = { 'r.-', 'm.-', 'b.-', 'g.-', 'c.-', 'k.-' };
   for t = 1:length(types)
      errIndex = 1;
      for r = range
         yqDiff = interpolate( r, fn, types{t}, xq, yqCorrect );
         errorMean( errIndex ) = mean( abs( yqDiff ) );
         errorMax( errIndex ) = max( abs( yqDiff ) );
         errIndex = errIndex + 1;
      end

      for j = 1:40
         yqDiff = interpolate( range( 10 ), fn, types{t}, xq, yqCorrect );
         histErr = [ histErr yqDiff ];
      end
      
      subplot( 2, 1, 1 )
      hold on;
      errorMeanTrunc = errorMean( errorMean > 10e-16 );
      errorMeanTrunc( errorMeanTrunc == 0 ) = [];
      errLength = length( errorMeanTrunc );
      p = plot( range( 1:errLength ), errorMeanTrunc, plotTypes{t} );
      set( gca, 'xscale', 'log', 'yscale', 'log' )
      set( p, 'LineWidth', 2 );
      set( p, 'MarkerSize', 10 );
      fit = polyfit( log(range( 1:errLength ) ), log(errorMeanTrunc), 1 );
      slopesMean(t) = fit(1);
      
      subplot( 2, 1, 2 )
      hold on;
      errorMaxTrunc = errorMax( errorMax > 10e-16 );
      errorMaxTrunc( errorMaxTrunc == 0 ) = [];
      errLength = length( errorMaxTrunc );
      p = plot( range( 1:errLength ), errorMaxTrunc, plotTypes{t} );
      set( gca, 'xscale', 'log', 'yscale', 'log' )
      set( p, 'LineWidth', 2 );
      set( p, 'MarkerSize', 10 );
      fit = polyfit( log(range( 1:errLength ) ), log(errorMaxTrunc), 1 );
      slopesMax(t) = fit(1);
      %y = exp( fit(1) * log(range) + fit(2) );
      %loglog( range, y );
      hold on;
   end

   s1 = subplot( 2, 1, 1 );
   hold on;
   title( sprintf( 'Mean of error for fn: %s', func2str( fn ) ) );
   xlabel( 'Discretization' );
   ylabel( 'Error norm' );
   legend( sprintf( 'piecewiseLinear: %d', slopesMean(1) ), ...
           sprintf( 'spline: %d', slopesMean(2) ), ...
           sprintf( 'cubicSpline: %d', slopesMean(3) ), ...
           sprintf( 'pchip: %d', slopesMean(4) ), ...
           'Location', 'southwest' );
   loglog( range, range.^-1, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -1
   loglog( range, range.^-2, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -2
   loglog( range, range.^-3, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -3
   loglog( range, range.^-4, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -4
   
   s2 = subplot( 2, 1, 2 );
   hold on;
   title( sprintf( 'Max of error for fn: %s', func2str( fn ) ) );
   xlabel( 'Discretization' );
   ylabel( 'Error norm' );
   legend( sprintf( 'piecewiseLinear: %d', slopesMax(1) ), ...
           sprintf( 'spline: %d', slopesMax(2) ), ...
           sprintf( 'cubicSpline: %d', slopesMax(3) ), ...
           sprintf( 'pchip: %d', slopesMax(4) ), ...
           'Location', 'southwest' );
   loglog( range, range.^-1, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -1
   loglog( range, range.^-2, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -2
   loglog( range, range.^-3, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -3
   loglog( range, range.^-4, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -4
   
   linkaxes( [ s1, s2 ], 'x' );
   
   figure;
   hist( histErr, 50 );
   title( sprintf( 'Histogram of error for fn: %s', func2str( fn ) ) );
end

function yqDiff = interpolate( r, fn, interp, xq, yqCorrect )
   global wantRand;
   x = linspace( 0, 1, r );
   d = wantRand * ( x(2) - x(1) ) / 2;
   x(2:length(x)-1) = x(2:length(x)-1) + d*rand( 1, length( x ) - 2 ) - d/2;
   y = fn( x );
   
   % The Call function for each interpolation allows us to call all
   % interpolations through a common format, while allowing for extra
   % parameters to be included when needed
   yq = feval( sprintf( '%sCall', interp ), x, y, xq );
      
   % We're currently using the average and maximum error to represent the
   % accuracy of an interpolation technique
   yqDiff = yq - yqCorrect;

end

% Call methods for the interpolations in the test plan
function yq = P1LagrangeCall( x, y, xq )
   yq = feval( 'P1Lagrange', x, y, xq );
end

function yq = piecewiseLinearCall( x, y, xq )
   yq = feval( 'piecewiseLinear', x, y, xq );
end

function yq = splineCall( x, y, xq )
   yq = feval( 'spline', x, y, xq );
end

function yq = pchipCall( x, y, xq )
   yq = feval( 'pchip', x, y, xq );
end

function yq = cubicSplineCall( x, y, xq )
   fpo = ( y(2) - y(1) ) / ( x(2) - x(1) );
   fpn = ( y(length(y)) - y(length(y)-1) ) / ( x(length(x)) - x(length(x)-1) );
   yq = feval( 'cubicComplete', x, y, xq, fpo, fpn );
end

% Functions to test
function y = sinTest( x )
   y = x .* sin( x / 8 );
end