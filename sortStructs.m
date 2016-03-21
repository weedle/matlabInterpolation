function [ cellStructs, structs ] = sortStructs( structs, index )
    fields = fieldnames(structs);
    cellStructs = struct2cell(structs);
    sz = size( cellStructs );
    %s = size(cellStructs);
    
    % Convert to a matrix
    cellStructs = reshape(cellStructs, 5, []);

    % cellStructs is: name, slope, mean error, max error, residual norm
    cellStructs = cellStructs';

    % sort by slope
    cellStructs = sortrows(cellStructs, index);
    
    
    % Put back into original cell array format
    cellStructs = reshape(cellStructs', sz );

    % Convert to Struct
    structs = cell2struct(cellStructs, fields, 1);

end