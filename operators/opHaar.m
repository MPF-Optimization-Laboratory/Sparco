function op = opHaar(n,levels)
%OPHAAR   One-dimensional Haar wavelet
%
%   OPHAAR(N) creates a Haar wavelet operator for 1-D signals of
%   length N, using 5 levels. N must be divisible by 2^5.
%
%   OPHAAR(N,LEVELS) optionally allows the number of LEVELS to be
%   specified. N must be divisible by 2^LEVELS.
%
%   See also opHaar2D, opWavelet

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opHaar.m 1390 2009-05-30 16:27:47Z mpf $

if nargin < 2, levels = 5; end
if levels <= 0 || rem(levels,1)
   error('No. of levels must be positive integer')
end

% n must be a multiple of 2^(levels)
if rem(n,2^levels)
   error('N must be a multiple of 2^(%i)',levels)
end

op = opWavelet(n,1,'haar',0, levels,'min');
