function data = prob601(varargin)
%PROB601  Daubechies basis, binary measurement basis, grayscale image.
%
%   PROB601 creates a problem structure. The generated signal will
%   consist of a 64 by 64 grayscale image of a soccer ball. The signal
%   is measured using an M by 4096 binary ensemble, with M = 3200.
%
%   The following optional arguments are supported:
%
%   PROB601('m',M,'scale',SCALE,flags) is the same as above,
%   but with a an image size of 32 by 32 if SCALE = 1 and 64 by 64 if
%   SCALE = 2. The measurement matrix has a size M by (32*SCALE)^2.
%   Leaving M unspecified gives a measurement matrix of size
%   800*SCALE^2 by (32*SCALE)^2. The 'noseed' flag can be specified
%   to suppress initialization of the random number generators. Each
%   of the parameter pairs and flags can be omitted.
%
%   Examples:
%   P = prob601;  % Creates the default 601 problem.
%
%   References:
%
%   [TakhLaskWakiEtAl:2006] D. Takhar and J. N. Laska and M. Wakin
%     and M. Duarte and D. Baron and S. Sarvotham and K. K. Kelly
%     and R. G. Baraniuk, A new camera architecture based on
%     optical-domain compression, in Proceedings of the IS&T/SPIE
%     Symposium on Electronic Imaging: Computational Imaging,
%     January 2006, Vol. 6065.
%
%   The soccerball image is taken from Wikipedia.
%
%   See also GENERATEPROBLEM.
%
%MATLAB SPARCO Toolbox.

% 8 Sep 09: Updated to use Spot operators.
%
%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: prob601.m 1680 2010-07-08 22:54:39Z mpf $

import spot.utils.* 
import sparco.*
import sparco.tools.*

% Parse parameters and set problem name
[opts,varg] = parseDefaultOpts(varargin);
[parm,varg] = parseOptions(varg,{'noseed'},{'m','scale'});
scale       = getOption(parm,'scale', 2); % 1 or 2
m           = getOption(parm,'m',    []);
info.name   = 'soccer1';

% Return problem name if requested
if opts.getname, data = info.name; return; end

% Initialize random number generators
if (~parm.noseed), rng('default'); rng(0); end

% Set up the data
n = 32 * scale;
if isempty(m), m = 800 * scale^2; end
signal = imread(sprintf('%sprob601_ballsmooth%d.png',opts.datapath,n));

% Set up operators
M = opBernoulli(m,n^2,2);
B = opWavelet(n,n,'Daubechies')'; % note transpose

% Set up the problem
data.signal = double(signal) / 256;
data.M      = M;
data.B      = B;
data.b      = M * reshape(data.signal,n*n,1);
data.r      = zeros(size(data.b));
data.x0     = [];
data        = completeOps(data);


% ======================================================================
% The following is self-documentation code, and is optional.
% ======================================================================

% Additional information
info.title           = 'Smooth soccer ball';
info.thumb           = 'figProblem601';
info.citations       = {'TakhLaskWakiEtAl:2006'};
info.fig{1}.title    = 'Original signal';
info.fig{1}.filename = 'figProblem601Signal';

% Set the info field in data
data.info = info;

% Plot figures
if opts.update || opts.show
  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  image(data.signal * 64); colormap gray;
  updateFigure(opts, info.fig{1}.title, info.fig{1}.filename)
  
  if opts.update
     P = double(imread([opts.datapath,'prob601_ballsmooth64.png'])) / 256;
     thumbwrite(P, info.thumb, opts);
  end
end
