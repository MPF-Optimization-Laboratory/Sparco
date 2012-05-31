function thumbwrite(data,name,opts)

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: thumbwrite.m 1027 2008-06-24 23:42:28Z ewout78 $

%
% data       Thumbnail data in range 0-1
% name       Name of file (no extension)
% opts
%   .thumbtype  Type of image (png, eps, ps, ...)
%   .thumbdir   Output directory
%

import sparco.tools.*

[type,ext] = getFigureExt(opts.thumbtype);
data = round(data * 255) / 255;
imwrite(data,[opts.thumbpath,name,'.',ext],type);
