function y = mtimes(A,B)

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: mtimes.m 1027 2008-06-24 23:42:28Z ewout78 $

% Note that either A or B is the classOp since this function gets
% called for both M*C, C*M, where C is the class and M is a
% matrix or vector. This gives the following options, with S for
% scalar and C for any instance of a classOp
%
% 1) M*C, to be implemented as (C'*M')'
% 2) C*M
% 3) s*C
% 4) C*s
% 5) C*C, either of which can be a foreign class

if isnumeric(A)
    % Mode 1 or 3, A*B, with A matrix or scalar
    if isscalar(A)
       y = opScalar(B,A);
    else
      y = (B' * A')';
    end
elseif isnumeric(B)
    % Mode 2 or 4, with A operator and B matrix or scalar
    if isscalar(B)
      y = opScalar(A,B);
    else
      [m,n] = size(A);
      [p,q] = size(B);
      
      % Raise an error when the matrices do not commute
      if p ~= n
          fmt = 'Matrix dimensions must agree when multiplying by %s';
          msg = sprintf(fmt, opToString(getHandle(B)));
          error(msg);
      end
      
      % Preallocate y
      y = zeros(m,q);
      
      % Perform operator*vector on each column of B
      for i=1:q
          if A.adjoint == 0
             y(:,i) = A.op(B(:,i),1);
          else
             y(:,i) = A.op(B(:,i),2);
          end
      end
      
      % Update the counter
      if ~isempty(A.counter)
          if A.adjoint == 0
             evalin('base',[A.counter '=' A.counter sprintf('+ [%d 0];',q)]);
          else
             evalin('base',[A.counter '=' A.counter sprintf('+ [0 %d];',q)]);
          end
      end
    end
else
   % Apply FoG operator 
   y = opFoG(A,B);
end
