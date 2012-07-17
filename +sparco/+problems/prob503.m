function data = prob503(varargin)
%PROB503  Shepp-Logan phantom, partial Fourier with sample mask,
%         complex domain, total variation.
%
%   PROB503 creates a problem structure.  The generated signal will
%   consist of a N = 256 by N Shepp-Logan phantom. The signal is
%   sampled at random locations in frequency domain generated
%   according to a probability density function.
%
%   The following optional arguments are supported:
%
%   PROB503('n',N,flags) is the same as above, but with a
%   phantom of size N by N. The 'noseed' flag can be specified to
%   suppress initialization of the random number generators. Both
%   the parameter pair and flags can be omitted.
%
%   Examples:
%   P = prob503;  % Creates the default 503 problem.
%
%   References:
%
%   [LustDonoPaul:2007] M. Lustig, D.L. Donoho and J.M. Pauly,
%     Sparse MRI: The application of compressed sensing for rapid MR
%     imaging, Submitted to Magnetic Resonance in Medicine, 2007.
%
%   [sparsemri] M. Lustig, SparseMRI,
%     http://www.stanford.edu/~mlustig/SparseMRI.html
%
%   See also GENERATEPROBLEM.
%
%MATLAB SPARCO Toolbox.

% 8 Sep 09: Updated to use Spot operators.
%
%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: prob503.m 1679 2010-04-29 23:26:14Z mpf $

import spot.utils.* 
import sparco.*
import sparco.tools.*

% Parse parameters and set problem name
[opts,varg] = parseDefaultOpts(varargin);
[parm,varg] = parseOptions(varg,{'noseed'},{'n'});
n           = getOption(parm,'n',256);
info.name   = 'phantom2';

% Return problem name if requested
if opts.getname, data = info.name; return; end;

% Initialize random number generators
if (~parm.noseed), rng('default'); rng(0); end;

% Set up the data
pdf  = genPDF([n,n],5,0.33,2,0.1,0);
mask = genSampling(pdf,10,60);

% Set up operators
M = opMask(mask);
F = opDFT2(n,n,true);

% Set up the problem
noise                = randn(n)*0.01 + sqrt(-1)*randn(n)*0.01;
data.signal          = ellipses(n);
data.M               = M * F;
data.r               = data.M * reshape(noise,[n*n,1]);
data.b               = data.M * reshape(data.signal,[n*n,1]) + data.r;
data                 = completeOps(data);


% ======================================================================
% The following is self-documentation code, and is optional.
% ======================================================================

% Additional information
info.title           = 'Shepp-Logan';
info.thumb           = 'figProblem503';
info.citations       = {'LustDonoPaul:2007','sparsemri'};
info.fig{1}.title    = 'Shepp-Logan phantom';
info.fig{1}.filename = 'figProblem503Phantom';
info.fig{2}.title    = 'Probability density function';
info.fig{2}.filename = 'figProblem503PDF';
info.fig{3}.title    = 'Sampling mask';
info.fig{3}.filename = 'figProblem503Mask';

% Set the info field in data
data.info = info;

% Plot figures
if opts.update || opts.show
  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  imagesc(data.signal), colormap gray;
  updateFigure(opts, info.fig{1}.title, info.fig{1}.filename)

  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  imagesc(pdf), colormap gray;
  updateFigure(opts, info.fig{2}.title, info.fig{2}.filename)

  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  imagesc(mask), colormap gray
  updateFigure(opts, info.fig{3}.title, info.fig{3}.filename)
  
  if opts.update
     mn = min(min(data.signal + real(noise)));
     mx = max(max(data.signal + real(noise)));
     P = (data.signal + real(noise) - mn) / (mx - mn);
     P = scaleImage(P,128,128);
     P = P(1:2:end,1:2:end,:);
     thumbwrite(P, info.thumb, opts);
  end
end
