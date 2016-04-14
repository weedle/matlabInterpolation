warning( 'off', 'MATLAB:polyfit:PolyNotUnique' );
warning( 'off', 'MATLAB:colon:nonIntegerIndex' );
warning( 'off', 'MATLAB:nearlySingularMatrix' );
warning( 'off', 'MATLAB:singularMatrix' );


names = { 'Poly8', 'Sin1', 'Sin2', 'Bessel1', 'Airy1' };
mySplines = { 'quintic', 'cubicSpline', 'cubicComplete', 'piecewiseLinear' };
MySplines = { 'Quintic', 'CubicSpline', 'CubicComplete', 'PiecewiseLinear' };

matSplines = { 'pchip', 'spline' };
MatSplines = { 'Pchip', 'Spline' };
for i = 4:5
    for j = 1:length(matSplines)
        cd 'C:\Users\Kevin\Documents\MATLAB\nativeFunctions';
        [ cellStructs, structs ] = testMutes( matSplines{j}, i );
        cd 'C:\Users\Kevin\Documents\MATLAB\';
        save( sprintf( 'allMutants%s%s.mat', MatSplines{j}, names{i} ), 'structs', 'cellStructs' );
        display( sprintf( 'Generated allMutants%s%s.mat\n', MatSplines{j}, names{i} ) );
    end
    for j = 1:length(mySplines)
        cd 'C:\Users\Kevin\Documents\MATLAB\';
        [ cellStructs, structs ] = testMutes( mySplines{j}, i );
        cd 'C:\Users\Kevin\Documents\MATLAB\';
        save( sprintf( 'allMutants%s%s.mat', MySplines{j}, names{i} ), 'structs', 'cellStructs' );
        display( sprintf( 'Generated allMutants%s%s.mat\n', MySplines{j}, names{i} ) );
    end
end

cd 'C:\Users\Kevin\Documents\MATLAB\';
