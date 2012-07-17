function data = prob802( varargin )
%PROB802 Classification of corrupted images : Faces + Dirac dictionnary, Face
%signal
%
%   PROB802 creates a problem structure. The generated signal will
%   consist of a 192 by 168 grayscale image of a face. RHO percentage of
%   randomly chosen pixels are corrupted using i.i.d values drawn from a
%   uniform distribution in the range of the image pixel values. Then the
%   signal is down-sampled to a M by 1 signal with M = 1400. It has a 
%   sparse representation in the dictionnary of the training data (N images
%   from each of the 8 sets).
%
%   The following optional arguments are supported:
%
%   PROB801('m',M,'n',N,'rho',RHO,flags) is the same as above, but with a
%   corruption of RHO percent, a down-sampling to M and a dictionnary of N
%   images from each of the 8 sets. The 'noseed' flag can be specified to
%   suppress initialization of the random-number generators. Each of the 
%   parameter pairs and flags can be omitted.
%
%   Examples:
%   P = prob802;  % Creates the default 802 problem.
%
%   References:
%
%   [ElhaVida:2011] E. Elhamifar and R. Vidal, Robust Classification using
%       Structured Sparse Representation, Computer Vision and Pattern 
%       Recognition (CVPR), 2011 IEEE Conference on, pp. 1873-1879.
%   
%   [LeeHoKrie:2005] K.C. Lee and J. Ho and D. Kriegman, Acquiring Linear 
%       Subspaces for Face Recognition under Variable Lighting, IEEE Trans. 
%       Pattern Anal. Mach. Intelligence, 2005, 27(5), pp. 684-698.
%
%   See also GENERATEPROBLEM.

import spot.utils.* 
import sparco.*
import sparco.tools.*

% Parse parameters and set problem name
[opts,varg] = parseDefaultOpts(varargin);
[parm,varg] = parseOptions(varg,{'noseed'},{'m','n','rho'});
m           = getOption(parm,'m', 1400); % Size of images
n           = getOption(parm,'n', 18); % Size of training data (<25)
rho         = getOption(parm,'rho', 0.3); % Rate of corruption
info.name   = 'classcorr';

% Return problem name if requested
if opts.getname, data = info.name; return; end;

% Initialize random number generators
if ~parm.noseed, rng('default'); rng(0); end

% Set up the data
idx = randperm(32256); idx = idx(1:m);
imgidx = randperm(25); imgidx = imgidx(1:(n+1));
solset = randi(8);
signal = imread(sprintf('%sprob80x_%d_%02d.pgm', opts.datapath, solset, imgidx(1)));
signal = im2double(signal);
signal = reshape(signal,[],1);
n_cor  = floor(rho*32256);
coridx = randperm(32256); coridx = coridx(1:n_cor);
corval = rand(1,n_cor);

signal(coridx) = corval;

% Set up the operators
imgsets = zeros(32256,8*n);
for i=1:8
    for j=1:n
        img = imread(sprintf('%sprob80x_%d_%02d.pgm', opts.datapath, i, imgidx(j+1)));
        img = im2double(img);
        img = reshape(img,[],1);
        imgsets(:,(i-1)*n+j) = img;
    end
end
B1 = opMatrix(imgsets);
B2 = opDirac(32256);
B = opDictionary(B1,B2);
M = opRestriction(32256,idx);

% Set up the problem
data.signal = signal;
data.x0     = solset;
data.B      = B;
data.M      = M;
data.b      = M * signal;
data.r      = zeros(size(data.b));
data        = completeOps(data);

% ======================================================================
% The following is self-documentation code, and is optional.
% ======================================================================

% Additional information
info.title           = 'Classification of corrupted images';
info.thumb           = 'figProblem802';
info.citations       = {'ElhaVida:2011','LeeHoKrie:2005'};
info.fig{1}.title    = 'Face to classify';
info.fig{1}.filename = 'figProblem801Face';
info.fig{2}.title    = 'Face of set 1';
info.fig{2}.filename = 'figProblem801Face1';
info.fig{3}.title    = 'Face of set 2';
info.fig{3}.filename = 'figProblem801Face2';
info.fig{4}.title    = 'Face of set 3';
info.fig{4}.filename = 'figProblem801Face3';
info.fig{5}.title    = 'Face of set 4';
info.fig{5}.filename = 'figProblem801Face4';
info.fig{6}.title    = 'Face of set 5';
info.fig{6}.filename = 'figProblem801Face5';
info.fig{7}.title    = 'Face of set 6';
info.fig{7}.filename = 'figProblem801Face6';
info.fig{8}.title    = 'Face of set 7';
info.fig{8}.filename = 'figProblem801Face7';
info.fig{9}.title    = 'Face of set 8';
info.fig{9}.filename = 'figProblem801Face8';

% Set the info field in data
data.info = info;

% Plot figures
if opts.update || opts.show
    
  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  imagesc(reshape(data.signal,192,168)); colormap gray; axis square;
  updateFigure(opts, info.fig{1}.title, info.fig{1}.filename);
  
  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  for i=1:8
      subplot(2,4,i);
      img = imread(sprintf('%sprob80x_%d_01.pgm', opts.datapath, i));
      imagesc(img); colormap gray; axis square;
      updateFigure(opts, info.fig{i+1}.title, info.fig{i+1}.filename);
  end
  
  % Output thumbnail
  if opts.update
    P =  scaleImage(reshape(data.signal,192,168),64,64);
    thumbwrite(P, info.thumb, opts);
  end
end

