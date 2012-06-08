function exGPSR
% Example illustrating how problems generated with Sparco can be
% solved using GPSR.
%
% References:
%
%   M. Figueiredo, R. Nowak, and S. J. Wright, "Gradient projection
%      for sparse reconstruction: Application to compressed sensing
%      and other inverse  problems", To appear in IEEE Journal of
%      Selected Topics in Signal Processing: Special Issue on
%      Convex Optimization Methods for Signal Processing, 2007.
%
%   GPSR: http://www.lx.it.pt/~mtf/GPSR

%   Copyright 2007, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: exGPSR.m 900 2008-05-06 21:06:00Z ewout78 $

pathstr = fileparts(mfilename('fullpath'));
pathstr = [pathstr filesep 'gpsr'];
addpath(pathstr);

% Generate problem 6: Piecwise cubic polynomial signal.
  P = generateProblem(6);

  b  = P.b;            % The right-hand-side vector.
  m = P.A.m;      % m is the no. of rows.
  n = P.A.n;      % n is the no. of columns.
  
% Solve an L1 recovery problem:
% minimize  1/2|| Ax - b ||_2^2  +  lambda ||x||_1.
  lambda = 1000;
  x = GPSR_BB(b, P.A, lambda);
  
% Removes gpsr's path from pathlist  
  
  rmpath(pathstr);

% The solution x is the reconstructed signal in the sparsity basis. 
  figure;
  plot(x); hold on; plot(P.x0,'ro'); hold off;
  title('Coefficients of the reconstructed signal')
  xlabel('Coefficient')
  
% Use the function handle P.reconstruct to use the coefficients in
% x to reconstruct the original signal.
  y     = P.reconstruct(x);    % Use x to reconstruct the signal.
  yorig = P.signal;            % P.Signal is the original signal.

  figure;
  plot(1:length(y), y    ,'b', ...
       1:length(y), yorig,'r');
  legend('Reconstructed signal','Original signal');
  title('Reconstructed and original signals');
  
end % function exGPSR
