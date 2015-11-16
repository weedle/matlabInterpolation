This repository contains the files (mostly Matlab scripts) for my undergrad 449 thesis.
So far, this consists of a main function, interpolateConvergence, that runs a given function
through a set of interpolation routines, and outputs a set of convergence plots and histograms.
Passing the 'derivs' argument runs it through a number of piecewise functions with varying
levels of continuity. This allows us to see the effects on convergence when supplied with 
functions that do not meet the required criteria for their level of performance.
Eg: we can see how cubic splines react when applied to functions without a third derivative.
Later, this will also contain files relating to mutation testing.
The histograms show the grouping of error given randomly perturbed points, and the convergence 
plots have subplots for mean and maximum error.