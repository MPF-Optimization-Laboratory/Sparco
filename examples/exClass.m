function exClass
% Example illustrating how classification problems with Sparco can be
% solved with SPLG1

pathstr = fileparts(mfilename('fullpath'));
pathstr = [pathstr filesep 'spgl1'];
addpath(pathstr);

% Generate the problem of classification of uncorrupted images 
  P = generateProblem('classcorr','m',800,'rho',0.5);

% Solve the complex L1 recovery problem:
% minimize  ||z||_1  subject to  ||Az = b||_2 <= sigma
  spglopts = spgSetParms('optTol',1e-4,'verbosity',0);
  tau = 0;   % Initial one-norm of solution
  sigma = 5; % Go for a basis pursuit solution
  z = spgl1(P.A, P.b, tau, sigma, [], spglopts);
  
% Remove spgl1 folder from path
  rmpath(pathstr)
  
% Find out from which set the solution is the closest
  n       = (P.B.n-32256) / 8;
  A       = P.A;
  
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
  [opts,varg] = sparco.tools.parseDefaultOpts();
  
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

