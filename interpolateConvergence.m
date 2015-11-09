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
% cubicSpline - A natural cubic spline
% cubicClamped - A clamped cubic, uses the derivative of the specified
% function
% The function needs to have a corresponding fnDir function in the scope
% eg, if calling interpolateConvergence( 'sinTest' )
% cubicClamped will use endpoint values from the function 'sinTestDir'
% *************************************************************************
   % fnCur is a global variable so that interpolations that require a
   % function derivative can systematically generate the appropriate
   % function handle
   % eg, for the function 'sinTest', we generate a handle 'sinTestDir'
   global fnCur;
   fnCur = str2func( fn );

   
   if( strcmp( fn, 'derivs' ) == 0 )
      figure();
      runRoutines( fnCur );
   else
      mid = pi/2;
      syms x a0(x) b0(x) a1(x) b1(x) a2(x) b2(x) a3(x) b3(x)
      a1(x) = 3 .* sin(x);
      b1(x) = 10 .* cos(x) + 10;
      a0(x) = diff( a1(x) );
      b0(x) = diff( b1(x) );
      a2(x) = int( a1(x), 0, x );
      b2(x) = int( b1(x), mid, x ) + a1(mid);
      a3(x) = int( a2(x), 0, x );
      b3(x) = int( b2(x), mid, x ) + a2(mid);
      a4(x) = int( a3(x), 0, x );
      b4(x) = int( b3(x), mid, x ) + a3(mid);
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
      f0 = @(x) ( x <= mid ) .* aFn0(x) + ( x > mid ) .* bFn0(x);
      f1 = @(x) ( x <= mid ) .* aFn1(x) + ( x > mid ) .* bFn1(x);
      f2 = @(x) ( x <= mid ) .* aFn2(x) + ( x > mid ) .* bFn2(x);
      f3 = @(x) ( x <= mid ) .* aFn3(x) + ( x > mid ) .* bFn3(x);
      f4 = @(x) ( x <= mid ) .* aFn4(x) + ( x > mid ) .* bFn4(x);
      %x = 0:0.1:5;
      
      fns = { f1, f2, f3, f4 };
      for i = 1:length(fns);
         figure();
         %plot( x, feval( fnCur, x ), 'r.-' );
         %title( fnCur );
         fnCur = fns{i};
         runRoutines( fnCur );
      end
   end
end

