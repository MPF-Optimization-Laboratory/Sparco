function op = opOnes(m,n)
% OPONES   Operator equivalent to ones function.
%
%    OPONES(M,N) creates an operator corresponding to an M by N
%    matrix of ones. If parameter N is omitted it is set to M.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opOnes.m 1027 2008-06-24 23:42:28Z ewout78 $

if nargin < 2
  n = m;
end

fun = @(x,mode) opOnes_intrnl(m,n,x,mode);
op  = classOp(fun);


function y = opOnes_intrnl(m,n,x,mode)
if (mode == 0)
   y = {m,n,[0,1,0,1],{'Ones'}};
elseif (mode == 1)
   y = ones(m,1)*sum(x);
else
   y = ones(n,1)*sum(x);
end
