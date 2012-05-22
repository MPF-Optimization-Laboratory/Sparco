function [str,scalar,precedence] = opToString(opIn)
%OPTOSTRING  Generate string description of operator
%
%   OPTOSTRING(OP) returns a string describing operator OP.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opToString.m 1027 2008-06-24 23:42:28Z ewout78 $

% Get operator information
opList = argToOperator(opIn);
op     = opList{1};
opInfo = op([],0);
type   = opInfo{4};


% Set default multiplication factor and precedence
scalar     = 1;
precedence = 1;


switch type{1}
   case {'Dictionary','Stack'}
      str = '[';
      sep = '';
      oplist = type{2};
      weight = type{3};
      
      if strcmp(type{1},'Dictionary'), sep = ','; end;
      if strcmp(type{1},'Stack'     ), sep = ';'; end;
      
      if (length(weight) == 1) || (length(unique(weight)) == 1)
         scalar = weight(1);
         weight = [1];
      end      
      
      for i=1:length(oplist)
         % Get the string representation for the operator
         [s,w,p] = opToString(oplist{i});
         
         % Handle weights
         wIdx = i; if length(weight) == 1, wIdx = 1; end;
         if w*weight(wIdx) ~= 1
            % When there is a weight we may have to put brackets
            % around the expression first
            s = checkPrecedence(s,1,p);
            w = weightToString(w*weight(wIdx));
            s = [w,'*',s];
         end
         
         if i ~= 1,
           str = [str, sep, ' ', s];
         else
           str = [str, s];
         end
      end
      str = [str,']'];

   case {'FoG'}
      oplist = type{2}; str = '';
      weight = 1;
      for i=1:length(oplist)
         [s,w,p] = opToString(oplist{i});
         s = checkPrecedence(s,1,p);
         weight = weight * w;
        
         if i~= 1,
            str = [str, ' * ', s];
         else
            str = [str, s];
         end
      end

      scalar = weight;
      
   case {'Scalar'}
      oplist = type{2};
      [str,w,precedence] = opToString(oplist);
      scalar = type{3} * w;
      
    case {'BlockDiag'}
      str = [type{1} '('];
      oplist = type{2}; % TODO: WEIGHTS in type{3}
      for i=1:length(oplist)
         s2 = opToString(oplist{i});
         if i ~= 1,
           str = [str, ', ', s2];
         else
           str = [str, s2];
         end
      end
      str = [str, ')'];

     
   case {'Sum'}
      oplist  = type{2};
      weights = type{3};
      str = '';
      for i=1:length(oplist)

        % Format the operator
        [s,w,p] = opToString(oplist{i});
        w = w * weights(i);
        if w == 1
           s = checkPrecedence(s,2,p);
        else
           % Multiplication applies to each term of operator
           % add brackets if needed
           s = checkPrecedence(s,1,p);
        end
        
        % Format the weight
        if w == 1
             if i == 1
                 weightStr = '';
             else
                 weightStr = ' + ';
             end
        elseif w == -1
             if i == 1
                 weightStr = '-';
             else
                 weightStr = ' - ';
             end
        elseif ~isreal(w) && ~isreal(w*sqrt(-1)) % Fully complex
             if i == 1
                weightStr = sprintf('(%d%+di)*',real(w),imag(w));
             else
                weightStr = sprintf(' + (%d%+di)*',real(w),imag(w));
             end
        elseif ~isreal(w) && imag(w) > 0 % Purely imaginary > 0
             if i == 1
                 weightStr = sprintf('%di*', imag(w));
             else
                 weightStr = sprintf(' + %di*', imag(w));
             end
        elseif ~isreal(w) && imag(w) < 0 % Purely imaginary < 0
             if i == 1
                 weightStr = sprintf('-%di*', abs(imag(w)));
             else
                 weightStr = sprintf(' - %di*', abs(imag(w)));
             end
        elseif w > 0
             if i == 1
                 weightStr = sprintf('%d*', w);
             else
                 weightStr = sprintf(' + %d*', w);
             end
         else
             if i == 1
                 weightStr = sprintf('%d * ', w);
             else
                 weightStr = sprintf(' - %d * ', abs(w));
             end
         end
         
         str = [str, weightStr, s];
         precedence = 2;
      end
 
   case {'Transpose'}
      oplist = type{2};
      str = ['(',opToString(oplist), ')^T'];
      
   case {'Crop'}
      str = sprintf('Crop(%s)',opToString(type{2}));
 
   case {'Wavelet'}
      name = type{2};
      name(1) = upper(name(1));
      str = sprintf('%s-Wavelet',name);
      
   case {'Kron'}
      str = sprintf('Kron(%s,%s)',opToString(type{2}), ...
                                  opToString(type{3}));
   
   case {'WindowedOp'}
      str = sprintf('Windowed(%s)',opToString(type{2}));
    
 
 otherwise
      str = sprintf('%s(%d,%d)',type{1},opInfo{1},opInfo{2});
end


% Apply scalar if number of arguments is less than 2
if (nargout < 2) && (scalar ~= 1)
   str = checkPrecedence(str,1,precedence);
   w   = weightToString(scalar);
   str = [w, ' * ',str];
end

% Print the result if no output arguments given
if (nargout == 0)
   fprintf('%s\n',str);
end



function str = checkPrecedence(str,p1,p2)
if p1 < p2
   str = ['(', str,')'];
end

function str = weightToString(w)

if w == 1
  str = '';
elseif isreal(w)
  str = sprintf('%d',w);
elseif isreal(w*sqrt(-1))
  str = sprintf('%di',imag(w));
else
  str = sprintf('(%d%+di)',real(w),imag(w));
end
