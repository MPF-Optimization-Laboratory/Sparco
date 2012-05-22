function y = minus(A,B)

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: minus.m 1027 2008-06-24 23:42:28Z ewout78 $

% If this function gets called then either A or B is guaranteed to
% be a classOp. The call to opSum will take care of the situation
% when A or B is a matrix.

if isscalar(A)
   [m,n] = size(B);
   A = opScalar(opOnes(m,n),A);
end

if isscalar(B)
   [m,n] = size(A);
   B = opScalar(opOnes(m,n),B);
end

y = opSum([1,-1],A,B);
