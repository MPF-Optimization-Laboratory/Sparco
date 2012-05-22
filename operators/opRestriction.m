function op = opRestriction(n,idx)
% OPRESTRICTION Restriction operator
%
%    OPRESTRICTION(N,IDX) creates a restriction operator that selects
%    the entries listed in the index vector IDX from an input vector
%    of length N. The adjoint of the operator creates a zero vector of
%    length N and fills the entries given by IDX with the input data.
%
%    Algebraically, OPRESTRICTION(N,IDX) is equivalent to a matrix of
%    size length(IDX)-by-N, where row i has a single 1 in column
%    IDX(i).
%
%    See also opColumnRestriction, opMask.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opRestriction.m 1027 2008-06-24 23:42:28Z ewout78 $

if min(idx) < 1  ||  max(idx) > n
   error('One or more of the indices are out of range.');
end

fun = @(x,mode) opRestriction_intrnl(n,idx,x,mode);
op  = classOp(fun);

function y = opRestriction_intrnl(n,idx,x,mode)
if mode == 0
   m = length(idx);
   y = {m,n,[0,1,0,1],{'Restriction'}};
elseif mode == 1
   y = x(idx);
else
   y = zeros(n,1);
   y(idx) = x;
end
