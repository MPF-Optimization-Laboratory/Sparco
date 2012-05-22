function op = opSum(varargin)
% OPSUM   Summate a sequence of operators into a single operator.
%
%    OPSUM(WEIGHTS,OP1,OP2,...OPn) creates an operator that
%    consists of the weighted sum of OP1, OP2, ..., OPn. An
%    alternative but equivalent way to call this function is
%    OPSUM(WEIGHTS,{OP1,OP2,...,OPn}). The WEIGHT parameter is
%    an optional N-vector.
%
%    See also opFoG, opDictionary, opStack.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opSum.m 1027 2008-06-24 23:42:28Z ewout78 $

opList = varargin;

if nargin == 0
   error('At least one operator must be specified');
else
   % Get number of operators and weights
   if (nargin > 1) && isnumeric(varargin{1})
     opList = varargin(2:nargin);
     w = varargin{1}; w = w(:);
   else
     opList = varargin;
     w = [];
   end
   if iscell(opList{1}), opList = opList{1}; end;
   if isempty(w), w = ones(length(opList),1); end;
   
   % Convert all arguments to operators
   opList = argToOperator(opList{:});
   
   % Check length of weights
   if (length(w) ~= length(opList))
      error('Weight vector must have same length as operator list');
   end
   
   % Check operator consistency and domain (real/complex) and
   % unwrap opSum operators
   opListNew = {};
   weightNew = [];
   for i=1:length(opList)
      info = opList{i}([],0);
      if i==1
         m = info{1};
         n = info{2};
         c = info{3};
      else
         c = c | info{3}; % Update complexity information
        
         % Generate error if operator sizes are incompatible
         if (info{1} ~= m) || (info{2} ~= n)
            error(['Operator ' int2str(i) ' is not consistent with the first operators']);
         end
      end
      
      % Add operator and weights to list
      info = info{4};
      if strcmp(info{1},'Sum')
         sumOperators = info{2};
         sumWeights   = info{3};
         for j=1:length(sumOperators)
            opListNew{end+1} = sumOperators{j};
            weightNew(end+1) = sumWeights(j) * w(i);
         end
      else
         opListNew{end+1} = opList{i};
         weightNew(end+1) = w(i);
      end
      
   end
   if any(~isreal(w)), c = ones(1,4); end;
end

fun = @(x,mode) opSum_intrnl(m,n,c,opListNew,weightNew,x,mode);
op  = classOp(fun);


function y = opSum_intrnl(m,n,c,opList,w,x,mode)
if mode == 0
   y = {m,n,c,{'Sum',opList,w}};
elseif mode == 1
   y = w(1) * opList{1}(x,mode);
   for i=2:length(opList)
     y = y + w(i)*opList{i}(x,mode);
   end
else
   y = conj(w(1)) * opList{1}(x,mode);
   for i=2:length(opList)
     y = y + conj(w(i))*opList{i}(x,mode);
   end
end
