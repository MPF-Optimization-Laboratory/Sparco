function op = opSplitComplex(n)
% OPSPLITCOMPLEX  Complex to real and imaginary
%
%    OPSPLITCOMPLEX(N) creates a nonlinear operator that splits a
%    complex vector of length N into its real and imaginary parts
%    [real(x); imag(x)]. In transpose mode it combines the real and
%    imaginary parts into a complex vector.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opSplitComplex.m 1027 2008-06-24 23:42:28Z ewout78 $

fun = @(x,mode) opComplexSplit_intrnl(n,x,mode);
op  = classOp(fun);

function y = opComplexSplit_intrnl(n,x,mode)
if mode == 0
   y = {2*n,n,[0,0,1,1],{'SplitComplex'}};
elseif mode == 1
   y = [real(x); imag(x)];
else
   y = x(1:n) + sqrt(-1) * x(n+(1:n));
end
