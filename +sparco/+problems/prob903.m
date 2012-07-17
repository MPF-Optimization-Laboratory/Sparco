function data = prob903(varargin)
%PROB903  Sparse spike deconvolution.
%
%   PROB903 creates a problem structure.  The generated signal will
%   have length N = 1024 and consist of a sparse spike train of K = 12
%   spikes convolved with a truncated second derivative of a Gaussian.
%
%   The following optional arguments are supported:
%
%   PROB903('k',K,'n',N,flags) is the same as above, but with signal
%   length N and a spike train consisting of K spikes. The 'noseed'
%   flag can be specified to suppress initialization of the random
%   number generators. Each of the parameter pairs and flags can be
%   omitted.
%
%   Examples:
%   P = prob903;  % Creates the default 903 problem.
%
%   References:
%
%   [DossMall:2005] Sparse spike deconvolution with minimum scale. In
%     Proceedings of Signal Processing with Adaptive Sparse
%     Structured Representations, pages 123-126, Rennes, France,
%     November 2005.
%
%   See also GENERATEPROBLEM.
%
%MATLAB SPARCO Toolbox.

% 8 Sep 09: Updated to use Spot operators.
%
%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: prob903.m 1679 2010-04-29 23:26:14Z mpf $

import spot.utils.* 
import sparco.*
import sparco.tools.*

% Parse parameters and set problem name
[opts,varg] = parseDefaultOpts(varargin);
[parm,varg] = parseOptions(varg,{'noseed'},{'k','n'});
n           = getOption(parm,'n',1024);
k           = getOption(parm,'k',  12);
info.name   = 'spiketrn';

% Return problem name if requested
if opts.getname, data = info.name; return; end;

% Initialize random number generators
if (~parm.noseed), rng('default'); rng(0); end;

% Set up the data
x0         = zeros(n,1);
p          = randperm(n);
x0(p(1:k)) = sign(rand(k,1)-0.5) .* (0.1 + abs(randn(k,1)));

% Compute second derivative of a Gaussian
sigma      = 0.05;
kernel0    = exp(-0.5 * (linspace(-1,1,n) / sigma).^2);
kernel1    = (linspace(-1,1,n) / -(sigma^2)) .* kernel0;
kernel2    = (linspace(-1,1,n) / -(sigma^2)) .* kernel1 + ...
             (-1/(sigma^2)) * kernel0;
kernel2(1:467) = 0;
kernel2    = kernel2(:) / kernel2(468);

kernel     = kernel2(468:end);
offset     = 1;
mode       = 'truncated';

% Set up the problem
data.kernel       = kernel;
data.signalSize   = [n,1];
data.x0           = x0;
data.M            = opConvolve(n,1,kernel(:),offset,mode);
data.b            = data.M * data.x0;
data.r            = zeros(size(data.b));
data              = completeOps(data);


% ======================================================================
% The following is self-documentation code, and is optional.
% ======================================================================

% Additional information
info.title           = 'Sparse spike deconvolution';
info.thumb           = 'figProblem903';
info.citations       = {'DossMall:2005'};
info.fig{1}.title    = 'Spikes';
info.fig{1}.filename = 'figProblem903Spikes';
info.fig{2}.title    = 'Kernel (Impulse response)';
info.fig{2}.filename = 'figProblem903Kernel';
info.fig{3}.title    = 'Convolved spike train';
info.fig{3}.filename = 'figProblem903Signal';
info.fig{4}.title    = 'Illustration on two spikes';
info.fig{4}.filename = 'figProblem903Example1';
info.fig{5}.title    = 'Illustration on two spikes (circular)';
info.fig{5}.filename = 'figProblem903Example2';

% Set the info field in data
data.info = info;

% Plot figures
if opts.update || opts.show
  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  plot(data.x0,'b-'); xlim([1,n]);
  updateFigure(opts, info.fig{1}.title, info.fig{1}.filename)

  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  plot(kernel2 / kernel2(468),'b-'); xlim([1,n]);
  updateFigure(opts, info.fig{2}.title, info.fig{2}.filename)

  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  plot(data.b,'b-'); xlim([1,n]);
  updateFigure(opts, info.fig{3}.title, info.fig{3}.filename)

  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  x = zeros(n,1); x(round(n/4)) = 1; x(n-100) = -1;
  op= opConvolve(n,1,data.kernel,offset,'truncated'); % Without wrapping
  plot(1:n,x,'b',1:n,op * x,'r.');
  updateFigure(opts, info.fig{4}.title, info.fig{4}.filename)
  
  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  op= opConvolve(n,1,data.kernel,offset,'cyclic'); % With wrapping
  plot(1:n,x,'b',1:n,op * x,'r.');
  updateFigure(opts, info.fig{5}.title, info.fig{5}.filename)

  if opts.update
     P = ones(128,128,3);
     P = thumbPlot(P,1:n,data.b,[0,0,1]);
     P = (P(1:2:end,:,:) + P(2:2:end,:,:)) / 2;
     P = (P(:,1:2:end,:) + P(:,2:2:end,:)) / 2;
     thumbwrite(P, info.thumb, opts);
  end
end
