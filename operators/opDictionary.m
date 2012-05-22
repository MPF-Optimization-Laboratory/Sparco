function op = opDictionary(varargin)
% OPDICTIONARY  Dictionary of concatenated operators
%
%    OPDICTIONARY(WEIGHTS, OP1, OP2, ...) creates a dictionary
%    operator consisting of the concatenation of all operators;
%    [WEIGHT1*OP1 | WEIGHT2*OP2 | ...]. The WEIGHT parameter is
%    optional and can either be a scalar or a vector. In case of a
%    scalar, all operators are weighted equally.
%
%    See also opFoG, opBLockDiag.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opDictionary.m 1027 2008-06-24 23:42:28Z ewout78 $



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
      if (info{1} ~= m)
         error(['Operator ' int2str(i) ' is not consistent with the previous operators']);
      end

      n = n + info{2};            % Total size
      c = c | info{3};            % Complex or real operator
   end
   
   % Check weight vector
   weight = weight(:);
   if (~isscalar(weight)) && (length(weight) ~= length(opList))
     error(['Length of weight vector must be equal to the number ' ...
            'of operators']);
   end
   if any(~isreal(weight)), c = ones(1,4); end;

   % Unpack dictionaries
   opListNew = {};
   weightNew = [];
   for i=1:length(opList)
      info = opList{i}([],0);
      info = info{4};
      wIdx  = i; if length(weight) == 1, wIdx  = 1; end;
      if strcmp(info{1},'Dictionary')
         dictOperators = info{2};
         dictWeights   = info{3};
         for j=1:length(dictOperators)
            wIdxOp = j; if length(dictWeights) == 1, wIdxOp = 1; end;
            opListNew{end+1} = dictOperators{j};
            weightNew(end+1) = dictWeights(wIdxOp) * weight(wIdx);
         end
      else
         opListNew{end+1} = opList{i};
         weightNew(end+1) = weight(wIdx);
      end
   end
   
   fun = @(x,mode) opDictionary_intrnl(m,n,c,weightNew,opListNew,x,mode);
   op  = classOp(fun);
end


function y = opDictionary_intrnl(m,n,c,weight,opList, x, mode)
if mode == 0
   y = {m,n,c,{'Dictionary',opList,weight}};
elseif mode == 1
   y = zeros(m,1);
   k = 0;
   for i=1:length(opList)
      wIdx  = i; if length(weight) == 1, wIdx  = 1; end;

      s = opList{i}([],0);
      y = y + weight(wIdx)*opList{i}(x(k+1:k+s{2}),mode);
      k = k + s{2};
   end;
else   
   y = zeros(n,1);
   k = 0;
   for i=1:length(opList)
      wIdx  = i; if length(weight) == 1, wIdx  = 1; end;

      s = opList{i}([],0);
      y(k+1:k+s{2}) = conj(weight(wIdx))*opList{i}(x,mode);
      k = k + s{2};
   end
end
