function exSPGL1
% Example illustrating how problems generated with Sparco can be
% solved using SPGL1.
%
% References:
%
%   E. van den Berg and M. P. Friedlander, "In pursuit of a root", UBC
%   Computer Science Technical Report TR-2007-19, June 2007.
%
%   http://www.cs.ubc.ca/labs/scl/index.php/Main/Spgl1

%   Copyright 2007, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: exSPGL1.m 900 2008-05-06 21:06:00Z ewout78 $

pathstr = fileparts(mfilename('fullpath'));
pathstr = [pathstr filesep 'spgl1'];
addpath(pathstr);

% Generate problem 'angiogram' (Sparco problem 502)
  P = generateProblem('angiogram');

% Solve the complex L1 recovery problem:
% minimize  ||z||_1  subject to  Az = b
  opts = spgSetParms('optTol',1e-4);
  tau = 0;   % Initial one-norm of solution
  sigma = 0; % Go for a basis pursuit solution
  z = spgl1(P.A, P.b, tau, sigma, [], opts);

% Remove spgl1 folder from path
  rmpath(pathstr)
  
% Reconstruct the signal y from the computed complex coefficients z
  y = P.reconstruct(z);

% The original signal is stored in the structure P
  yorig = P.signal;

% Compute real measurement bMes
  MMes = P.M;
  bMes = MMes*y(:); % bMes = padding*fft*signal

% Plot exact and observed Fourier coefficients
  figure;
  subplot(2,2,1);
     imagesc(real(reshape(bMes,100,100)));
     title('Real part observed');
     axis square;
     
  subplot(2,2,2);
     imagesc(imag(reshape(bMes,100,100)));
     title('Imaginary part observed');
     axis square;
     
  subplot(2,2,3);
     imagesc(real(reshape(P.b,100,100)));
     title('Real part exact');
     axis square;
     
  subplot(2,2,4);
     imagesc(imag(reshape(P.b,100,100)));
     title('Imaginary part exact');
     axis square;
  
% Plot original and recovered signal and difference
  figure;
  subplot(1,3,1);
     imagesc(real(yorig));
     title('Original signal');
     axis square;
     
  subplot(1,3,2);
     imagesc(real(y));
     title('Recovered signal');
     axis square;
     
  subplot(1,3,3);
     imagesc(real(y - yorig));
     title('Difference');
     axis square;
  
end % function exSPGL1
