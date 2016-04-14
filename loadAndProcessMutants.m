threshold = [ 1e8, 5, 1.2, 1.01 ];
splines = { 'Pchip'; 'Spline'; 'CubicSpline'; 'CubicComplete'; ...
            'Quintic'; 'PiecewiseLinear' };
fns = { 'Poly8', 'Sin1', 'Sin2', 'Bessel1', 'Airy1' };

for spl = 1:length(splines)
    for fn = 1:length(fns)
        load( sprintf( 'allMutants%s%s.mat', splines{spl}, fns{fn} ) );
        figure;
        display( sprintf( 'Now running on spline: %s for fn %s', splines{spl}, fns{fn} ) );
        for i = 1:length(threshold)
            [ ~, s ] = filterStructs( structs, threshold(i) );
            subplot( 2, 2, i )
            sortAndPlotStructs( splines{spl}, s, 2, threshold(i), fns{fn} )
        end
        suptitle( sprintf( 'Data for mutants of %s for function %s', splines{spl}, fns{fn} ) );
        savefig( sprintf( 'allMutants%s%s.fig', splines{spl}, fns{fn} ) );
        print( sprintf( 'allMutants%s%s.png', splines{spl}, fns{fn} ), '-dpng' );
        display( sprintf( 'Generated allMutants%s%s.fig\n', splines{spl}, fns{fn} ) );
        close all;
    end
end