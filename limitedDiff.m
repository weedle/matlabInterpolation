function limitedDiff( spline ) %#ok<*DEFNU>
% INTERPOLATECONVERGENCE: Tests various convergent algorithms
% interpolateConvergence( mode ) runs tests using various interpolation
% methods, and displays convergence plots and error histograms
% So far, the algorithms tested are:
% *************************************************************************
% UPDATE IF ADDING NEW ALGORITHM TO TEST PLAN
% piecewiseLinear - A piecewise linear interpolation
% spline - The native matlab cubic spline
% pchip - The matlab piecewise cubic hermite spline
% cubicSpline - A complete cubic spline
% quintic - A quintic spline
% *************************************************************************
   
% Set random number generator to default
   rng('default')
   
   fig = figure;
   subplot( 1, 2, 1 );
   fns = getFnsPoly;
   for f = 1:5
       runRoutines( spline, fns{f}, 0, fig );
   end
   title( 'Polynomial functions' );
   
   subplot( 1, 2, 2 );
   fns = getFnsSin;
   for f = 1:5
       runRoutines( spline, fns{f}, 0, fig );
   end
   title( 'Trigonometric functions' );
   
   suptitle( sprintf( 'Convergence rate of %s with underlying functions of varying differentiability', spline ) );
   print( sprintf( 'varyingDiff%s.png', spline ), '-dpng' );
end

function runRoutines( type, fn, randEnabled, fig )

   % Initialization
   range = 2.^(3:0.25:9);
   %range = 2.^(3:0.5:16);
   xVals = getDomain( range, randEnabled );
   % xq is the set of query points
   xq = linspace( 0.1, 0.9, 1e2 );
   yqCorrect = fn( xq );
   errorMean = ones( 1, length(range) );
   errorMax = errorMean;
   
   
      errIndex = 1;
      for r = 1:length(range)     
         x = xVals( r, 1:floor(range(r)) );
         y = fn( x );
         
         [ errorMean( 1, errIndex ), errorMax( 1, errIndex ), ~, ~ ] = ...
             interpolate( x, y, type, xq, yqCorrect );
         errIndex = errIndex + 1;
      end
   
   %subplot( 2, 1, 1 )
   %plotErrorMain( range, errorMean, fig, 1 )
   %subplot( 2, 1, 2 )
   plotErrorMain( range, errorMean, errorMax, fig );

end

function plotErrorMain( range, errorMean, errorMax, fig )
   % Plot error and retrieve fit of slope
   plotError( range, errorMean, errorMax, fig );
   
   hold on;
   % Plot thin lines for all data
   loglog( range, errorMax  );
   
   % Plot fixed slopes for visual comparison
   plotConstSlopes( fig, range );
end

function returnStruct = plotError( range, errorMean, errorMax, fig )
   errorMeanTrunc = errorMean;
   errorMaxTrunc = errorMax( errorMax > 10e-14 );
   errorMaxTrunc( errorMaxTrunc == 0 ) = [];
   errorMeanTrunc( errorMaxTrunc == 0 ) = [];
   errorMeanTrunc( errorMaxTrunc == 0 ) = [];
   errLength = length( errorMaxTrunc );
   errorMaxTrunc = errorMaxTrunc( errorMaxTrunc < 10e-3 );
   errorMaxTrunc( errorMaxTrunc == 0 ) = [];
   errorMeanTrunc( errorMaxTrunc == 0 ) = [];
   errStart = errLength - length( errorMaxTrunc );
   errStart = max( errStart, 1 );
   errRange = errStart:errLength;
   if( length( errRange ) < 12 )
      errStart = errStart - ( 12 - length( errRange ) ); 
   end
   errRange = errStart:errLength;
   
   figure(fig);
   p = loglog( range( errRange ), errorMax( errRange ), 'b.-' );
   set( p, 'LineWidth', 2 );
   set( p, 'MarkerSize', 10 );
   xlabel( 'Discretization' );
   ylabel( 'Error' );
end

function plotConstSlopes( fig, range )
   figure(fig);
   
   loglog( range, range.^-1, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -1
   loglog( range, range.^-2, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -2
   loglog( range, range.^-3, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -3
   loglog( range, range.^-4, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -4
end

function xVals = getDomain( range, randEnabled )
   xVals = 0 * ones( length( range ),  range( length( range ) ) );
   separationFactor = 4;
   for r = 1:length(range)
      f = floor( range(r) );
      xVals( r, 1:floor(range(r)) ) = -cos( ( 2.*(1:f) - 1 ) ./ ( 2*f ) * pi )/2+0.5;
   end
   
   for r = 1:length(range)
      separation = xVals( r, 2 ) - xVals( r, 1 );
      xVals( r, 2:floor(range(r))-1 ) = ...
          xVals( r, 2:floor(range(r))-1 ) + ...
          randEnabled * separation * rand( 1, floor(range(r))-2 ) / separationFactor - ...
          randEnabled * separation / ( 2 * separationFactor );
   end
end

function [ diffMean, diffMax, yq, yqDiff ] = interpolate( x, y, interp, xq, yqCorrect )
   
   yq = feval( interp, x, y, xq );
   
   %figure;
   %hold on;
   %plot( x, y, 'r-' );
   %plot( xq, yq, 'b-' );
   % We're currently using the average and maximum error to represent the
   % accuracy of an interpolation technique
   yqDiff = yq - yqCorrect;
   
   diffMean = mean( abs( yqDiff ) );
   diffMax = max( abs( yqDiff ) );

end

function fns = getFnsPoly
   mid = 0.438;
   syms x
   a1(x) = 3 .* x + 8;
   b1(x) = -2 .* x +3;
   a2(x) = int( a1(x), 0, x );
   b2(x) = int( b1(x), mid, x ) + a2(mid);
   a3(x) = int( a2(x), 0, x );
   b3(x) = int( b2(x), mid, x ) + a3(mid);
   a4(x) = int( a3(x), 0, x );
   b4(x) = int( b3(x), mid, x ) + a4(mid);
   a5(x) = int( a4(x), 0, x );
   b5(x) = int( b4(x), mid, x ) + a5(mid);
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
   f1 = @(x) ( x <= mid ) .* aFn1(x) + ( x > mid ) .* bFn1(x);
   f2 = @(x) ( x <= mid ) .* aFn2(x) + ( x > mid ) .* bFn2(x);
   f3 = @(x) ( x <= mid ) .* aFn3(x) + ( x > mid ) .* bFn3(x);
   f4 = @(x) ( x <= mid ) .* aFn4(x) + ( x > mid ) .* bFn4(x);
   f5 = @(x) ( x <= mid ) .* aFn5(x) + ( x > mid ) .* bFn5(x);
   fns = { f1, f2, f3, f4, f5 };
end

function fns = getFnsSin
   mid = 0.5;
   syms x
   c1(x) = 3 .* sin(20.*x) + 8;
   d1(x) = 2 .* cos(30.*x) + 2;
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
   g1 = @(x) ( x <= mid ) .* cFn1(x) + ( x > mid ) .* dFn1(x);
   g2 = @(x) ( x <= mid ) .* cFn2(x) + ( x > mid ) .* dFn2(x);
   g3 = @(x) ( x <= mid ) .* cFn3(x) + ( x > mid ) .* dFn3(x);
   g4 = @(x) ( x <= mid ) .* cFn4(x) + ( x > mid ) .* dFn4(x);
   g5 = @(x) ( x <= mid ) .* cFn5(x) + ( x > mid ) .* dFn5(x);
   fns = { g1, g2, g3, g4, g5 };
end