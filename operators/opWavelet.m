function op = opWavelet(m, n, family, filter, levels, type)
% OPWAVELET  Wavelet operator
%
%    OPWAVELET(M,N) creates a Daubuchies wavelet operator for M-by-N
%    matrices.  The transform is computed using the Rice Wavelet
%    Toolbox.
%
%    OPWAVELET(M,N,FAMILY,FILTER,LEVELS,TYPE) specifies the optional
%    parameters:
%    FAMILY  is either 'daubechies' (default) or 'haar'
%    FILTER  must be even and specifies the filter length (default 8)
%    LEVELS  gives the number of levels in the transformation (default 5).
%            Both M and N must be divisible by 2^LEVELS.
%    TYPE    is either 'min' for minimum phase (default),
%            'max' for maximum phase, or 'mid' for mid-phase solutions.

%   Copyright 2008, Rayan Saab, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opWavelet.m 1390 2009-05-30 16:27:47Z mpf $

if nargin < 3, family = 'Daubechies'; end
if nargin < 4, filter =     8;        end
if nargin < 5, type   = 'min';        end
if nargin < 6, levels =     5;        end

family = lower(family);

switch family
 case {'daubechies'}
    h = daubcqf(filter);
    
 case {'haar'}
    h = daubcqf(0);
    
 otherwise
    error('Wavelet family %s is unknown', family);
end

fun = @(x,mode) opWavelet_intrnl(m,n,family,filter,levels,type,h,x,mode);
op  = classOp(fun);


function y = opWavelet_intrnl(m,n,family,filter,levels,type,h,x,mode)
if mode == 0
   y = {n*m,n*m,[0,1,0,1],{'Wavelet',family,filter,levels,type}};
elseif mode == 1
   if isreal(x)
     [y,l] = midwt(reshape(x,[m,n]), h, levels);
   else
     [y1,l] = midwt(reshape(real(x),[m,n]), h, levels);
     [y2,l] = midwt(reshape(imag(x),[m,n]), h, levels);
     y = y1 + sqrt(-1) * y2;    
   end
   y = reshape(y,[m*n,1]);
else
   if isreal(x)
      [y,l] = mdwt(reshape(x,[m,n]), h, levels);
   else
      [y1,l] = mdwt(reshape(real(x),[m,n]), h, levels);
      [y2,l] = mdwt(reshape(imag(x),[m,n]), h, levels);
     y = y1 + sqrt(-1) * y2;    
   end   
   y = reshape(y,[m*n,1]);
end
