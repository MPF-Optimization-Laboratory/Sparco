function data = prob403(varargin)
%PROB403  Source separation example 3 - Starry Lenographer.
%
%   PROB403 creates a problem structure.  The generated signal will
%   consist of two mixed images from three sources; the cameraman,
%   Lena and a two-dimensional blurred spike array.
%
%   The following optional arguments are supported:
%
%   PROB403('mixing',MIXING,flags) is the same as above, but with the
%   2 bv 3 mixing matrix set to MIXING. The flags include the default
%   'show' and 'update' flags for plotting the problem illustrations.
%
%   Examples:
%   P = prob403;  % Creates the default 403 problem.
%
%   See also GENERATEPROBLEM.
%
%MATLAB SPARCO Toolbox.

% 8 Sep 09: Updated to use Spot operators.
%
%   Copyright 2008, Rayan Saab, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: prob403.m 1679 2010-04-29 23:26:14Z mpf $

import spot.utils.* 
import sparco.*
import sparco.tools.*

% Parse parameters and set problem name
[opts,varg] = parseDefaultOpts(varargin);
[parm,varg] = parseOptions(varg,{'noseed'},{'mixing'});
mixingDef   = [0.2081    0.0501    0.7418
               0.6592    0.1986    0.1422
               0.1167    0.6758    0.2075];
mixing      = getOption(parm, 'mixing', mixingDef);
info.name   = 'srcsep3';

% Return problem name if requested
if opts.getname, data = info.name; return; end;

% Initialize random number generators
if (~parm.noseed), rng('default'); rng(0); end;

% Set up the data
s1 = imread(sprintf('%sprob701_Camera.tif', opts.datapath));
s1 = double(s1(:))/256;
s2 = imread(sprintf('%sprob403_Lena512.bmp', opts.datapath));
s2 = double(s2) / 256;
s2 = (s2(:,1:2:end) + s2(:,2:2:end)) / 2;
s2 = (s2(1:2:end,:) + s2(1:2:end,:)) / 2;
s2 = s2(:);
s3 = (rand(256,256) <= 0.01); % One percent chance of spike
s3 = s3(:);
m  = length(s1);
idx= randperm(256); idx = idx(1:220);

% Set up operators
Blur        = sparcoBlur(256,256);
Wavelet     = opWavelet(256,256,'Daubechies');
Dirac       = opDirac(256*256);
Restriction = sparcoColumnRestrict(256,256,idx,'zero');
BlockDiagB  = opBlockDiag(Wavelet, ...
                          Wavelet, ...
                          Dirac);
BlockDiagM = opBlockDiag([1,1,3], ...
                         Restriction, ...
                         Dirac, ...
                         Blur);
MixingMatrix = opMatrix(kron(mixing,speye(m,m)), ...
                        'Mixing matrix: kron(mixing,speye)');

% Sparsify the images (keep 15%)
s1  = sparsify(s1,0.15,Wavelet);
s2  = sparsify(s2,0.15,Wavelet);

% Set up the problem
data.signal = [s1, s2, s3];
data.B      = BlockDiagB;
data.M      = MixingMatrix * BlockDiagM;
data.b      = data.M * data.signal(:);
data.r      = zeros(size(data.b));
data        = completeOps(data);

% Override the default reconstruction (exclude blurring)
m  = 256;
m2 = m*m;
data.reconstruct = @(x) {reshape(Wavelet * x(1:m2),m,m),...
                         reshape(Wavelet * x(m2+(1:m2)),m,m), ...
                         reshape(x(2*m2+(1:m2)),m,m)};

% ======================================================================
% The following is self-documentation code, and is optional.
% ======================================================================

% Additional information
info.title           = 'Source separation example 3 - Starry Lenographer';
info.thumb           = 'figProblem403';
info.citations       = {};
info.fig{1}.title    = 'Photographer';
info.fig{1}.filename = 'figProblem403Image1';
info.fig{2}.title    = 'Lena';
info.fig{2}.filename = 'figProblem403Image2';
info.fig{3}.title    = 'Stars';
info.fig{3}.filename = 'figProblem403Image3';
info.fig{4}.title    = 'Mixed image 1';
info.fig{4}.filename = 'figProblem403Mixed1';
info.fig{5}.title    = 'Mixed image 2';
info.fig{5}.filename = 'figProblem403Mixed2';
info.fig{6}.title    = 'Mixed image 3';
info.fig{6}.filename = 'figProblem403Mixed3';

% Set the info field in data
data.info = info;

% Plot figures
if opts.update || opts.show
  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  imagesc(reshape(data.signal(:,1),256,256)),colormap gray
  updateFigure(opts, info.fig{1}.title, info.fig{1}.filename)

  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  imagesc(reshape(data.signal(:,2),256,256)),colormap gray
  updateFigure(opts, info.fig{2}.title, info.fig{2}.filename)

  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  imagesc(reshape(data.signal(:,3),256,256)),colormap gray
  updateFigure(opts, info.fig{3}.title, info.fig{3}.filename)

  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  imagesc(reshape(data.b(1:m2),256,256)),colormap gray
  updateFigure(opts, info.fig{4}.title, info.fig{4}.filename)

  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  imagesc(reshape(data.b(m2+(1:m2)),256,256)),colormap gray
  updateFigure(opts, info.fig{5}.title, info.fig{5}.filename)

  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  imagesc(reshape(data.b(2*m2+(1:m2)),256,256)),colormap gray
  updateFigure(opts, info.fig{6}.title, info.fig{6}.filename)

  if opts.update
     P = reshape(data.b(1:m2),256,256);
     P = P / max(max(P));
     P = scaleImage(P,64,64);
     thumbwrite(P, info.thumb, opts);
  end
end

