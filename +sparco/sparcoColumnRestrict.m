function op = sparcoColumnRestrict(m,n,idx,type)
% SPARCOCOLUMNRESTRICT   Restriction operator on matrix columns
%
%    SPARCOCOLUMNRESTRICT(M,N,IDX,TYPE), with TYPE = 'DISCARD',
%    creates an operator that extracts the columns indicated by
%    IDX from a given M by N matrix. The adjoint operator takes
%    an M by length(IDX) matrix and outputs an M by N matrix with
%    the columns filled by the given input matrix. Note that all
%    input and output matrices are in vectorized from. When
%    TYPE = 'ZERO', all columns that are not in IDX are
%    zero-padded instead of discarded.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: sparcoColumnRestrict.m 1485 2009-09-09 03:41:37Z ewout78 $

if (min(idx) < 1) || (max(idx) > n)
   error('Index parameter must be integer and match dimensions of the data');
end

if (nargin < 4) || isempty(type)
  type = 'discard';
end

if strcmp(lower(type),'discard')
   l   = length(idx);
   fun = @(x,mode) opColumnRestrict_intrnl1(idx,l,m,n,x,mode);
else
   l = n;
   invidx = ones(n,1);
   invidx(idx) = 0;
   idx = find(invidx);
   fun = @(x,mode) opColumnRestrict_intrnl2(idx,m,n,x,mode);
end

op = opFunction(m*l,m*n,fun);


function y = opColumnRestrict_intrnl1(idx,l,m,n,x,mode)
if mode == 1
   y = reshape(x,m,n);
   y = reshape(y(:,idx),m*l,1);
else
   y = zeros(m,n);
   y(:,idx) = reshape(x,m,l);
   y = reshape(y,m*n,1);
end

function y = opColumnRestrict_intrnl2(invidx,m,n,x,mode)
y = reshape(x,m,n);
y(:,invidx) = 0;
y = y(:);

