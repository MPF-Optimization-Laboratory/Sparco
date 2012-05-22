function op = opHaar2d(m,n,levels)
%OPHAAR2D   Two-dimensional Haar wavelet
%
%   OPHAAR2D(M,N) creates a Haar wavelet operator for two dimensional
%   signals of size M-by-N.
%
%   OPHAAR2D(M,N,LEVELS) is the same as above, but LEVELS indicates
%   the number of scales to use; the default is 5.
%
%   See also opHaar, opWavelet

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opHaar2d.m 1390 2009-05-30 16:27:47Z mpf $

if (nargin < 3), levels = 5; end
if levels <= 0 || rem(levels,1)
   error('No. of levels must be positive integer')
end

op = opWavelet(m,n,'haar',0, levels,'min');
