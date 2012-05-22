function op = opMask(A)
% OPMASK  Selection mask
%
%    OPMASK(A) creates an operator that computes the dot-product of
%    a given vector with the (binary) mask provided by A. If A is a
%    matrix it will be vectorized prior to use.
%
%    See also opColRestrict, opRestriction.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opMask.m 1027 2008-06-24 23:42:28Z ewout78 $

fun = @(x,mode) opMask_intrnl(A,x,mode);
op  = classOp(fun);


function y = opMask_intrnl(A,x,mode)
if mode == 0
   m = size(A,1);
   n = size(A,2);
   c =~isreal(A);
   y = {m*n,m*n,[c,1,c,1],{'Mask'}};
else
   y = A(:) .* x;
end
