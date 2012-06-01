function data = prob001(varargin)
%PROB001  FFT/Heaviside dictionary, HeaviSine signal.
%
%   PROB001 creates a problem structure.  The generated signal will
%   have length N = 1024.
%
%   The following optional argument calls are supported:
%
%   PROB001('n',N,flags) is the same as above but with a signal length
%   N. The 'noseed' flag can be specified to suppress initialization of
%   the random number generators. Both the parameter pair and the flags
%   can be omitted.
%
%   Examples:
%   P = prob001;  % Creates the default 001 problem.
%
%   References:
%
%   [BuckDono:1995] J. Buckheit and D.L. Donoho, WaveLab and
%     reproducible research, in: A. Antoniadis (Ed.), Wavelets and
%     Statistics, Springer, Berlin, 1995. 
%
%   [ChenDonoSaun:1998] S.S. Chen and D.L. Donoho and M.A. Saunders,
%     Atomic Decomposition by Basis Pursuit, SIAM Journal on
%     Scientific Computing, 20:1 (1998), pp. 33-61.
%
%   [DonoJohn:1993] D.L. Donoho and I.M. Johnstone, Ideal spatial
%     adaptation by wavelet shrinkage, Biometrika, 81:3 (1994),
%     pp. 425-455.
%
%   See also GENERATEPROBLEM.
%
%MATLAB SPARCO Toolbox.

% 16 Jul 09: Updated to use Spot operators.
%
%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: prob001.m 1517 2009-09-26 02:57:28Z ewout78 $

import spot.utils.* 
import sparco.*
import sparco.tools.*

% Parse parameters and set problem name
[opts,varg] = parseDefaultOpts(varargin); 
[parm,varg] = parseOptions(varg,{'noseed'},{'n'});
n           = getOption(parm,'n',1024);
info.name   = 'zheavisgn';

% Return problem name if requested
if opts.getname, data = info.name; return; end

% Construct the signal
t            = ((1:n) / n)';
signalSine   = 4.*sin(4*pi.*t);
signalJump   = - sign(t - .3) - sign(.72 - t);

% Set up the problem
F    = opDFT(n);
H    = opHeaviside(n,1);
Hinv = inv(H);

data.signal = signalSine + signalJump;
data.B      = [F, H];
data.b      = data.signal;
data.r      = zeros(size(data.b));
data.x0     = [F'   * signalSine;  ...
               Hinv * signalJump ];
data        = completeOps(data);

% Override the default reconstruction (exclude blurring)
data.reconstruct = @(x) real(data.B * x);

% ======================================================================
% The following is self-documentation code, and is optional.
% ======================================================================

% Additional information
info.title           = 'Heavisine signal';
info.thumb           = 'figProblem001';
info.citations       = {'BuckDono:1995','ChenDonoSaun:1998','DonoJohn:1993'};
info.fig{1}.title    = 'Heavisine signal';
info.fig{1}.filename = 'figProblem001Heavisine';
info.fig{2}.title    = 'Sinusoid component of heavisine signal';
info.fig{2}.filename = 'figProblem001Sinusoid';
info.fig{3}.title    = 'Piecewise constant component of heavisine signal';
info.fig{3}.filename = 'figProblem001Block';

% Set the info field in data
data.info = info;

% Plot figures
if opts.update || opts.show
    
  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  plot((1:n)./n,data.signal,'b-');
  xlim([0,1]);
  updateFigure(opts, info.fig{1}.title, info.fig{1}.filename);
  
  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  plot((1:n)./n,4.*sin(4*pi.*(1:n)./n),'b-');
  xlim([0,1]);
  updateFigure(opts, info.fig{2}.title, info.fig{2}.filename);

  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  plot((1:n)./n,-sign((1:n)./n - 0.3) - sign(0.72 - (1:n)./n),'b-');
  ylim([-4,4]);
  updateFigure(opts, info.fig{3}.title, info.fig{3}.filename);

  % Output thumbnail
  if opts.update
     P = ones(128,128,3);
     P = thumbPlot(P,1:n,data.signal,[0,0,1]);
     P = (P(1:2:end,:,:) + P(2:2:end,:,:)) / 2;
     P = (P(:,1:2:end,:) + P(:,2:2:end,:)) / 2;
     thumbwrite(P, info.thumb, opts);
  end
end
