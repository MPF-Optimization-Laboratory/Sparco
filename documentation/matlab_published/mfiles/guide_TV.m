%%
% In this example we will see an illustration of Total Variation minimization

%% Generating the problem
% We generate <problems.html#prob502 problem 502> : the Artificial Angiogram
  data = generateProblem(502);

%%
% Then we create the total variation operator thanks to the Spot's wrapper
% <tools.html#opDifference opDifference>

  TV = sparco.tools.opDifference(data.signalSize)

%%
% We set up the parameters for the Total variation problem
%
% $$
% \mbox{min } \|MBx - b\|^2 + \gamma_{L_p} \|w_{L_p}x\|_p +
% \gamma_{TV}\|w_{TV}TV(Bx)\|_q
% $$
%
% with $\alpha$ and $\beta$ being used in the line search algorithm.

  % Set solver parameters
  opts.maxIts           = 10;       % Maximum iterations
  opts.maxLSIts         = 150;      % Maximum Line Search iterations
  opts.gradTol          = 1e-30;

  opts.weightTV         = 0.001;
  opts.weightLp         = 0.01;
  opts.pNorm            = 1;
  opts.qNorm            = 1;
  opts.alpha            = 0.01;
  opts.beta             = 0.6;
  opts.mu               = 1e-12;

%% Solving the problem
% 
% We will call the <tools.html#solveTV solveTV> solver function 7 times with
% a maximum of 10 iterations. We provide easily the necessary input thanks
% to the problem structure.
  
figure;
  x = randn(prod(data.signalSize),1);
  for i=1:7
    x = sparco.tools.solveTV(data.M, data.B, TV, data.b, x, opts);
    y = data.reconstruct(x);
    subplot(2,4,i)
    imagesc(abs(y));
    title(sprintf('Iteration %d',i));
    axis square;
    drawnow;
  end
  
%%
% At the end of the 10 iterations we get the recovered signal from the
% Total Variation minimization problem. We plot the recovered signal, the
% original one and the difference between those two.

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