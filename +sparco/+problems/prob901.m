function data = prob901(varargin)
%PROB901  Curvelet basis, seismic image with missing traces.
%
%   PROB901 creates a problem structure.  The generated signal will
%   consist of a 250 seismic traces of length 256 combined into an
%   image of size 256 by 250. In the observed signal, a fraction
%   P = 0.35 of the traces are missing.
%
%   The following optional arguments are supported:
%
%   PROB901('p',P,flags) is the same as above, with with a fraction
%   P of all traces missing. The 'noseed' flag can be specified to
%   suppress initialization of the random number generators. Both
%   the parameter pair and flags can be omitted.
%
%   Examples:
%   P = prob901;  % Creates the default 901 problem.
%
%   References:
%
%   [HennHerr:2005] G. Hennenfent and F.J. Herrmann,
%     Sparseness-constrained data continuation with frames:
%     Applications to missing traces and aliased  signals in 2/3-D,
%     Proceedings of the SEG International Exposition and 75th
%     Annual Meeting, 2005.
%
%   [HennHerr:2006] G. Hennenfent and F.J. Herrmann, Application of
%     stable signal recovery to seismic interpolation, Proceedings
%     of the SEG International Exposition and 76th Annual Meeting,
%     2006.
%
%   See also GENERATEPROBLEM.
%
%MATLAB SPARCO Toolbox.

% 8 Sep 09: Updated to use Spot operators.
%
%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: prob901.m 1679 2010-04-29 23:26:14Z mpf $

import spot.utils.* 
import sparco.*
import sparco.tools.*

% Parse parameters and set problem name
[opts,varg] = parseDefaultOpts(varargin);
[parm,varg] = parseOptions(varg,{'noseed'},{'p'});
p           = getOption(parm,'p',0.35);
info.name   = 'seismic';

% Return problem name if requested
if opts.getname, data = info.name; return; end;

% Initialize random number generators
if (~parm.noseed), rng('default'); rng(0); end;

% Set up the data
x = load(sprintf('%sprob901_seismic.mat', opts.datapath));
m = size(x.model2d,1);
n = size(x.model2d,2);
k = round(p * n);

% Set up operators
mask = (randperm(n) > k);
M    = sparcoColumnRestrict(m,n,find(mask),'discard');
B    = opCurvelet(m,n)' ;

% Set up the problem
data.signal = x.model2d;
data.mask   = mask;
data.M      = M;
data.B      = B;
data.b      = M * reshape(data.signal,m*n,1);
data.r      = zeros(size(data.b));
data        = completeOps(data);


% ======================================================================
% The following is self-documentation code, and is optional.
% ======================================================================

% Additional information
info.title           = 'Seismic data with missing traces';
info.thumb           = 'figProblem901';
info.citations       = {'HennHerr:2005,HennHerr:2006,HerrHenn:2007a'};
info.fig{1}.title    = 'Complete seismic data';
info.fig{1}.filename = 'figProblem901Seismic';
info.fig{2}.title    = 'Seismic data with traces missing';
info.fig{2}.filename = 'figProblem901Partial';

% Set the info field in data
data.info = info;

% Plot figures
if opts.update || opts.show
  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  signal = data.signal - min(min(data.signal));
  signal = signal / max(max(signal));
  clr = min([linspace(2,0,64)' , ...
             min(linspace(2,0,64)',linspace(0,2,64)'), ...
             linspace(0,2,64)'],1);
  image(signal * 64), colormap(clr);
  updateFigure(opts, info.fig{1}.title, info.fig{1}.filename)

  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  P = max(0,min(1,signal)) * 64;
  P(:,find(data.mask==0)) = 65;
  image(P), colormap([clr; 0.92 0.92 0.95]);
  updateFigure(opts, info.fig{2}.title, info.fig{2}.filename)
  
  if opts.update
     P = scaleImage(signal,128,128);
     P = scalarToRGB(P,clr);
     P = P(1:2:end,1:2:end,:);
     thumbwrite(P, info.thumb, opts);
  end
end
