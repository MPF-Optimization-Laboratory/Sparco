function exSPC(varargin)
%EXSPC  Single-pixel camera experiment.
%
%   Reference:
%
%   [TakhLaskWakiEtAl:2006] D. Takhar and J. N. Laska and M. Wakin
%     and M. Duarte and D. Baron and S. Sarvotham and K. K. Kelly
%     and R. G. Baraniuk, A new camera architecture based on
%     optical-domain compression, in Proceedings of the IS&T/SPIE
%     Symposium on Electronic Imaging: Computational Imaging,
%     January 2006, Vol. 6065.
%
%   See also PROB602.
%
%MATLAB SPARCO Toolbox.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: prob601.m 1027 2008-06-24 23:42:28Z ewout78 $

%nobs = [1600 2400 3200];
nobs = [3200];

opts = spgSetParms('optTol',1e-2,'bpTol',1e-2,'decTol',1e-3,'subspacemin',0);

for i = 1:length(nobs);
    m = nobs(i);
    P = sparco.problems.prob602('m',m);
    A = P.A;
    b = P.b;
    
    fname = sprintf('snglix%03i',m);
    if exist([fname,'.mat'],'file');
       sdata = load(fname);
       x = sdata.x;
    else
       x = spgl1(A,b,[],0,[],opts);
       %x = as_topy(A,b);
       save(fname,'x');
    end
    
    y0 = P.signal;           % the original signal
    y  = P.reconstruct(x);   % reconstruct the signal from coefficients

    % Plot new figure
    subplot(1,length(nobs),i);
    imagesc(y); colormap gray; axis image; axis off;
    title({sprintf('No. observations: %i\n',m),...
           sprintf('pSNR = %5.1f dB',psnr(y0,y))});
end
    
function d = psnr(a,b)
% Compute the peak signal-to-noise ratio (dB) between two images
a = a / max(max(a)); % Normalize images to [0,1] interval
b = b / max(max(b));
c = a - b;           % the error
d = 20*log10(1/(sqrt(mean(mean(c.^2)))));
