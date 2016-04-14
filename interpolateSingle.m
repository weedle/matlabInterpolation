function returnStruct = interpolateConvergence( spline, fnIndex, plotFlag ) %#ok<*DEFNU>
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
   %set(0,'defaultfigureposition',[0 0 800 800]')
   params = { 'poly8'; 'sin1'; 'sin2'; 'bessel1'; 'airy1' };
   
   param = params{ fnIndex };
   if( plotFlag )
       fig = figure();
   else
       fig = 0;
   end
   
   returnStruct = runRoutines( spline, param, 0, fig );
end

function returnStruct = runRoutines( type, fn, randEnabled, fig )

   % Initialization
   range = 2.^(3:0.25:9);
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
   if( fig ~= 0 )
      returnStruct = plotErrorMain( range, errorMean, errorMax, fig, 1 );
   else
      returnStruct = plotErrorMain( range, errorMean, errorMax, fig, 0 );
   end
end

function returnStruct = plotErrorMain( range, errorMean, errorMax, fig, plotEnabled )
   % Plot error and retrieve fit of slope
   returnStruct = plotError( range, errorMean, errorMax, fig, plotEnabled );
   
   if( plotEnabled )
      hold on;
      % Plot thin lines for all data
      loglog( range, errorMax  );
   
      % Plot fixed slopes for visual comparison
      plotConstSlopes( fig, range );
   end
end

function returnStruct = plotError( range, errorMean, errorMax, fig, plotEnabled )
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
   errRange = errStart:errLength;
   if( length( errRange ) < 12 )
      errStart = errStart - ( 12 - length( errRange ) ); 
   end
   errRange = errStart:errLength;
   
   [fit, S] = polyfit( log(range( errRange ) ), log( errorMax( errRange ) ), 1 );
   i = 3;
   while S.normr > 0.8 && length(errRange) > 12
       errorMaxTrunc = errorMaxTrunc( errorMaxTrunc < 10^-(i) );
       errorMaxTrunc( errorMaxTrunc == 0 ) = [];
       errorMeanTrunc( errorMaxTrunc == 0 ) = [];
       errStart = errLength - length( errorMaxTrunc );
       errRange = errStart:errLength;
       [fit, S] = polyfit( log(range( errRange ) ), log( errorMax( errRange ) ), 1 );
       i = i+1;
   end
   
   if( plotEnabled )
      figure(fig);
      p = loglog( range( errRange ), errorMax( errRange ), 'b.-' );
      set( p, 'LineWidth', 2 );
      set( p, 'MarkerSize', 10 );
      xlabel( 'Discretization' );
      ylabel( 'Error' );
      title( 'loglog of error at various discretizations' );
   end

   returnStruct.slope = fit(1);
   returnStruct.maxErr = errorMax( errLength );
   returnStruct.meanErr = errorMean( errLength );
   returnStruct.residNorm = S.normr;
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

% Functions to test
function y = sinTest( x )
   y = x .* sin( x * 8 );
end

function y = sin1( x )
   y = x .* sin( x * 8 );
end

function y = sin2( x )
   y = ( 1 - x ).^3 .* cos( ( x - 0.4 ) * 12 );
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

function y = bessel1( x )
   y = besselj( 3, x*10 );
end

function y = airy1( x )
   y = airy( x*10-5 );
end

function y = tanNormal( x )
   y = tan( x );
end