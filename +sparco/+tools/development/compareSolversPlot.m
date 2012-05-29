function compareSolversPlot(problem)

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: compareSolversPlot.m 1027 2008-06-24 23:42:28Z ewout78 $

% ---------------------------------------------------------------
% Get solution path and ensure existence
% ---------------------------------------------------------------
opts = parseDefaultOpts({});
solutionpath = [opts.rootpath 'solutions' filesep];
if exist(solutionpath,'dir') == 0
   error(sprintf('Cannot access solution directory %s\n',solutionpath));
end

% ---------------------------------------------------------------
% Load solution
% ---------------------------------------------------------------
filename1 = sprintf('%ssolution%03d.mat',solutionpath,problem);
filename2 = sprintf('%scomparison%03d.mat',solutionpath,problem);
if exist(filename1,'file')==0
   fprintf(['No solution available for problem %d, run ', ...
            'generateSolution(%d) first.\n'], problem, problem);
   return
end
if exist(filename2,'file')==0
   fprintf(['No comparison available for problem %d, run ', ...
            'compareSolver(%d) first.\n'], problem, problem);
   return
end

 
% Load data
S1 = load(filename1); % Solution<problem>.mat
S2 = load(filename2); % Comparison<problem>.mat

% Get data
tau     = S1.tau;
lambda  = S1.lambda;
results = S2.results;

% Set settings
fs = 16; % Fontsize;
ms =  9; % Marker size;

% ---------------------------------------------------------------
% Figure 1
% ---------------------------------------------------------------
figure(1); clf; gca; hold on;
keys   = {'Pareto curve','GPSR','SPGL1','L1LS','L1-Magic', ...
          'PDCO'};
marker = {'r.','bo','r+','bx','r^'};
lgndkey= {};
for i=1:length(keys)
  h = -1;
  if (i==1)
    h = plot(tau,abs(S1.rNorm),'k-');
    lgndkey{end+1} = keys{i};
    set(h,'MarkerSize',ms); set(gca,'Fontsize',fs,'YScale','log');
  elseif ~isempty(results{i-1})
    h = plot(results{i-1}.xNorm,results{i-1}.rNorm,marker{i-1});
    lgndkey{end+1} = keys{i};
    set(h,'MarkerSize',ms); set(gca,'Fontsize',fs,'YScale','log');
  end
end
xlim([0,1.05*tau(end)]); ylim([0,max(S1.rNorm)*1.05]);
h = legend(lgndkey{:}); set(h,'Fontsize',fs);
hold off;

figname = sprintf('%scomparison%03da',solutionpath,problem);
printpdf(figname);


% ---------------------------------------------------------------
% Figure 2
% ---------------------------------------------------------------
figure(2); clf; gca; hold on;
lgndkey = {};
for i=2:length(keys)
  if ~isempty(results{i-1})
    h = plot(tau,results{i-1}.matvec,marker{i-1});
    lgndkey{end+1} = keys{i};
    set(h,'MarkerSize',ms); set(gca,'Fontsize',fs,'YScale','log');
  end
end
xlim([0,1.05*tau(end)]);
h = legend(lgndkey{:}); set(h,'Fontsize',fs);
hold off;

figname = sprintf('%scomparison%03db',solutionpath,problem);
printpdf(figname);

%-----------------------------------------------------------------------

function printpdf(name)
%cmd = sprintf('print -dpdf %s; !pdfcrop %s.pdf %s.pdf',name,name,name);
%eval(cmd);
