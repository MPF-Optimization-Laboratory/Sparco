function ex1
% Example illustrating problem generation, and the interpretation
% of the problem data structure.

%   Copyright 2007, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: ex1.m 900 2008-05-06 21:06:00Z ewout78 $

% Generate problem 6: Piecwise cubic polynomial signal.  The
% structure P holds all the information about that problem.
  P = generateProblem(6);

  A = P.A; % The operator A = Gaussian * Daubechies
  b = P.b; % The right-hand-side vector.
  
  m = P.A.m;  % m is the no. of rows in A.
  n = P.A.n;  % n is the no. of columns in A.
  
% Some (but not all) problems have the "correct" sparse coefficient
% vector.  Generally, finding this sparse representation is the hard
% part!  Plot the coefficients.
  x = P.x0;
  figure;
  plot(x);
  title('Coefficients of the signal in the sparsity basis')
  xlabel('Coefficients')

% The function handle P.reconstruct is an aid in reconstructing the
% signal from the coefficient vector x.
  y = P.reconstruct(x);    % Use x to reconstruct the signal.

% yorig = P.signal;        % P.Signal is the original signal.

  figure;
  plot(y);
  title('Original signal');

% Using the operators:  Here's an example on how to use the
% function handles that describe the linear operator.
%
% Consider the least-squares problem
%
%    minimize  1/2 || A*x - b ||_2^2
%  
% The residual and objective gradient at x are given by
  r = b - A * x;
  g =   - A'* r;
 
end % function ex1
