function exOp
% Example illustrating the use of operators.

%   Copyright 2007, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: exOp.m 900 2008-05-06 21:06:00Z ewout78 $

pathstr = fileparts(mfilename('fullpath'));
pathstr = [pathstr filesep 'spgl1'];
addpath(pathstr);

  % Set problem size
  k = 20;  % Number of non-zero coefficients
  n = 128; % Coefficient length
  m = 80;  % Number of measurements

 
  % Set up sparse coefficients
  p = randperm(n);
  x0= zeros(n,1); x0(p(1:k)) = randn(k,1);

  % Set up operators
  disp(['Setting up partial DCT measurement ' ...
        'and Haar sparsity operators']);
  p = randperm(n);
  M = opRestriction(n,p(1:m)) * opDCT(n);
  B = opHaar(n);
  A = M * B;
  
  % Compute observed signal b
  disp('Computing b = M*B*x0');
  b = A * x0;
  
  % Solve the problem
  input('Press <RETURN> to solve the problem . . .');
  [xs,r,g,info] = spgl1(A,b,0,0,[]);
  
  % Remove spgl1 from path
  rmpath(pathstr)
  
  figure(1);
  plot(1:n,xs,'b',1:n,x0,'ro');
  legend('Solution found','Original coefficients');
  
  figure(2);
  y = B * xs; % Signal from sparse Haar coefficients
  plot(1:n,y,'b-',1:n,B * x0,'ro');
  legend('Reconstructed signal','Original signal');
  
  % Quick check on operator
  disp('Corroborate correctness of operator A by checking that')
  disp('<Ax,y> = <x,A* y> for 100 random vectors x and y.');
  dottest(A,100);
  
  % Extract matrix entries and plot
  disp('Extracting matrix from operator (plot 3)');
  M = double(A);
  figure(3); imagesc(M);

end % function exOp
