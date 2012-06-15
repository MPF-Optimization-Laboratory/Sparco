function data = prob801( varargin )
%PROB801 Classification of uncorrupted images : Faces dictionnary, Face
%signal
%
%   Detailed explanation goes here

import spot.utils.* 
import sparco.*
import sparco.tools.*

% Parse parameters and set problem name
[opts,varg] = parseDefaultOpts(varargin);
[parm,varg] = parseOptions(varg,{'noseed'},{'m','n'});
m           = getOption(parm,'m', 1400); % Size of images
n           = getOption(parm,'n', 18); % Size of training data
info.name   = 'classuncorr';

% Return problem name if requested
if opts.getname, data = info.name; return; end;

% Initialize random number generators
if ~parm.noseed, randn('state',0); rand('state',0); end

% Set up the data
idx = randperm(32256); idx = idx(1:m);
Restriction = opRestriction(32256,idx);
imgidx = randperm(25); idx = idx(1:n);
solset = randi(8);
signal = imread(sprintf('%sprob80x_%d_%d.pgm', opts.datapath, solset, imgidx(1)));
signal = reshape(signal,[],1);
signal = Restriction*signal;

% Set up the operators
for i=1:8
    imgsets = zeros(m,8*n);
    for j=1:n
        img = imread(sprintf('%sprob80x_%d_%02d.pgm', opts.datapath, i, imgidx(j+1)));
        img = reshape(img,[],1);
        img = Restriction*img;
        imgsets(:,(i-1)*n+j) = img;
    end
end
B = opMatrix(imgsets);

% Set up the problem
data.signal = signal;
data.x0     = solset;
data.B      = B;
data.b      = signal;
data        = completeOps(data);

end

