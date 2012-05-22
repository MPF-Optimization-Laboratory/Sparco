function op = opFoG(varargin)
% OPFOG   Concatenate a sequence of operators into a single operator.
%
%    OPFOG(OP1,OP2,...OPn) creates an operator that successively
%    applies each of the operators OP1, OP2, ..., OPn on a given
%    input vector. In non-adjoint mode this is done in reverse
%    order, starting with OPn.
%
%    See also opDictionary

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opFoG.m 1027 2008-06-24 23:42:28Z ewout78 $

% Convert all arguments to operators
opList = argToOperator(varargin{:});

if nargin == 0
   error('At least one operator must be specified');
else
    
   % Check operator consistency and space
   info = opList{1}([],0);
   m = info{1}; n = info{2}; cTr = info{3}(3:4);
   for i=2:length(opList)
      info = opList{i}([],0);
      if (info{1} ~= n)
         error(['Operator ' int2str(i) ' is not consistent with the previous operators']);
      end

      cTr= info{3}(3+cTr); % Evaluate where real and complex data get mapped to
      n  = info{2};
   end

   cFw = info{3}(1:2);
   for i=length(opList)-1:-1:1
      info = opList{i}([],0);
      cFw = info{3}(1+cFw);
   end

   c = [cFw, cTr];
   
   % Unpack all FoG operators
   opListNew = {};
   for i=1:length(opList)
      info = opList{i}([],0);
      info = info{4};
      if strcmp(info{1},'FoG')
         fogOperators = info{2};
         for j=1:length(fogOperators)
            opListNew{end+1} = fogOperators{j};
         end
      else
         opListNew{end+1} = opList{i};
      end
   end
end

fun = @(x,mode) opFoG_intrnl(m,n,c,opListNew,x,mode);
op  = classOp(fun);

function y = opFoG_intrnl(m,n,c,opList,x,mode)
if mode == 0
   y = {m,n,c,{'FoG',opList}};
elseif mode == 1
   y = opList{end}(x,mode);
   for i=length(opList)-1:-1:1
     y = opList{i}(y,mode);
   end
else
   y = opList{1}(x,mode);
   for i=2:length(opList)
     y = opList{i}(y,mode);
   end
end
