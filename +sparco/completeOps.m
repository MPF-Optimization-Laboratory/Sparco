function data = completeOps(data)
%completeOps  Completes the Sparco problem operator structure.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: completeOps.m 1677 2010-04-29 23:08:47Z mpf $

flagM = 0; if isfield(data,'M'), flagM = 1; end
flagB = 0; if isfield(data,'B'), flagB = 1; end

if ~(flagM || flagB)
   error('At least one of the operators M or B has be to given.');
end

% Define measurement matrix if needed
if ~flagM
  data.M = opDirac(data.B.m);
end

% Define sparsity basis if needed
if ~flagB
  data.B = opDirac(data.M.n);
end

% Define operator A if needed
if ~isfield(data,'A')
    data.A = data.M * data.B;
end

% Define empty solution if needed
if ~isfield(data,'x0')
  data.x0 = [];
end

% Define noise term if needed
if ~isfield(data,'r')
  data.r = zeros(size(data.b));
end


% Get the size of the desired signal
if ~isfield(data,'signalSize')
   if ~isfield(data,'signal')
     error(['At least one of the fields signal ', ...
            'or signalSize must be given.']);
   end
   data.signalSize = size(data.signal);
end

% Reconstruct signal from sparse coefficients
if ~isfield(data,'reconstruct')
   B = data.B;
   signalSize = data.signalSize;
   data.reconstruct = @(x) reshape(B*x,signalSize);
end

% Reorder the fields (sort alphabetically)
m = fieldnames(data);
m = sort(m);
dataReorder = struct();
for i=1:length(m)
   dataReorder = setfield(dataReorder,m{i},getfield(data,m{i}));
end

data = dataReorder;