function runRoutines( fn )
   range = 2.^(3:0.5:16);
   error1 = ones( 1, length(range) );
   error2 = error1;
   % xq is the set of query points
   xq = 0.1:0.01:1;
   % ADD NEW INTERPOLATIONS TO TEST PLAN HERE
   types = { 'piecewiseLinear', 'spline', 'cubicSpline', 'pchip' };
   slopes1 = ones( 1, 4 );
   slopes2 = slopes1;
   plotTypes = { 'r.-', 'm.-', 'b.-', 'g.-', 'c.-', 'k.-' };
   for i = 1:length(types)
      index = 1;
      for r = range
         x = linspace( 0, 1, r );
         fn(3)
         y = fn( x );
      
         % The Call function for each interpolation allows us to call all
         % interpolations through a common format, while allowing for extra
         % parameters to be included when needed
         % eg: the cubicClampedCall function adds in the extra derivative
         % endpoint values to the call to cubicClamped
         yq = feval( sprintf( '%sCall', types{i} ), x, y, xq );
      
         % We're currently using the average error to represent the
         % accuracy of an interpolation technique
         error1( index ) = mean( abs( yq - fn( xq ) ) );
         error2( index ) = max( abs( yq - fn( xq ) ) );
         index = index + 1;
      end
      subplot( 2, 1, 1 )
      hold on;
      p = plot( range, error1, plotTypes{i} );
      set( gca, 'xscale', 'log', 'yscale', 'log' )
      set( p, 'LineWidth', 2 );
      set( p, 'MarkerSize', 10 );
      fit = polyfit( log(range), log(error1), 1 );
      slopes1(i) = fit(1);
      
      subplot( 2, 1, 2 )
      hold on;
      p = plot( range, error2, plotTypes{i} );
      set( gca, 'xscale', 'log', 'yscale', 'log' )
      set( p, 'LineWidth', 2 );
      set( p, 'MarkerSize', 10 );
      fit = polyfit( log(range), log(error2), 1 );
      slopes2(i) = fit(1);
      %y = exp( fit(1) * log(range) + fit(2) );
      %loglog( range, y );
      hold on;
   end

   s1 = subplot( 2, 1, 1 );
   hold on;
   title( sprintf( 'Mean of error for fn: %s', func2str( fn ) ) );
   xlabel( 'Discretization' );
   ylabel( 'Error norm' );
   legend( sprintf( 'piecewiseLinear: %d', slopes1(1) ), ...
           sprintf( 'spline: %d', slopes1(2) ), ...
           sprintf( 'cubicSpline: %d', slopes1(3) ), ...
           sprintf( 'pchip: %d', slopes1(4) ) );
   loglog( range, range.^-1, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -1
   loglog( range, range.^-2, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -2
   loglog( range, range.^-3, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -3
   loglog( range, range.^-4, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -4
   
   s2 = subplot( 2, 1, 2 );
   hold on;
   title( sprintf( 'Max of error for fn: %s', func2str( fn ) ) );
   xlabel( 'Discretization' );
   ylabel( 'Error norm' );
   legend( sprintf( 'piecewiseLinear: %d', slopes2(1) ), ...
           sprintf( 'spline: %d', slopes2(2) ), ...
           sprintf( 'cubicSpline: %d', slopes2(3) ), ...
           sprintf( 'pchip: %d', slopes2(4) ) );
   loglog( range, range.^-1, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -1
   loglog( range, range.^-2, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -2
   loglog( range, range.^-3, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -3
   loglog( range, range.^-4, '-', 'Color', [ 0.75 0.75 0.75 ] ); %slope -4
   
   linkaxes( [ s1, s2 ], 'x' );
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
   yq = feval( 'cubicSpline', x, y, xq );
end

function yq = cubicClampedCall( x, y, xq )
   global fnCur;
   fnDir = sprintf( '%sDir', func2str( fnCur ) );
   yq = feval( 'cubicClamped', x, y, xq, feval( fnDir, xq(1) ), feval( fnDir, xq( length( xq ) ) ) );
end


% Functions to test
function y = sinTest( x )
   y = x .* sin( x / 8 );
end

function y = sinTestDir( x )
   y = sin( x / 8 ) + x / 8 .* cos( x / 8 );
end

% Systematic generation for functions with limited continuity
%function y = f0( x )
%   mid = pi/2;
%   a0 = @(x) 3.*cos(x);
%   b0 = @(x) -10.*sin(x);
%   f0 = @(x) ( x <= mid ) .* a0(x) + ( x > mid ) .* b0(x);
%   y = f0(x);
%end

%function y = f1( x )
%   mid = pi/2;
%   a1 = @(x) 3.*sin(x);
%   b1 = @(x) 10.*cos(x) + 10;
%   f1 = @(x) ( x <= mid ) .* a1(x) + ( x > mid ) .* b1(x);
%   y = f1(x);
%end

%function y = f1Dir( x )
%   y = f0(x);
%end

%function y = f2( x )
%   mid = pi/2;
%   a2 = @(x) 3 - 3.*cos(x);
%   b2 = @(x) 10.*x - 5*pi + 10.*sin(x) - 7;
%   f2 = @(x) ( x <= mid ) .* a2(x) + ( x > mid ) .* b2(x);
%   y = f2(x);
%end

%function y = f2Dir( x )
%   y = f1(x);
%end

%function y = f3( x )
%   mid = pi/2;
%   a3 = @(x) 3.*x - 3.*sin(x);
%   b3 = @(x) (7*pi)/2 - 7.*x - 10.*cos(x) - 5.*pi.*x + (5*pi^2)/4 + 5.*x.^2 + 3;
%   f3 = @(x) ( x <= mid ) .* a3(x) + ( x > mid ) .* b3(x);
%   y = f3(x);
%end

%function y = f3Dir( x )
%   y = f2(x);
%end

%function y = f4( x )
%   mid = pi/2;
%   a4 = @(x) 3.*cos(x) + (3.*x.^2)./2 - 3;
%   b4 = @(x) 3.*x - 10.*sin(x) + (7.*pi.*x)./2 - (5.*pi.*x.^2)./2 + (5.*pi.^2.*x)./4 - (7*pi^2)/8 - (5*pi^3)/24 - (7.*x.^2)./2 + (5.*x.^3)./3 + 7
%   f4 = @(x) ( x <= mid ) .* a4(x) + ( x > mid ) .* b4(x);
%   y = f4(x);
%end

%function y = f4Dir( x )
%   y = f3(x);
%end