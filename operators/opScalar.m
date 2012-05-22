function op = opScalar(opIn, scalar)
% OPSCALAR   Multiplication of operator by scalar
%
%    OPSCALAR(OP,SCALAR) creates an operator that is the SCALAR
%    multiple of operator OP.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opScalar.m 1027 2008-06-24 23:42:28Z ewout78 $

opList = argToOperator(opIn);
opIn   = opList{1};

% Ensure that applying this operator on another scalar operator
% constructs an operator that scales the underlying operator by the
% product of the two scalars. Directly return the underlying
% operator if the resulting scalar equals one.
info = opIn([],0); info = info{4};
if strcmp(info{1},'Scalar')
   opIn   = info{2};
   scalar = info{3} * scalar;
end

if scalar == 1
    fun = opIn;
else
   fun = @(x,mode) opScalar_intrnl(opIn,scalar,x,mode);
end
op = classOp(fun);


function y = opScalar_intrnl(op,scalar,x,mode)
if mode == 0
  info = op([],0);
  y = {info{1},info{2},info{3}([3,4,1,2]),{'Scalar',op,scalar}};
else
  y = scalar * op(x,mode);
end
