function op = opSparsebin(m,n,d)
% OPSPARSEBIN  Random sparse binary matrix
%
%    OPSPARSEBIN(M,N) creates an M by N sparse binary matrix with
%    min(8,M) nonzeros in each column.
%
%    OPSPARSEBIN(M,N,D) is the same as above, except that each column
%    has min(D,M) nonzero elements.
%
%    This matrix was suggested by Radu Berinde and Piotr Indyk,
%    "Sparse recovery using sparse random matrices", MIT CSAIL TR
%    2008-001, January 2008, http://hdl.handle.net/1721.1/40089
%
%    Note that OPSPARSEBIN calls RANDPERM and thus changes the state
%    of RAND.
%
%    See also RAND, RANDPERM, SPARSE

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opSparsebin.m 1027 2008-06-24 23:42:28Z ewout78 $

if nargin < 3, d = 8; end;

% Don't allow more than m nonzeros per column (obviously).
d = min(d,m);

% Preallocate row pointers.
ia = zeros(d*n,1);
ja = zeros(d*n,1);
va =  ones(d*n,1);

for k = 1:n  % Loop over each column.
    
    % Generate random integers in [1,m].
    p = randperm(m);

    % Indices for start and end of the k-th column.
    colbeg = 1+(k-1)*d;
    colend = colbeg + d - 1;

    % Populate the row and column indices.
    ia(colbeg:colend) = p(1:d);
    ja(colbeg:colend) = k;
        
end

A  = sparse(ia,ja,va,m,n);
op = opMatrix(A,{'Sparsebin'});
