function sortAndPlotStructs( structs, index )
   [ c, ~ ] = sortStructs( structs, index );
   
   plot( [ c{2,:} ], 'r.-' );
   hold on;
   plot( [ c{4,:} ], 'b.-' );
   plot( [ c{5,:} ], 'g.-' );
   
   title( 'Slopes, maximum error, and residual for mutants' );
   
   xlabel( 'Mutant' );
   ylabel( 'Value' );
   
   legend( 'Slope', 'Max Err.', 'Residual' );
end