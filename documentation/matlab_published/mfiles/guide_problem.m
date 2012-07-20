%%
% A single data structure defines all aspects of a problem, and is designed
% to give flexible access to specific components.

%% General structure
% Each Sparco problem consists of an observation vector $b$ which is
% formed by applying measurement matrix $M$ on a signal that has a
% sparse representation in sparsity basis $B$:
%  
% $$b = M*y$$
%  
% or
%  
% $$b = MBx_0 = Ax_0$$
%  
% where $x_0$ is a sparse vector. By convention $A$ is defined as $MB$.
% For some problems noise $r$ is added to the observation b to make
% the scenario more realistic.
% For the sake of
% uniformity, there are a small numbre of fields that are guaranteed to
% exist in every problem structure. These include Spot operators $A$, $B$ 
% and $M$, the data for the observed signal $b$ and the dimensions of the
% (perhaps unobserved) actual signal $b_0 = Bx$.
%
%% Code example
%  Create a new test problem using its name or its sparcoID. For example,
%  to make the Piecewise cubic polynomial problem:

  P = generateProblem(6) 

%% 
% We have access to all the components of the problem using the structure
% above. A precise description of the operators is provided by Spot.

A = P.A  % The operator A = Gaussian * Daubechies
b = P.b; % The right-hand side vector

%%
% The 'info' field provides additional information about the problem.

ID          = P.info.sparcoID
name        = P.info.name
description = P.info.title

%%
% Some (but not all) problems have the "correct" sparse coefficient
% vector.  Generally, finding this sparse representation is the hard
% part!  Here is a plot of the coefficients.

  x = P.x0;
  plot(x);

%%
% The function handle P.reconstruct is an aid in reconstructing the
% signal from the coefficient vector x.

  y = P.reconstruct(x);    % Use x to reconstruct the signal.
  %yorig = P.signal;        % P.Signal is the original signal (here yorig = y because y = B*x0).
  plot(y);
  
%% Using the operators
% Here's an example on how to use the function handles that describe the 
% linear operator.
% Consider the least-squares problem
% $$
% \mbox{min } \frac{1}{2} \|Ax - b\|_2^2
% $$
%  
% The residual and objective gradient at x are given by

  r = b - A * x;
  g =   - A'* r;