function x = randspvec(n,k)
%RANDSPVEC  Generate a random vector with k nonzero entries
%
%   RANDSPVEC(n,k) returns an n-vector with k normally distributed
%   random entries in random locations.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: randspvec.m 1026 2008-06-23 20:10:20Z ewout78 $

if nargin ~= 2
    error('Two input arguments required.')
end

x = zeros(n,1);
p = randperm(n);
x(p(1:k)) = randn(k,1);
