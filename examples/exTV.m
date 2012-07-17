function exTV
% Illustration of Total Variation minimization
%
% References
%     M. Lustig, D.L. Donoho, and J.M. Pauly, Sparse MRI: The
%         application of compressed sensing for rapid MR imaging,
%         Submitted to Magnetic Resonance in Medicine, 2007.
%
%     SparseMRI: http://www.stanford.edu/~mlustig/SparseMRI.html

%   Copyright 2007, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: exTV.m 900 2008-05-06 21:06:00Z ewout78 $

  % Create the data
  data = generateProblem(502);

  % Create total difference 'operator'
  TV = sparco.tools.opDifference(data.signalSize);

  % Set solver parameters
  opts.maxIts           = 10;
  opts.maxLSIts         = 150;
  opts.gradTol          = 1e-30;

  opts.weightTV         = 0.001;
  opts.weightLp         = 0.01;
  opts.pNorm            = 1;
  opts.qNorm            = 1;
  opts.alpha            = 0.01;
  opts.beta             = 0.6;
  opts.mu               = 1e-12;

  % Give instructions to the user.
  fprintf('----------------------------------------\n');
  fprintf('This script calls "solveTV" seven times,\n');
  fprintf('each with a maximum of 10 iterations.\n');
  fprintf('Ignore the messages "ERROR EXIT"\n');
  fprintf('----------------------------------------\n');
  input('Press "Return" to continue.');
  
  figure;
  % Solve
  x = randn(prod(data.signalSize),1);
  for i=1:7
    x = sparco.tools.solveTV(data.M, data.B, TV, data.b, x, opts);
    y = data.reconstruct(x);
    imagesc(abs(y));
    title(sprintf('Iteration %d',i));
    drawnow;
  end
  
  yreal = data.signal;
  
  % Plot original and recovered signal and difference
  figure;
  subplot(1,3,1);
    imagesc(real(y));
    title('Recovered signal');
    axis square;
    
  subplot(1,3,2);
    imagesc(real(yreal));
    title('Original signal');
    axis square;
    
  subplot(1,3,3);
    imagesc(real(y - yreal));
    title('Difference');
    axis square;
    
  
end % function exTV

