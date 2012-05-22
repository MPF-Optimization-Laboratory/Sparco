function op = opDCT(n)
% OPDCT  One-dimensional discrete cosine transform (DCT)
%
%    OPDCT(N) creates a one-dimensional discrete cosine transform
%    operator for vectors of length N.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opDCT.m 1027 2008-06-24 23:42:28Z ewout78 $

fun = @(x,mode) opDCT_intrnl(n,x,mode);
op  = classOp(fun);

function y = opDCT_intrnl(n,x,mode)
if mode == 0
   y = {n,n,[0,1,0,1],{'DCT'}};
elseif mode == 1
   y = idct(x);
else
   y = dct(x);
end
