function data = prob005(varargin)
%PROB005  DCT/Dirac dictionary, Gaussian measurements.
%
%   PROB005 creates a problem structure.  The generated signal will
%   have length N = 1024 and consist of K = 60 random spikes and 
%   C = 3 cosine components. The signal is measured using an M = 300
%   by N Gaussian ensemble.
%
%   The following optional arguments are supported:
%
%   PROB005('m',M,'n',N,'k',K,'c',C,flags) is the same as above, but with
%   a signal length N, K random spikes and C cosine components and an M
%   by N measurement matrix. Set C = [] to use the default cosine form
%
%   2.0 * cos(2*pi*t) + 3.0 * cos(9*pi*t) - cos(20*pi*t)
%
%   for t = [0,1). The 'noseed' flag can be specified to suppress
%   initialization of the random number generators. Each of the
%   parameter pairs and flags can be omitted.
%
%   Examples:
%   P = prob005;  % Creates the default 005 problem.
%
%   See also GENERATEPROBLEM.
%
%MATLAB SPARCO Toolbox.

% 23 Jul 09: Updated to use Spot operators.
%
%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: prob005.m 1517 2009-09-26 02:57:28Z ewout78 $

import spot.utils.* 
import sparco.*
import sparco.tools.*

% Parse parameters and set problem name
[opts,varg] = parseDefaultOpts(varargin);
[parm,varg] = parseOptions(varg,{'noseed'},{'c','k','m','n'});
c           = getOption(parm,'c',  []);
k           = getOption(parm,'k',  60);
m           = getOption(parm,'m', 300);
n           = getOption(parm,'n',1024);
info.name   = 'gcosspike';

% Return problem name if requested
if opts.getname, data = info.name; return; end

% Initialize random number generators
if ~parm.noseed, rng('default'); rng(0); end

% Create cosine coefficients
t = (0:n-1)' / n;
if isempty(c)
   cosCoef     =  zeros(n,1);
   cosCoef(4)  =  sqrt(n/2)*2;
   cosCoef(10) =  sqrt(n/2)*3;
   cosCoef(21) = -sqrt(n/2);
else
   p          = randperm(n); p = p(1:c);
   cosCoef    = zeros(n,1);
   cosCoef(p) = randn(c,1) * sqrt(n/2);
end

% Create spike coefficients
p            = randperm(n); p = p(1:k);
spikeCoef    = zeros(n,1);
spikeCoef(p) = randn(k,1);

% Set up operators
D = opDCT(n);           
I = opDirac(n);
B = [D' I];             % Sparsity dictionary
G = opGaussian(m,n,2);  % Measurement operator

% Synthesize signal
cosine = D' * cosCoef;
spike  = I  * spikeCoef;

% Set up the problem
data.signal = cosine + spike;
data.M      = G;
data.B      = B;
data.b      = G * data.signal;
data.r      = zeros(size(data.b));
data.x0     = [cosCoef; spikeCoef];
data        = completeOps(data);

% ======================================================================
% The following is self-documentation code, and is optional.
% ======================================================================

% Additional information
info.title           = 'Cosine with spikes measured with Gaussian ensemble';
info.thumb           = 'figProblem005';
info.fig{1}.title    = 'Cosine with spikes';
info.fig{1}.filename = 'figProblem005SpikyCos';
info.fig{2}.title    = 'Cosine component of the signal';
info.fig{2}.filename = 'figProblem005Cosine';
info.fig{3}.title    = 'Spike component of the signal';
info.fig{3}.filename = 'figProblem005Spikes';
info.fig{4}.title    = 'Observed signal';
info.fig{4}.filename = 'figProblem005Observed';

% Set the info field in data
data.info = info;

% Plot figures
if opts.update || opts.show
  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  plot(t,data.signal,'b-'); xlim([0,1]);
  updateFigure(opts, info.fig{1}.title, info.fig{1}.filename)

  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  plot(t,cosine,'b-'); xlim([0,1]);
  updateFigure(opts, info.fig{2}.title, info.fig{2}.filename)

  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  plot(t,spike,'b-'); xlim([0,1]);
  updateFigure(opts, info.fig{3}.title, info.fig{3}.filename)
  
  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  plot(data.b,'b-'); xlim([1,m]);
  updateFigure(opts, info.fig{4}.title, info.fig{4}.filename)

  if opts.update
     P = ones(128,128,3);
     P = thumbPlot(P,1:n,data.signal,[0,0,1]);
     P = (P(1:2:end,:,:) + P(2:2:end,:,:)) / 2;
     P = (P(:,1:2:end,:) + P(:,2:2:end,:)) / 2;
     thumbwrite(P, info.thumb, opts);
  end
end
