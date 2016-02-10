function interpolateConvergence( spline ) %#ok<*DEFNU>
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
   set(0,'defaultfigureposition',[0 0 800 800]')
   
   param = 'poly8';
   fig = figure();
   runRoutines( spline, param, 0, fig );
end

function runRoutines( type, fn, randEnabled, fig )

   % Initialization
   range = 2.^(3:0.5:13);
   %range = 2.^(3:0.5:16);
   xVals = getDomain( range, randEnabled );
   % xq is the set of query points
   xq = linspace( 0.1, 0.9, 1e2 );
   yqCorrect = feval( fn, xq );
   errorMean = ones( 1, length(range) );
   errorMax = errorMean;
   
   
      errIndex = 1;
      for r = 1:length(range)     
         x = xVals( r, 1:floor(range(r)) );
         y = feval( fn, x );
         
         [ errorMean( 1, errIndex ), errorMax( 1, errIndex ), ~, ~ ] = ...
             interpolate( x, y, type, xq, yqCorrect );
         errIndex = errIndex + 1;
      end
   
   %subplot( 2, 1, 1 )
   %plotErrorMain( range, errorMean, fig, 1 )
   %subplot( 2, 1, 2 )
   plotErrorMain( range, errorMax, fig, 1 )
end

function slope = plotErrorMain( range, errorM, fig, plotEnabled )
   % Plot error and retrieve fit of slope
   slope = plotError( range, errorM, fig, plotEnabled );
   
   if( plotEnabled )
      hold on;
      % Plot thin lines for all data
      loglog( range, errorM  );
   
      % Plot fixed slopes for visual comparison
      plotConstSlopes( fig, range );
   end
end

function fit = plotError( range, errorRow, fig, plotEnabled )
   errorMeanTrunc = errorRow( errorRow > 10e-15 );
   errorMeanTrunc( errorMeanTrunc == 0 ) = [];
   errLength = length( errorMeanTrunc );
   if( plotEnabled )
      figure(fig);
      p = loglog( range(1:errLength), errorRow( 1:errLength ), 'b-' );
      set( p, 'LineWidth', 2 );
      set( p, 'MarkerSize', 10 );
   end
   fit = polyfit( log(range( 1:errLength ) ), log( errorRow( 1:errLength ) ), 1 );
   fit = fit(1);
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
      xVals( r, 1:floor(range(r)) ) = linspace( 0, 1, range(r) );
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
   
   % The Call function for each interpolation allows us to call all
   % interpolations through a common format, while allowing for extra
   % parameters to be included when needed
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

% Functions to test
function y = sinTest( x )
   y = x .* sin( x / 8 );
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
   y = x.^8 - 35.*x.^7 + 14.*x.^5 - 105.*x.^3 + 5.*x.^2 + 75.*x + 31;
end

function y = tanNormal( x )
   y = tan( x );
end