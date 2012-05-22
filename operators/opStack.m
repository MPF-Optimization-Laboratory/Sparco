function op = opStack(varargin)
% OPSTACK  Stack of vertically concatenated operators
%
%    OPSTACK(WEIGHTS, OP1, OP2, ...) creates a stacked operator
%    consisting of the vertical concatenation of all operators;
%
%                [WEIGHT1*OP1
%                 WEIGHT2*OP2
%                    ...
%                 WEIGHTn*OPn]
%
%    The WEIGHT parameter is optional and can either be a scalar
%    or a vector. In case of a scalar, all operators are weighted
%    equally.
%
%    See also opFoG, opBLockDiag, opDictionary.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opStack.m 1485 2009-09-09 03:41:37Z ewout78 $

if nargin > 0 && isnumeric(varargin{1})
  weight = varargin{1};
  opList = varargin(2:end);
else
  weight = 1;
  opList = varargin;
end

% Convert all arguments to operators
opList = argToOperator(opList{:});

if length(opList) == 0
   error('At least one operator must be specified');
else
   % Check operator consistency and space
   info = opList{1}([],0);
   m = info{1}; n = info{2}; c = info{3};
   for i=2:length(opList)
      info = opList{i}([],0);
      if (info{2} ~= n)
         error(['Operator ' int2str(i) ' is not consistent with the previous operators']);
      end

      m = m + info{1};            % Total size
      c = c | info{3};            % Complex or real operator
   end
   if any(~isreal(weight)), c = ones(1,4); end;
   
   % Check weight vector
   weight = weight(:);
   if (~isscalar(weight)) && (length(weight) ~= length(opList))
     error(['Length of weight vector must be equal to the number ' ...
            'of operators']);
   end

   % Unpack stacks
   opListNew = {};
   weightNew = [];
   for i=1:length(opList)
      info = opList{i}([],0);
      info = info{4};
      wIdx  = i; if length(weight) == 1, wIdx  = 1; end;
      if strcmp(info{1},'Stack')
         stackOperators = info{2};
         stackWeights   = info{3};
         for j=1:length(stackOperators)
            wIdxOp = j; if length(stackWeights) == 1, wIdxOp = 1; end;
            opListNew{end+1} = stackOperators{j};
            weightNew(end+1) = stackWeights(wIdxOp) * weight(wIdx);
         end
      else
         opListNew{end+1} = opList{i};
         weightNew(end+1) = weight(wIdx);
      end
   end
   
   fun = @(x,mode) opStack_intrnl(m,n,c,weightNew,opListNew,x,mode);
   op  = classOp(fun);
end


function y = opStack_intrnl(m,n,c,weight,opList, x, mode)
if mode == 0
   y = {m,n,c,{'Stack',opList,weight}};
elseif mode == 1
   y = zeros(m,1);
   k = 0;
   for i=1:length(opList)
      wIdx  = i; if length(weight) == 1, wIdx  = 1; end;

      s = opList{i}([],0);
      y(k+(1:s{1})) = weight(wIdx)*opList{i}(x,mode);
      k = k + s{1};
   end;
else   
   y = zeros(n,1);
   k = 0;
   for i=1:length(opList)
      wIdx  = i; if length(weight) == 1, wIdx  = 1; end;

      s = opList{i}([],0);
      y = y + conj(weight(wIdx))*opList{i}(x(k+(1:s{2})),mode);
      k = k + s{2};
   end
end
