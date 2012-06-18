function exClass
% Example illustrating how classification problems with Sparco can be
% solved with SPLG1

pathstr = fileparts(mfilename('fullpath'));
pathstr = [pathstr filesep 'spgl1'];
addpath(pathstr);

% Generate the problem of classification of uncorrupted images 
  generateProblem('classuncorr')

% Solve the complex L1 recovery problem:
% minimize  ||z||_1  subject to  Az = b
  opts = spgSetParms('optTol',1e-4);
  tau = 0;   % Initial one-norm of solution
  sigma = 0; % Go for a basis pursuit solution
  z = spgl1(P.A, P.b, tau, sigma, [], opts);
  
% Remove spgl1 folder from path
  rmpath(pathstr)
  
  
end

