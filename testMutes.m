function structs = testMutes( spline )
% TESTMUTES: This code will test the mutations created by matmute
% testMutes takes a spline, and navigates to the file containing all
% mutations created by running matmute. It then runs interpolateSingle on
% each mutant, and filters out all failed mutants (files that fail to run
% at all)

% save current directory to navigate back to later
   currPath = pwd;

% formulate string that should be the directory name holding our mutants
   mutesPath = sprintf( '%s%s', spline, '_mutes' );

% turn into proper directory path
   x = strsplit( pwd, '\' );
   x = strjoin( x( 1:length( x ) ), '/' );
   
   cd( x );
   cd( mutesPath );
   
% files contains all the mutants we're considering
   files = ls;

   s = size(files);
   f = s(1);
   
% For testing, just run on a small subset of mutants
   %f = 100;
   
   structs = struct( 'name', cell( 1, f-2 ), 'slope', nan, 'max', nan, 'mean', nan, 'resid', nan );
 
% For each mutant, we attempt to run interpolateSingle on it
% If this fails, we set the slope to a dummy variable (we expect something
% like -6, or -4, so anything that naturally returns 100 is clearly a bad
% mutant already)

   for i = 3:f
       j = i-2;
       x = files(i,1:length(files(i,:)));
       x = strtok( x, '.' );
       fileNames{ j } = x;
       try
           yq = feval( x, 1:10, sin(1:10), 2:0.01:5 );
           r = interpolateSingle( x );
           structs( j ).name = x;
           structs( j ).slope = r.slope;
           structs( j ).max = r.maxErr;
           structs( j ).mean = r.meanErr;
           structs( j ).resid = r.residNorm;
       catch
           structs( j ).name = x;
       end
   end

   for i = j:-1:1
       if( isnan( structs( i ).slope ) )
           structs( i ) = [];
       end
   end
% Since we can have thousands of mutants, we filter out the failed ones
% here, and only return the ones that ran sucessfully

% Return to previous path, so we have no net effect on current path
   cd( currPath );
   
   
    %fields = fieldnames(structs);
    %cellStructs = struct2cell(structs);
    %s = size(cellStructs);
    
    % Convert to a matrix
    %cellStructs = reshape(cellStructs, s(1), []);

    % cellStructs is: name, slope, mean error, max error, residual norm
    %cellStructs = cellStructs';

    % sort by slope
    %cellStructs = sortrows(cellStructs, 2);
    
    
    % Put back into original cell array format
    %cellStructs = reshape(cellStructs', s);

    % Convert to Struct
    %structs = cell2struct(cellStructs, fields, 1);
    
    %length(structs)
    % get slopes
    %slopes = [cellStructs{2,:}];
    % filter bad slopes;
    %structs( slopes < -8.5 ) = [];
    

end