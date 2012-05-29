function y = sparsify(x, level, op)
%SPARSIFY  Sparsify vector
%
%   SPARSIFY(X,LEVEL,OP) increases the sparsity in vector X by
%   keeping only the LEVEL largest coefficients. When LEVEL < 1
%   it is interpreted as the fraction of entries in X. Otherwise
%   LEVEL indicates the number of non-zeros to keep. When operator
%   OP is given X is first transformed to OP'*X and then
%   sparsified. The result is returned in the original domain by
%   applying OP on the intermediate result.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: sparsify.m 1027 2008-06-24 23:42:28Z ewout78 $

if nargin < 3, op = []; end;

% Store original size and vectorize x
s = size(x); x = x(:);

% Apply the adjoint operator on x
if ~isempty(op), x = op' * x; end

% Determine the threshold level
c = sort(abs(x),'descend');
if level < 1
  threshold = c(max(ceil(level * length(c)),length(c)));
else
  threshold = c(min(round(level),length(c)));
end

% Zero out all coefficients below threshold level
x(abs(x) < threshold) = 0;

% Apply operator on x
if ~isempty(op) x = op * x; end;

% Reshape the result to original size
y = reshape(x,s);
