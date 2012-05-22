function A = uminus(A)

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: uminus.m 1027 2008-06-24 23:42:28Z ewout78 $

% Note that A.op is used directly regardless of whether A is in
% adjoint mode. This is ok because the adjoint flag is left
% unaltered and opScalar is symmetric.
A.op = getHandle(opScalar(A.op,-1));
