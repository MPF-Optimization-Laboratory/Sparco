function exClass
% Example illustrating how classification problems with Sparco can be
% solved with SPLG1

import sparco.*
import sparco.tools.*

pathstr = fileparts(mfilename('fullpath'));
pathstr = [pathstr filesep 'spgl1'];
addpath(pathstr);

% Generate the problem of classification of uncorrupted images 
  P = generateProblem('classuncorr','noseed');

% Solve the complex L1 recovery problem:
% minimize  ||z||_1  subject to  Az = b
  spglopts = spgSetParms('optTol',1e-4);
  tau = 0;   % Initial one-norm of solution
  sigma = 1; % Go for a basis pursuit solution
  z = spgl1(P.A, P.b, tau, sigma, [], spglopts);
  
% Remove spgl1 folder from path
  rmpath(pathstr)
  
% Find out from which set the solution is the closest
  sol.min = 1000;
  sol.arg = 0;
  opt     = P.A * z;
  n       = P.B.n / 8;
  m       = P.B.m;
  A       = double(P.A);
  
  for i=1:8
      idx = ((i-1)*n+1):(i*n);
      B   = A(:,idx);
      c   = z(idx,:);
      if (i==1)
          sol.min = norm(P.b-B*c,2);
          sol.arg = 1;
      else
          if norm(P.b-B*c,2) < sol.min
              sol.min = norm(P.b-B*c,2);
              sol.arg = i;
          end
      end
  end
  
  % Show a face from the real face set and the found set
  [opts,varg] = parseDefaultOpts();
  
  figure;
  subplot(1,3,1);
  imagesc(reshape(P.signal,192,168)); 
  colormap gray; axis square; title 'Initial face';
  
  subplot(1,3,2);
  img = imread(sprintf('%sprob80x_%d_01.pgm', opts.datapath, sol.arg));
  imagesc(img); title 'Face from recovered set'; colormap gray; axis square;
  
  subplot(1,3,3);
  img = imread(sprintf('%sprob80x_%d_01.pgm', opts.datapath, P.x0));
  imagesc(img); title 'Face from real set'; colormap gray; axis square;
  
  
end

