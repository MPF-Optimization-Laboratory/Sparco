function op = opFFT(n)
% OPFFT  One-dimensional fast Fourier transform (FFT).
%
%    OPFFT(N) create a one-dimensional normalized Fourier transform
%    operator for vectors of length N.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opFFT.m 1027 2008-06-24 23:42:28Z ewout78 $

fun = @(x,mode) opFFT_intrnl(n,x,mode);
op  = classOp(fun);


function y = opFFT_intrnl(n,x,mode)
if mode == 0
   y = {n,n,[1,1,1,1],{'FFT'}};
elseif mode == 1
   y = fft(x) / sqrt(length(x));
else
   y = ifft(x) * sqrt(length(x));
end
