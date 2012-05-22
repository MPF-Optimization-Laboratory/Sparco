function [status, tau, filename] = generateBPsoln(problem,varargin)
% Generate BP solution
%
%   [STATUS,TAU,FILENAME] = GENERATEBPSOLN(PROBLEM,FLAGS) generates
%   the BP solution for the problem indicated by PROBLEM. FLAGS can
%   be one of the following options:
%      'continue' - Continue running a problem when status
%                   indicates the BP solution was not found 
%      'force'    - Force the solution to be regenerated even if it
%                   is up to date 
%      'query'    - Only check the status
%      'quiet'    - Do not output any progress information
%
%   The STATUS value has the following interpretation
%       0         - TAU is correct
%      -1         - The solution has not yet been reached, TAU is
%                   only an intermediate (approximate) value
%      -2         - No solution information exists
%
%   FILENAME contains the filename where the solution is stored or
%   will be stored.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: generateBPsoln.m 1027 2008-06-24 23:42:28Z ewout78 $


% ---------------------------------------------------------------
% Parse arguments
% ---------------------------------------------------------------
[flags,varargin]= parseOptions(varargin,{'continue','force','query','quiet'},{});

% ---------------------------------------------------------------
% Generate problem
% ---------------------------------------------------------------
if nargin >= 1  &&  isscalar(problem)
   P = generateProblem(problem);
else
   error('Parameter problem has to be a scalar');
end


% ---------------------------------------------------------------
% Get solution path and ensure existence
% ---------------------------------------------------------------
opts = parseDefaultOpts({});
solutionpath = [opts.rootpath 'solutions' filesep];
[success,msg,msgid] = mkdir(solutionpath);
if (success ~= 1)
   error(sprintf('Could not generate solution directory %s\n', ...
                 solutionpath));
end


% ---------------------------------------------------------------
% Check if solution exists and is up to date
% ---------------------------------------------------------------
filename = sprintf('%ssolutionBP%03d.mat',solutionpath,problem);
probname = sprintf('%sprob%03d.m', opts.problempath,problem);
valid    = 0;

if exist(filename,'file')
   % Check modification times
   info1 = dir(filename);
   info2 = dir(probname);
   if (info1.datenum <= info2.datenum) && (~flags.force)
      warning('Existing solution may be out of date!');
   end
   
   % Check validity of file
   S = load(filename);
   if isfield(S,'tauHist' ) && isfield(S,'rNormHist') && ...
      isfield(S,'rGapHist') && isfield(S,'gNormHist') && ...
      isfield(S,'statHist') && isfield(S,'iterHist' ) && ...
      isfield(S,'status'  )
     valid = 1;
   end
end

if flags.query
   status = -2; tau = NaN;
   if (valid)
     status = S.status;
     tau    = S.tauHist(end);
   end
   return;
end

if (valid) && (~flags.force) && ((S.status == 0) || (~flags.continue))
   status = S.status;
   tau    = S.tauHist(end);
   return;
end


% ---------------------------------------------------------------
% Check complexity of problem and display problem information
% ---------------------------------------------------------------
info      = P.A([],0);
iscomplex = (info{3}(1) == 1) || ...
            (info{3}(3) == 1) || ...
            (~isreal(P.b));

str = 'real'; if (iscomplex), str = 'complex'; end;
str = sprintf('Problem %03d - %s; %d x %d (%s)', ...
              problem, P.info.title, info{1}, info{2}, str);
if (~flags.quiet)
   fprintf('%s\n',repmat('-',1,length(str)));
   fprintf('%s\n',str);
   fprintf('%s\n',repmat('-',1,length(str)));
end


% ---------------------------------------------------------------
% Apply Newton root finding on the Pareto curve
% ---------------------------------------------------------------

xOld = zeros(info{2},1);
opts = spgSetParms('iterations',  500,  ...
                   'optTol',      1e-5, ...
                   'bpTol',       1e-7, ...
                   'verbosity',   0,    ...
                   'subspaceMin', 1,    ...
                   'iscomplex',   iscomplex);

if (valid) && (flags.continue) && (S.status == -1)
   if isfield(S,'xResume'), xOld = S.xResume; end
   tau       = S.tauHist(end) + S.rNormHist(end).^2 / S.gNormHist(end);
   tauHist   = S.tauHist;
   rNormHist = S.rNormHist;
   gNormHist = S.gNormHist;
   rGapHist  = S.rGapHist;
   statHist  = S.statHist;
   iterHist  = S.iterHist;
   sigmaOld  = S.rNormHist(end);
else
   tau       = 0;
   tauHist   = [];
   rNormHist = [];
   gNormHist = [];
   rGapHist  = [];
   statHist  = [];
   iterHist  = [];
   sigmaOld  = NaN;
end

status = -1;

for j=1:30 % Maximum number Newton iterations

   % -------------------------------------------
   % Solve LASSO(tau) subproblem
   % -------------------------------------------
   x = xOld;
   if (~flags.quiet)
      fprintf('Tau = %16.10e .',tau);
   end;
   for i=1:40 % Maximum 40x500 = 20,000 iterations
      [x,r,g,info] = spgl1(P.A,P.b, tau,[],x, opts);
      if (~flags.quiet), fprintf('.'); end;
      if (info.stat ~= 1), break; end;
   end
   if (~flags.quiet)
      fprintf('%s',repmat('.',1,40-i));
      fprintf(' Sigma = %16.10e (%d)\n',info.rNorm,info.stat);
   end
 
   % -------------------------------------------
   % Store current values
   % -------------------------------------------
   tauHist(end+1)   = tau;
   iterHist(end+1)  = (i-1)*opts.iterations + info.iter;
   rNormHist(end+1) = info.rNorm;
   gNormHist(end+1) = info.gNorm;
   rGapHist(end+1)  = info.rGap;
   statHist(end+1)  = info.stat;

   % -------------------------------------------
   % Update tau
   % -------------------------------------------
   xOld = x;
   if (info.rNorm > 1e-5)
      tau = tau + info.rNorm.^2 / info.gNorm;
   else
      status = 0; break;
   end;

   % Quit if sigma does not make much progress
   if ((sigmaOld - info.rNorm) / info.rNorm) < 1e-3
      status = 0; break;
   else
      sigmaOld = info.rNorm;
   end;
end


% ---------------------------------------------------------------
% Write results to file
% ---------------------------------------------------------------
variables = ['tauHist rNormHist rGapHist gNormHist statHist ' ...
             'iterHist status'];
if status == -1
  xResume      = x;
  variables   = [variables ' xResume'];
end

cmd = sprintf('save %s %s;', filename, variables);
eval(cmd);
