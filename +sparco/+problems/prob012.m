function data = prob012(varargin)
%PROB012  Partial DCT, high dynamic-range
%
%   PROB012 creates a problem structure.  The generated signal is of
%   length N = 8192 with comprised of K = 300 nonzero entries that are
%   randomly distributed over the range [0,SCALE], where SCALE =
%   1000. The measurement matrix is a randomly-restricted DCT with M =
%   2000 rows.
%
%   PROB12('n',N,'m',M,'k',K,'scale',SCALE) is the same as above, but
%   specified by the optional paramters.  Examples: P = prob012; %
%
%   See also GENERATEPROBLEM.
%
%MATLAB SPARCO Toolbox.

% 23 Jul 09: Updated to use Spot operators.
%
%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: prob012.m 1517 2009-09-26 02:57:28Z ewout78 $

import spot.utils.* 
import sparco.*
import sparco.tools.*

% Parse parameters and set problem name
[opts,varg] = parseDefaultOpts(varargin);
[parm,varg] = parseOptions(varg,{'noseed'},{'k','m','n','scale'});
k           = getOption(parm,'k'    ,  300);
m           = getOption(parm,'m'    , 2000);
n           = getOption(parm,'n'    , 8192);
scale       = getOption(parm,'scale', 1000);
info.name   = 'dcthdr';

% Return problem name if requested
if opts.getname, data = info.name; return; end

% Initialize random number generators
rng('default'); rng(0);

% Generate signal
p     = randperm(n); p = p(1:k);
x0    = zeros(n,1);
x0(p) = sign(randn(1,k)).*exp(linspace(log(scale),log(1),k));
r     = randperm(n); r = r(1:m);

% Setup operators
D = opDCT(n);
M = D(r,:);   % Measurement operator: randomly restricted DCT

% Set up the problem
data.M      = M;
data.signal = x0;
data.x0     = x0;
data.b      = M * data.signal;
data.r      = zeros(size(data.b));
data        = completeOps(data);

% ======================================================================
% The following is self-documentation code, and is optional.
% ======================================================================

% Additional information
info.title = 'Compressible signal, restricted DCT';
info.thumb = 'figProblem012';

% Set the info field in data
data.info = info;
