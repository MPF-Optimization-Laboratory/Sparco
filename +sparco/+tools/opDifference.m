function op = opDifference(size)
%OPDIFFERENCE  Generation of difference function
%
%   OPDIFFERENCE(SIZE) returns the handle of a difference function
%   that takes the arguments X and MODE. When MODE is 1 the vector
%   X is reshaped to SIZE and the difference is taken in the ROW
%   and COLUMN direction and output in an matrix with two
%   columns. When SIZE is a scalar, only the difference along the
%   COLUMNS is taken and a single column vector is returned.
%   When MODE is 2 the reverse operation is done, except that the
%   offset is lost.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opDifference.m 1027 2008-06-24 23:42:28Z ewout78 $

if length(size) == 1
   m = size(1);
   n = 1;
   l = 1;
   fun = @(x,mode) opDifference_intrnl1(size(1),x,mode);
elseif length(size) == 2
   m = size(1);
   n = size(2);
   l = 2;
   fun = @(x,mode) opDifference_intrnl2(size(1),size(2),x,mode);
else
  error('Higher dimensional difference operator not supported yet');
end

op = opFunction(l*n*m,n*m,fun);

function y = opDifference_intrnl1(m,x,mode)
if (mode == 1)
   y       = x([2:m,m]) - x;
else
   y       =  x([1,1:m-1]) - x;
   y(1)    = -x(1);
   y(m)    =  x(m-1);
end

function y = opDifference_intrnl2(m,n,x,mode)
if (mode == 1)
   z       = reshape(x,m,n);
   zx      = z([2:m,m],:) - z;
   zy      = z(:,[2:n,n]) - z;
   y       = [zx(:), zy(:)];
   y       = reshape (y,2*m*n,1);
else
   z       = reshape(x,m*n,2); 
   xr      = reshape(z(:,1),m,n);
   zx      =  xr([1,1:m-1],:) - xr;
   zx(1,:) = -xr(1,:);
   zx(m,:) =  xr(m-1,:);
   
   xr      = reshape(z(:,2),m,n);
   zy      =  xr(:,[1,1:n-1]) - xr;
   zy(:,1) = -xr(:,1);
   zy(:,n) =  xr(:,n-1);
   
   y       = reshape(zx + zy, m*n, 1);
end
