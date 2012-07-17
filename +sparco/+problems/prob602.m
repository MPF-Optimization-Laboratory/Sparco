function data = prob602(varargin)
%PROB602  2D Haar basis, binary measurement, b/w image.
%
%   PROB602 creates a problem structure. The generated signal will
%   consist of a 64-by-64 black and white image of a soccer ball.
%   The signal is measured using an M-by-4096 binary ensemble, with
%   M = 3200.
%
%   The following optional arguments are supported:
%
%   PROB602('m',M,'scale',SCALE,flags) is the same as above, but with
%   an image size of 32-by-32 if SCALE = 1, and 64-by-64 if SCALE = 2
%   (default).  The measurement matrix is of size M-by-(32*SCALE)^2.
%   Leaving M unspecified gives a measurement matrix of size
%   800*SCALE^2-by-(32*SCALE)^2. The 'noseed' flag can be specified to
%   suppress initialization of the random-number generators. Each of
%   the parameter pairs and flags can be omitted.
%
%   Examples:
%   P = prob602;  % Creates the default 602 problem.
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
%   $Id: prob602.m 1677 2010-04-29 23:08:47Z mpf $

import spot.utils.* 
import sparco.*
import sparco.tools.*

% Parse parameters and set problem name
[opts,varg] = parseDefaultOpts(varargin);
[parm,varg] = parseOptions(varg,{'noseed'},{'m','scale'});
scale       = getOption(parm,'scale', 2); % 1 or 2
m           = getOption(parm,'m',    []);
info.name   = 'soccer2';

% Return problem name if requested
if opts.getname, data = info.name; return; end

% Initialize random number generators
if (~parm.noseed), rng('default'); rng(0); end

% Set up the data
n = 32 * scale;
if isempty(m), m = 800 * scale^2; end

% Set up operators
M = opBinary(m,n*n);
B = opHaar2(n,n);

% Set up the problem
data.signal      = double(imread(sprintf('%sprob602_ball%d.png',opts.datapath,n)));
data.M           = M;
data.B           = B;
data.b           = M * reshape(data.signal,n*n,1);
data.r           = zeros(size(data.b));
data.x0          = [];
data             = completeOps(data);


% ======================================================================
% The following is self-documentation code, and is optional.
% ======================================================================

% Additional information
info.title           = 'Soccer ball';
info.thumb           = 'figProblem602';
info.citations       = {'TakhLaskWakiEtAl:2006'};
info.fig{1}.title    = 'Original signal';
info.fig{1}.filename = 'figProblem602Signal';

% Set the info field in data
data.info = info;

% Plot figures
if opts.update || opts.show
  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  imagesc(data.signal); colormap gray;
  updateFigure(opts, info.fig{1}.title, info.fig{1}.filename)
  
  if opts.update
     P = double(imread([opts.datapath,'prob602_ball64.png']));
     thumbwrite(P, info.thumb, opts);
  end
end
