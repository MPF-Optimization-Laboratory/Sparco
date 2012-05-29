function [filename] = generatePareto(problem)
% TODO, generate solution and plot the results for illustration

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: generatePareto.m 1027 2008-06-24 23:42:28Z ewout78 $

% ---------------------------------------------------------------
% Generate problem
% ---------------------------------------------------------------
P = generateProblem(problem);
fprintf('Problem %s\n',P.info.title);


% ---------------------------------------------------------------
% Check complexity of problem
% ---------------------------------------------------------------
infoA      = P.A([],0);
iscomplex  = (infoA{3}(1) == 1) || ...
             (infoA{3}(3) == 1) || ...
             (~isreal(P.b));

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


% ---------------------------------------------------------
% Step 1. Load the BP objective value (eg, tauBP).
% ---------------------------------------------------------
fprintf('Step 1. Compute BP solution.\n');

%opts = spgSetParms('iterations',5000, ...
%                   'bpTol',     1e-6, ...
%                   'optTol',    1e-6, ...
%                   'verbosity', 1, ...
%                   'subspacemin',true);
%[xbp,r,g,info] = spgl1(data.A,data.b,0,0,[],opts);
%tauBP = norm(xbp,1);

[status,tauBP,fn] = generateBPsoln(problem);
if status ~= 0, error('Could not generate BP solution'); end;




% ---------------------------------------------------------------
% Check if solution exists and is up to date
% ---------------------------------------------------------------
filename = sprintf('%ssolution%03d.mat',  solutionpath,problem);
solnname = sprintf('%ssolutionBP%03d.mat',solutionpath,problem);
valid    = 0;

if exist(filename,'file')
   % Check modification times
   info1 = dir(filename);
   info2 = dir(solnname);
   if (info1.datenum <= info2.datenum)
      warning('Existing solution may be out of date!');
   end
   
   % Check validity of file
   S = load(filename);
   if isfield(S,'tau'  ) && isfield(S,'xNorm' ) && ...
      isfield(S,'rNorm') && isfield(S,'rGap'  ) && ... 
      isfield(S,'stat' ) && isfield(S,'lambda')
     valid = 1;
   end
end

if (valid)
   disp('Solution is up-to-date.');
   return;
end




% ---------------------------------------------------------
% Step 2. Solve problems for different tau
% ---------------------------------------------------------
n         = 50;
%tau      = [0, exp(linspace(log(1e-4),log(norm(x,1)),n-1))];
tau       = [0, linspace(1e-3,0.98*tauBP,n-1)]';
xprev     = zeros(infoA{2},1);
xNorm     = zeros(n,1);
rNorm     = zeros(n,1); rNorm(1) = norm(P.b,2);
rGap      = zeros(n,1);
stat      = 5*ones(n,1);
lambda    = zeros(n,1);
lambda(1) = norm(P.A(P.b,2),inf);
opts      = spgSetParms('iterations',20000, ...
                        'optTol',    1e-6, ...
                        'bpTol',     1e-8, ...
                        'verbosity', 0, ...
                        'iscomplex', iscomplex);

for i=2:length(tau)
   fprintf('\rStep 2. Working on problem %-2d/%2d . . .',i,n);
   [x,r,g,info] = spgl1(P.A,P.b,tau(i),[],xprev,opts);
   xprev = x;
   xNorm(i)  = norm(x,1);
   rNorm(i)  = norm(r,2);
   rGap(i)   = info.rGap;
   stat(i)   = info.stat;
   lambda(i) = info.gNorm;
   if info.stat ~= 5
      rNorm(i) = -rNorm(i);
   end
   fprintf(' stat = %d',info.stat);

   % Save data
   cmd = sprintf('save ''%s'' tau xNorm rNorm rGap stat lambda;', filename);
   eval(cmd);
end
fprintf('\nStep 2. Done.\n');

%figure(1); plot(xn(fn>0),fn(fn>0),'b.',xn(fn<0),-fn(fn<0),'r.');
%fn(fn < 0) = NaN;
%figure(1); plot(xn,fn,'b.');         % tau versus f
%figure(2); plot(lambda,fn,'b.');
