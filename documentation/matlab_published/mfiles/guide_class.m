%%
% In this example we will see the specificity of the classification
% problems (<problems.html#prob801 801> and <problems.html#prob802 802>) and solve
% one using <http://www.cs.ubc.ca/labs/scl/spgl1 SPGL1>.

%% Generating the problem
%
% We generate the problem of the classification of corrupted images (<problems.html#prob802 problem 802>)
% with the corruption ration $\rho = 0.4$, the doxn-sampling to $m=1400$ 
% coefficients (instead of 168*192=32256 pixels) and $n=16$ images from each of
% the 8 sets of the training data to form the dictionary.

  P = generateProblem('classcorr','n',16,'m',1400,'rho',0.4);

%%
% The Dictionary used is a concatenation of the dictionary formed by the
% training data and the identity matrix to take into account the error
% created by the corruption :

B  = P.B            % The full dictionary
B1 = B.children{1}  % The dictionary from the training data
B2 = B.children{2}  % The identity matrix

%% Solving the problem
% We solve the recovery problem using spgl1:
%
% $$ \mbox{min } \|c\|_1 + \|e\|_1 \mbox{  s.t  }  \|[B1 \mbox{ } B2] \left[\begin{array}{c}c
% \\ e\end{array}\right] - b\|_2 \leq \sigma$$
%

  spglopts = spgSetParms('optTol',1e-4,'verbosity',1);
  tau = 0;   % Initial one-norm of solution
  sigma = 9; % Go for a basis pursuit solution
  z = spgl1(P.A, P.b, tau, sigma, [], spglopts);

%%  
% We now find out which set the solution is the closest to : 
%
% $$ \mbox{class}(y) = \mbox{argmin}_i \|y - e^{*} - B[i]c^{*}[i]\|_2 $$
%
% with $i$ being the number of the set. Thus, we have to take out each set
% one-by-one along with the Dirac operator to compute the 2-norm.

  n = (P.B.n-32256) / 8; % Number of images per set from the training data (there are 8 sets)
  A = P.A;
  
  for i=1:8
      idx = [((i-1)*n+1):(i*n) (8*n+1):A.n];    % Take out the indices of the c[i] and e
      B   = A(:,idx);
      y   = z(idx,:);
      if (i==1)                                 % Initialize the min and arg
          sol.min = norm(P.b-B*y,2);
          sol.arg = 1;
      else
          if norm(P.b-B*y,2) < sol.min
              sol.min = norm(P.b-B*y,2);
              sol.arg = i;
          end
      end
  end
  
  %%
  % Now that we have the recovered set, it is time to check if the result
  % is good. The structure of the problem P gives us the real set our image
  % is from using P.x0. This is the main different thing between problems 80x
  % (where P.x0 is just the original set) and the others (where P.x0 is
  % the real sparse representation of the signal). Then we plot the image
  % we wanted to classify, the first image of the recovered set and the
  % first image from the real set. 
  
  [opts,varg] = sparco.tools.parseDefaultOpts(); % To get the datapath
  
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
  