function X = full(S)
%FULL  Convert a Sparco operator into a (dense) matrix.
%
%   X = FULL(S) converts the Sparco operator T into a dense matrix X.
%
%   See also opToMatrix

%   Sparco Toolbox
%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco

% $Id: full.m 1390 2009-05-30 16:27:47Z mpf $

X = opToMatrix(S);
