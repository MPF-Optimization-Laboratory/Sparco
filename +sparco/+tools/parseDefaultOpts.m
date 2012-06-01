function [opts,args] = parseDefaultOpts(args)
%parseDefaultOpts  Parses default options for Sparco
%
%   [OPTS,ARGS] = parseDefaultOpts(ARGS) scans the argument list
%   ARGS for a number of default flags such as 'update', 'show',
%   and options, including 'problempath', 'datapath', 'linewidth',
%   'fontsize' and 'markersize'. The parameters successfully parsed
%   are stored in the OPTS structure, while the remaining parameters
%   are returned in the ARGS variables.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: parseDefaultOpts.m 1680 2010-07-08 22:54:39Z mpf $

import spot.utils.*

% Parse default option arguments
flagKeys = {'update','show','getname'};
optsKeys = {'buildpath', 'buildpathHTML', ...
            'problempath', 'datapath', ...
            'spotpath', 'docpath', 'opthumbpath', ...
            'thumbpath','thumbtype', ...
            'linewidth','fontsize','markersize', ...
            'figpath', 'figtype', 'figno','figinc'};

% Parse the arguments
if nargin == 0, args = {}; end;
[opts,args] = parseOptions(args,flagKeys,optsKeys);


% --- Plotting parameters -------------------------------------
opts.figno    = getOption(opts,'figno', 1);

if ~isfield(opts,'figinc')
  if opts.show
     opts.figinc = 1;
  else
     opts.figinc = 0;
  end
end

opts.linewidth  = getOption(opts,'linewidth', []);
opts.fontsize   = getOption(opts,'fontsize',  []);
opts.markersize = getOption(opts,'markersize',[]);


% --- Path information and file types -------------------------
pathstr = fileparts(mfilename('fullpath'));
idx  = strfind(pathstr,'+sparco');
root = pathstr(1:idx(end)-2);

opts.rootpath      = [root filesep];

defaultpath        = [opts.rootpath '+sparco' filesep '+problems' filesep];
opts.problempath   = getOption(opts,'problempath', defaultpath);
opts.problempath   = addfilesep(opts.problempath);

defaultpath        = [opts.problempath 'data' filesep];
opts.datapath      = getOption(opts,'datapath', defaultpath);
opts.datapath      = addfilesep(opts.datapath);

defaultpath        = [opts.rootpath 'build' filesep];
opts.buildpath     = getOption(opts,'buildpath', defaultpath);
opts.buildpath     = addfilesep(opts.buildpath);

defaultpath        = [opts.buildpath 'html' filesep];
opts.buildpathhtml = getOption(opts,'buildpathHTML', defaultpath);
opts.buildpathhtml = addfilesep(opts.buildpathhtml);

defaultpath        = [opts.buildpath 'thumbs' filesep];
opts.thumbpath     = getOption(opts,'thumbpath', defaultpath);
opts.thumbpath     = addfilesep(opts.thumbpath);
opts.thumbtype     = getOption(opts,'thumbtype','png');

defaultpath        = [opts.buildpath 'figures' filesep];
opts.figpath       = getOption(opts,'figpath', defaultpath);
opts.figpath       = addfilesep(opts.figpath);

defaultpath        = [opts.rootpath 'spotbox' filesep];
opts.spotpath       = getOption(opts,'spotpath', defaultpath);
opts.spotpath       = addfilesep(opts.spotpath);

defaultpath        = [opts.rootpath 'documentation' filesep];
opts.docpath       = getOption(opts,'docpath', defaultpath);
opts.docpath       = addfilesep(opts.docpath);

defaultpath        = [opts.docpath 'thumbs' filesep];
opts.opthumbpath   = getOption(opts,'opthumbpath', defaultpath);
opts.opthumbpath   = addfilesep(opts.opthumbpath);


% Parse figtype and ensure is a cell array of types
opts.figtype = getOption(opts,'figtype', {'png'});
if ischar(opts.figtype)
  opts.figtype = {opts.figtype};
end



function pathstr = addfilesep(pathstr)

if pathstr(end) ~= filesep
  pathstr(end+1) = filesep;
end

