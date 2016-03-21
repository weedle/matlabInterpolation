function [ cellStructs, structs ] = filterStructs( structs, threshold )
    fields = fieldnames(structs);
    
    % Sort by maxes
    [ cellStructs, ~ ] = sortStructs( structs, 4 );
    sz = size(cellStructs);
    display( sprintf( 'Currently have %d mutants', sz(3) ) );
    
    % Remove all mutants with higher maximum errors
    cellStructs = filterByIndex( cellStructs, 4, threshold*mode( [ cellStructs{4,:} ] ) );
    
    sz = size(cellStructs);
    display( sprintf( 'Filtered by max: now have %d mutants', sz(3) ) );
    
    % Remove mutants with higher residuals
    cellStructs = filterByIndex( cellStructs, 5, threshold*mode( [ cellStructs{5,:} ] ) );
    sz = size(cellStructs);
    display( sprintf( 'Filtered by residual: now have %d mutants', sz(3) ) );
    
    % Remove mutants with higher slopes
    cellStructs = filterByIndex( cellStructs, 2, threshold*mode( [ cellStructs{2,:} ] ) );
    sz = size(cellStructs);
    display( sprintf( 'Filtered by slope: now have %d mutants', sz(3) ) );
    
    structs = cell2struct(cellStructs, fields, 1);
end

function cellStructs = filterByIndex( cellStructs, index, threshold )
    cellStructs = removeInvalid( cellStructs, index, threshold );
end

function cellStructs = removeInvalid( cellStructs, index, threshold )
    slope = 0;
    if( index == 2 )
        slope = 1;
    end
    values = [ cellStructs{ index,: } ];
    cellStructs( :,:,isnan( values ) ) = [];
    if( slope )
        cellStructs( :,:,( [ cellStructs{ index,1:length( cellStructs ) } ] < threshold ) ) = []; 
    else
        cellStructs( :,:,( [ cellStructs{ index,1:length( cellStructs ) } ] > threshold ) ) = []; 
    end
end

function cellStructs = toCells( structs ) %#ok<DEFNU>
    cellStructs = struct2cell(structs);
    s = size(cellStructs);
    cellStructs = reshape(cellStructs, s(1), []);
    cellStructs = reshape(cellStructs, s);
end