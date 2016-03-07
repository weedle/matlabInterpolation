function [fileNames, slopes] = testMutes( spline )
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
   
   slopes = 0*ones( 1, f-2 );
 
% For each mutant, we attempt to run interpolateSingle on it
% If this fails, we set the slope to a dummy variable (we expect something
% like -6, or -4, so anything that naturally returns 100 is clearly a bad
% mutant already)
   for i = 3:f
       x = files(i,1:length(files(i,:)));
       x = strtok( x, '.' );
       fileNames{ i-2 } = x;
       try
           yq = feval( x, 1:10, sin(1:10), 2:0.01:5 );
           slopes( i-2 ) = interpolateSingle( x );
       catch
           slopes( i-2 ) = 100;
       end
   end
   
% Since we can have thousands of mutants, we filter out the failed ones
% here, and only return the ones that ran sucessfully
   fileNames( slopes == 100 ) = [];
   slopes( slopes == 100 ) = [];

% Return to previous path, so we have no net effect on current path
   cd( currPath );
end