function [ cellStructs, structs ] = filterStructs( structs )
    fields = fieldnames(structs);
    
    cellStructs = toCells( structs );
    
    cellStructs = filterMaxes( cellStructs );

    cellStructs = filterMins( cellStructs );
    
    cellStructs = filterSlopes( cellStructs );
    
    structs = cell2struct(cellStructs, fields, 1);
end

function cellStructs = filterMaxes( cellStructs )
    cellStructs = removeInvalid( cellStructs, 3, 1 );
end

function cellStructs = filterMins( cellStructs )
    cellStructs = removeInvalid( cellStructs, 4, 1 );
end

function cellStructs = filterSlopes( cellStructs )
    cellStructs = removeInvalid( cellStructs, 2, -4 );
end

function cellStructs = removeInvalid( cellStructs, index, threshold )
    values = [ cellStructs{ index,: } ];
    cellStructs( :,:,isnan( values ) ) = [];
    cellStructs( :,:,( [ cellStructs{ index,1:length( cellStructs ) } ] > threshold ) ) = []; 
    
    %[ cellStructsMaxes{ 3,1:length( cellStructsMaxes ) } ] == Inf
    %cellStructsMaxes( 3,1:length(cellStructsMaxes) )
end

function cellStructs = sortByMaxes( structs )
    cellStructs = struct2cell(structs);
    s = size(cellStructs);
    
    % Convert to a matrix
    cellStructs = reshape(cellStructs, s(1), []);

    % cellStructs is: name, slope, mean error, max error, residual norm
    cellStructs = cellStructs';

    % sort by slope
    cellStructs = sortrows(cellStructs, 3);
    
    
    % Put back into original cell array format
    cellStructs = reshape(cellStructs', s);
end

function cellStructs = toCells( structs )
    cellStructs = struct2cell(structs);
    s = size(cellStructs);
    cellStructs = reshape(cellStructs, s(1), []);
    cellStructs = reshape(cellStructs, s);

    % Convert to Struct
    %structs = cell2struct(cellStructs, fields, 1);
    
    % get slopes
    %slopes = [cellStructs{2,:}];
    %maxes = [cellStructs{3,:}];
    
    %x = isnan( maxes );
    %x = x | ( maxes > 1 );
    % filter bad slopes;
    %structs( x ) = [];
end