function exSeismic
% Example illustrating how Sparco operators can be used to quickly setup and
% solve using SPGL1 a sparse recovery problem in the context of seismic data
% interpolation.  This example mimics the Sparco test problem 901.
%
% Note: this example requires the CurveLab (http://www.curvelet.org/)
% toolbox.
%
% References:
%
%   E. van den Berg and M. P. Friedlander, "In pursuit of a root", UBC
%   Computer Science Technical Report TR-2007-19, June 2007.
%
%   http://www.cs.ubc.ca/labs/scl/index.php/Main/Spgl1
%
%   F. J. Herrmann and G. Hennenfent, "Non-parametric seismic data recovery
%   with curvelet frames", UBC Earth & Ocean Science Technical report
%   TR-2007-1, January 2007.
%
%   http://slim.eos.ubc.ca/Publications/Public/Journals/CRSI.pdf
  
%   Copyright 2007, Ewout van den Berg, Michael P. Friedlander, and
%   G. Hennenfent
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: exSeismic.m 900 2008-05-06 21:06:00Z ewout78 $

pathstr = fileparts(mfilename('fullpath'));
pathstr = [pathstr filesep 'spgl1'];
addpath(pathstr);

% First check if the CurveLab MEX interface is installed.
if ~exist('fdct_wrapping_mex','file')
    error('The CurveLab MEX interfaces are not installed.')
end

% Reset random number generates.
randn('state',0); rand('state',0);

% Load seismic data 
load('seismicdata');
[n1,n2] = size(data);

% Load trace positions
load('seismicmask');

% Setup the sparse recovery problem 
M = opColumnRestrict(n1,n2,find(mask),'discard'); 
B = opCurvelet2d(n1,n2,6,32); 
A = M * B; 

rdata = data(:,find(mask)); 
b = rdata(:); 

% Set options for SPGL1 
opts = spgSetParms( 'iterations' , 100  , ... 
                    'verbosity'  , 1    , ... 
                    'bpTol'      , 1e-3 , ... 
                    'optTol'     , 1e-3   ... 
                    ); 
% Solve sparse recovery problem 
[x, r, g, info] = spgl1(A, b, 0, 0, [], opts); 

% Remove spgl1's path from path list
rmpath(pathstr);

% Construct interpolated seismic data 
res = reshape(B * x,n1,n2);

% Display the input and interpolated data
figure;
imagesc(data)
colormap gray
axis('image')
xlabel('Offset')
ylabel('Time')
caxis([-2e-3 2e-3])
title('Data with missing traces')

figure;
imagesc(res)
colormap gray
axis('image')
xlabel('Offset')
ylabel('Time')
caxis([-2e-3 2e-3])
title('Interpolated data')

end % function exSeismic
