function h = getHandle(A)

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: getHandle.m 1027 2008-06-24 23:42:28Z ewout78 $

h = A.op;

if A.adjoint
    h = getHandle(opTranspose(h));
end
