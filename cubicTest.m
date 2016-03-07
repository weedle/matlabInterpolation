function cubicTest %#ok<*DEFNU>
% Set random number generator to default
   rng('default')
   set(0,'defaultfigureposition',[0 0 800 800]')
   global deg;
   deg = 12;
   
   % ADD NEW INTERPOLATIONS TO TEST PLAN HERE
   types = { 'spline', 'cubicSpline', 'quintic' };
   %fns = getFns;
   %F = { 'f5', 'polynomial deg 8', 'sin(x)', 'complicated sin' };
   %f = { fns{5}, @poly8, @sinNormal, @sinTest };
   %F = { '5', '5b', '6', '6b', '7', '7b', '8', '8b', ...
   %      'sin1', 'sin2', 'sin3', 'sin4' };
   %f = { @poly5, @poly5b, @poly6, @poly6b, @poly7, @poly7b, @poly8, @poly8b, ...
   %      @sinTest, @sinTest2, @sinTest3, @sinTest4 };
   %for i = 1:8
   %   fig = figure();
   %   runRoutines( types, F{i}, f{i}, 0, fig );
   %end
   
   fig = figure();
   runRoutines( types, sprintf( 'deg: %d', deg ), @polyX, 0, fig );
   
   x = 0:0.01:5;
   y = polyX( x );
   xq = 0.1:0.001:5;
   
   figure;
   plot( x, y, 'r-' );
   hold on;
   plot( xq, cubicSpline( x, y, xq ), 'b-' );
   legend( 'actual', 'spline' );
   title( 'Function' );
   figure;
   plot( xq, cubicSpline( x, y, xq ) - polyX( xq ), 'g-' );
   title( 'error' );
   %fig = figure();
   %runRoutines( types, F, f, 1, fig );
end

function runRoutines( types, mode, fn, randEnabled, fig )

   % Initialization
   range = 2.^(3:0.05:11);
   %range = 2.^(3:0.5:16);
   xVals = getDomain( range, randEnabled );
   % xq is the set of query points
   xq = linspace( 0.1, 0.9, 1e2 );
   yqCorrect = fn( xq );
   errorMean = ones( length(types), length(range) );
   errorMax = errorMean;
   
   
   for t = 1:length(types)
      errIndex = 1;
      for r = 1:length(range)     
         x = xVals( r, 1:floor(range(r)) );
         y = fn( x );
         
         [ errorMean( t, errIndex ), errorMax( t, errIndex ), ~, ~ ] = ...
             interpolate( x, y, types{t}, xq, yqCorrect );
         errIndex = errIndex + 1;
      end
   end   
   
   plotTypes = { 'r.-', 'm.-', 'b.-', 'g.-', 'c.-', 'k.-' };
   subplot( 2, 1, 1 )
   plotErrorMain( range, types, mode, errorMean, plotTypes, fig, randEnabled, 'Mean' )
   subplot( 2, 1, 2 )
   plotErrorMain( range, types, mode, errorMax, plotTypes, fig, randEnabled, 'Max' )
end

function plotErrorMain( range, types, mode, errorM, plotTypes, fig, randEnabled, meanOrMax )
   slopesM = ones( 1, length(types) );
   % Plot thicker lines for data used in fit
   for t = 1:length(types)
      % Plot error and retrieve fit of slope
      slopesM(t) = plotError( range, errorM( t,: ), ...
                                 plotTypes{t}, fig );
      hold on;
   end
   
   % Apply legends, labels, and title
   plotLabels( fig, types, mode, randEnabled, slopesM, meanOrMax );
   
   % Plot thin lines for all data
   for t = 1:length(types)
      loglog( range, errorM( t,: ), plotTypes{t} );
   end
   
   % Plot fixed slopes for visual comparison
   plotConstSlopes( fig, range );
end

function fit = plotError( range, errorRow, plotType, fig )
   figure(fig);
      errorMeanTrunc = errorRow( errorRow > 10e-15 );
      errorMeanTrunc( errorMeanTrunc == 0 ) = [];
      errLength = length( errorMeanTrunc );
      p = loglog( range(1:errLength), errorRow( 1:errLength ), plotType );
      set( p, 'LineWidth', 2 );
      set( p, 'MarkerSize', 10 );
      fit = polyfit( log(range( 1:errLength ) ), log( errorRow(1:errLength) ), 1 );
      fit = fit(1);
end

function plotLabels( fig, types, mode, randEnabled, slopesM, meanOrMax )
   figure(fig);
   for t = 1:length(types)
      types{t} = sprintf( '%s: %1.2f.', types{t}, slopesM(t) );
   end
   legend( types, 'Location', 'southwest' );
   randMsg = '';
   if( randEnabled == 1 )
      randMsg = ' with random perturbation';
   end
      title( sprintf( '%s of error%s for fn: %s', meanOrMax, randMsg, mode ) );
   xlabel( 'Discretization' );
   ylabel( 'Error norm' );
end

function plotHistLabels( fig, type, range, mode, randEnabled )
   figure(fig);
   randMsg = '';
   if( randEnabled == 1 )
      randMsg = ' with random perturbation';
   end
   title( sprintf( 'Using routine: %s and discretization: %4.0d%s for fn: %s', ...
      type, range, randMsg, mode ) ); 
   xlabel( 'Difference between interpolated value and true value' );
   ylabel( 'Number of samples' );
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
       f = floor(range(r));
      xVals( r, 1:floor(range(r)) ) = -cos( ( 2.*(1:f) - 1 ) ./ ( 2*f ) * pi )/2+0.5;
      %xVals( r, 1:floor(range(r)) ) = linspace( 0, 1, range(r) );
   end
   
   for r = 1:length(range)
      separation = xVals( r, 2 ) - xVals( r, 1 );
      xVals( r, 2:floor(range(r))-1 ) = ...
          xVals( r, 2:floor(range(r))-1 ) + ...
          randEnabled * separation * rand( 1, floor(range(r))-2 ) / separationFactor - ...
          randEnabled * separation / ( 2 * separationFactor );
   end
end

function  fns = getFns
   mid = 0.43;
   syms x
   a1(x) = 3 .* sin(20.*x) + 8;
   b1(x) = 2 .* cos(43.*x) + 2;
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

function  fns = getFnsPoly
   mid = 0.5;
   syms x
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
   g1 = @(x) ( x <= mid ) .* cFn1(x) + ( x > mid ) .* dFn1(x);
   g2 = @(x) ( x <= mid ) .* cFn2(x) + ( x > mid ) .* dFn2(x);
   g3 = @(x) ( x <= mid ) .* cFn3(x) + ( x > mid ) .* dFn3(x);
   g4 = @(x) ( x <= mid ) .* cFn4(x) + ( x > mid ) .* dFn4(x);
   g5 = @(x) ( x <= mid ) .* cFn5(x) + ( x > mid ) .* dFn5(x);
   fns = { g1, g2, g3, g4, g5 };
end

function [ diffMean, diffMax, yq, yqDiff ] = interpolate( x, y, interp, xq, yqCorrect )
   
   % The Call function for each interpolation allows us to call all
   % interpolations through a common format, while allowing for extra
   % parameters to be included when needed
   yq = feval( sprintf( '%sCall', interp ), x, y, xq );
      
   % We're currently using the average and maximum error to represent the
   % accuracy of an interpolation technique
   yqDiff = yq - yqCorrect;
   
   diffMean = mean( abs( yqDiff ) );
   diffMax = max( abs( yqDiff ) );

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

function yq = quinticCall( x, y, xq )
   yq = feval( 'quintic', x, y, xq );
end

% Functions to test
function y = sinTest( x )
   y = x .* sin( x / 8 );
end


function y = sinTest2( x )
   y = x.^2 .* sin( x / 18 );
end


function y = sinTest3( x )
   y = x .* sin( x / 6 ).^2;
end


function y = sinTest4( x )
   y = sin( x / 8 ) .* cos( x / 13 );
end

function y = sinNormal( x )
   y = sin( x );
end

function y = poly1( x )
   y = x.^2 + 3.*x;
end

function y = poly2( x )
   y = -x.^4 + 5.*x.^3 - 7.*x + 10;
end

function y = npoly2( x )
   y = -( -x.^4 + 5.*x.^3 - 7.*x + 10 );
end

function y = poly8( x )
   y = x.^8 + 3.*x.^7 - 33.*x.^5 + 20.*x.^3 - 15.*x.^2 + 15.*x + 64;
end

function y = poly8b( x )
   y = -4.*x.^8 + 17.*x.^6 + 45.*x.^4 - 3.*x.^3 - x + 13;
end

function y = poly7( x )
   y = -3.*x.^7 + 5.*x.^6 - 15.*x.^3 + 23.*x.^2 + 43.*x;
end

function y = poly7b( x )
   y = x.^7 + 8.*x.^4 - 3.*x.^5 + 75.*x.^4 - 17.*x.^2 - 7.*x + 12;
end

function y = poly6( x )
   y = -3.*x.^6 + 5.*x.^5 - 15.*x.^3 + 23.*x.^2 + 43.*x;
end

function y = poly6b( x )
   y = x.^6 + 8.*x.^4 - 3.*x.^3 + 75.*x.^2 - 7.*x + 12;
end

function y = poly5( x )
   y = -3.*x.^5 + 5.*x.^4 - 15.*x.^3 + 23.*x.^2 + 43.*x;
end

function y = poly5b( x )
   y = x.^5 + 8.*x.^4 - 3.*x.^3 + 75.*x.^2 - 7.*x + 12;
end

function y = polyX( x )
   global deg;
   y = x.^deg;
end

function y = tanNormal( x )
   y = tan( x );
end