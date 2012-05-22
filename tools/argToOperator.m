function ops = argToOperator(varargin)

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: argToOperator.m 1027 2008-06-24 23:42:28Z ewout78 $

ops = {};

for i=1:length(varargin)
   m = varargin{i};
   
   
   if isa(m,'classOp')
      % Get operator handle or matrix
      m = getHandle(m);
   end

   if isnumeric(m)
       % Convert matrix to operator
       m = opMatrix(m);
       m = getHandle(m);
   end

   ops{i} = m;
end
