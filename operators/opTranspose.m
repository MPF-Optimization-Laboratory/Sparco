function op = opTranspose(opIn)
% OPTRANSPOSE   Transpose operator
%
%    OPTRANSPOSE(OP) creates an operator that is the the adjoint
%    operator OP.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opTranspose.m 1027 2008-06-24 23:42:28Z ewout78 $

opList = argToOperator(opIn);
opIn   = opList{1};

% Ensure that applying the transpose on a transpose of an operator
% returns that operator
info = opIn([],0); info = info{4};
if strcmp(info{1},'Transpose')
   fun = info{2};
else
   fun = @(x,mode) opTranspose_intrnl(opIn,x,mode);
end
op = classOp(fun);


function y = opTranspose_intrnl(op,x,mode)
if mode == 0
  info = op([],0);
  y = {info{2},info{1},info{3}([3,4,1,2]),{'Transpose',op}};
elseif mode == 1
  y = op(x,2);
else
  y = op(x,1);
end
