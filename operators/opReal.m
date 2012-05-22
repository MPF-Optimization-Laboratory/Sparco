function op = opReal(n)
% OPREAL  Discard imaginary components
%
%    OPREAL(N) creates an operator that discards the imaginary
%    components of input vectors of length N.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opReal.m 1027 2008-06-24 23:42:28Z ewout78 $

fun = @(x,mode) opReal_intrnl(n,x,mode);
op  = classOp(fun);


function y = opReal_intrnl(n,x,mode)
if (mode == 0)
   y = {n,n,[0,0,0,0],{'Real'}};
else
   y = real(x);
end

