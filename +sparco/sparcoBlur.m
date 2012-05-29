function op = sparcoBlur(m,n)
%SPARCOBLUR   Two-dimensional blurring operator
%
%   SPARCOBLUR(M,N) creates an blurring operator for M by N
%   images. This function is used for the GPSR-based test problems
%   and is based on the implementation by Figueiredo, Nowak and
%   Wright, 2007.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opBlur.m 1027 2008-06-24 23:42:28Z ewout78 $

% Construct blurring kernel
kernel = zeros(9,9);
for i=-4:4  
   kernel(i+5,(-4:4)+5)= (1./(1+i*i+(-4:4).^2));
end
kernel = kernel / sum(kernel(:));

% Create operator
op = opConvolve(n,m,kernel,[5,5],'cyclic');

