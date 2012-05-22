function op = opDirac(n)
% OPDIRAC  Identity operator
%
%    OPDIRAC(N) creates the identity operator for vectors of length
%    N. 

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opDirac.m 1027 2008-06-24 23:42:28Z ewout78 $

fun = @(x,mode) opDirac_intrnl(n,x,mode);
op  = classOp(fun);


function y = opDirac_intrnl(n,x,mode)
if (mode == 0)
   y = {n,n,[0,1,0,1],{'Dirac'}};
else
   y = x;
end

