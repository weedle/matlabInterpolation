function sortAndPlotStructs( interp, structs, index, threshold, fn )
   [ c, ~ ] = sortStructs( structs, index );
   
   plot( [ c{2,:} ], 'r.-' );
   hold on;
   plot( [ c{4,:} ], 'b.-' );
   plot( [ c{5,:} ], 'g.-' );
   
   title( sprintf( 'threshold = %g', threshold ) );
   
   xlabel( 'Mutant' );
   ylabel( 'Value' );
   
   legend( 'Slope', 'Max Err.', 'Residual' );
end