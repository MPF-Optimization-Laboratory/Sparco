function y = mrdivide(A,B)

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: mrdivide.m 1027 2008-06-24 23:42:28Z ewout78 $

% This function works only when A is the classOp and B is a scalar

if ~isa(A,'classOp') || ~isscalar(B)
    msg = ['''mrdivide'' is implemented only for operator ' ...
           'divisions by a scalar'];
    error(msg);
end

y = opScalar(A,1/B);
