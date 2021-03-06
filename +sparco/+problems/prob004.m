function data = prob004(varargin)
%PROB004  FFT/Dirac dictionary, cosine/spikes signal Complex domain.
%
%   PROB004 creates a problem structure.  The generated signal will
%   have length N = 1024 with K = 120 random spikes and C = 2 sinusoid
%   components.
%
%   The following optional arguments are supported:
%
%   PROB004('n',N,'k',K,'c',C,flags) is the same as above, but with a signal
%   length N, K random spikes and C sinusoid components. Set C = [] to
%   use the default sine form
%
%   4 * sin(t*4*pi) + sqrt(-9) * cos(t*12*pi)
%
%   for t = [0,1). The 'noseed' flag can be specified to suppress
%   initialization of the random number generators. Each of the
%   parameter pairs and flags can be omitted.
%
%   Examples:
%   P = prob004;  % Creates the default 004 problem.
%
%   See also GENERATEPROBLEM.
%
%MATLAB SPARCO Toolbox.

% 16 Jul 09: Updated to use Spot operators.
%
%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: prob004.m 1679 2010-04-29 23:26:14Z mpf $

import spot.utils.* 
import sparco.*
import sparco.tools.*

% Parse parameters and set problem name
[opts,varg] = parseDefaultOpts(varargin);
[parm,varg] = parseOptions(varg,{'noseed'},{'c','k','n'});
c           = getOption(parm,'c',  []);
k           = getOption(parm,'k', 120);
n           = getOption(parm,'n',1024);
info.name   = 'zsinspike';

% Return problem name if requested
if opts.getname, data = info.name; return; end

% Initialize random number generators
if ~parm.noseed, rng('default'); rng(0); end

% Set up operators
F = opDFT(n);
I = opDirac(n);
M = opEye(n);

% Create Fourier coefficients
t = (0:n-1)' / n;
if isempty(c)
   sinusoid = 4.0 * sin(t*4*pi) + sqrt(-9) * cos(t*12*pi);
   sinCoef  = F * sinusoid;
else
   p          = randperm(n); p = p(1:c);
   sinCoef    = zeros(n,1);
   sinCoef(p) = (randn(c,1) + sqrt(-1) * randn(c,1)) * sqrt(n)/2;
   sinusoid   = F' * sinCoef;
end

% Create spike coefficients
p            = randperm(n); p = p(1:k);
spikeCoef    = zeros(n,1);
spikeCoef(p) = randn(k,1) + sqrt(-1) * randn(k,1);

% Synthesize signal
spike  = I * spikeCoef;

% Set up the problem
data.signal = sinusoid + spike;
data.M      = M;
data.B      = [F', I];
data.x0     = [sinCoef; spike];
data.b      = data.signal;
data.r      = zeros(size(data.b));
data        = completeOps(data);

% ======================================================================
% The following is self-documentation code, and is optional.
% ======================================================================

% Additional information
info.title           = 'Complex sinusoid with spikes';
info.thumb           = 'figProblem004';
info.fig{1}.title    = 'Real part of the signal';
info.fig{1}.filename = 'figProblem004SignalReal';
info.fig{2}.title    = 'Imaginary part of the signal';
info.fig{2}.filename = 'figProblem004SignalImag';
info.fig{3}.title    = 'Real part of the coefficients';
info.fig{3}.filename = 'figProblem004CoefReal';
info.fig{4}.title    = 'Imaginary part of the coefficients';
info.fig{4}.filename = 'figProblem004CoefImag';

% Set the info field in data
data.info = info;

% Plot figures
if opts.update || opts.show
  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  plot(t,real(data.signal),'b-');
  updateFigure(opts, info.fig{1}.title, info.fig{1}.filename)

  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  plot(t,imag(data.signal),'b-');
  updateFigure(opts, info.fig{2}.title, info.fig{2}.filename)

  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  plot(real(data.x0),'b-'); xlim([1,2048]);
  updateFigure(opts, info.fig{3}.title, info.fig{3}.filename)

  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  plot(imag(data.x0),'b-'); ylim([-10,10]); xlim([1,2048]);
  updateFigure(opts, info.fig{4}.title, info.fig{4}.filename)
  
  if opts.update
     P = ones(128,128,3);
     P = thumbPlot(P,real(data.signal),imag(data.signal),[0,0,1]);
     P = (P(1:2:end,:,:) + P(2:2:end,:,:)) / 2;
     P = (P(:,1:2:end,:) + P(:,2:2:end,:)) / 2;
     thumbwrite(P, info.thumb, opts);
  end
end
