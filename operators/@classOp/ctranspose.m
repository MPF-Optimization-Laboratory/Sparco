function result = ctranspose(A)

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: ctranspose.m 1027 2008-06-24 23:42:28Z ewout78 $

A.adjoint = xor(A.adjoint,1);
result = A;

