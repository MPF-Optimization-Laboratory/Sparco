function compareSolvers(problem)
%COMPARESOLVERS  Compare various L1 solvers on a given problem.
    
%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: compareSolvers.m 1027 2008-06-24 23:42:28Z ewout78 $

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
% Load solution
% ---------------------------------------------------------------
S = load(sprintf('%ssolution%03d.mat',solutionpath,problem));
tau    = S.tau;
lambda = S.lambda;
nTau   = length(tau);


% ---------------------------------------------------------------
% Generate problem and check complexity
% ---------------------------------------------------------------
P = generateProblem(problem);
infoA      = P.A([],0);
iscomplex  = (infoA{3}(1) == 1) || ...
             (infoA{3}(3) == 1) || ...
             (~isreal(P.b));
m = infoA{1}; n = infoA{2};


% Generate operators and define mat-vec counters.
nAx  = 0;
nATx = 0;
cA   = classOp(P.A,'matvec');
cAT  = cA';
fA   = @(x) (cA * x);
fAT  = @(x) (cAT * x);
sA   = @(mode,m,n,x,idx,dim) sparselabOp(P.A,mode,m,n,x,idx,dim);
opA  = @(x,mode) opMatvec(P.A,x,mode);

% -----------------------------------
% GPSR
% -----------------------------------
result.rNorm  = zeros(nTau,1);
result.xNorm  = zeros(nTau,1);
result.gNorm  = zeros(nTau,1);
result.matvec = zeros(nTau,1);
for i=1:nTau
   fprintf('\rProblem: %-2d/%2d, solver: GPSR', i,nTau);
   resetMatvec();
   args = {P.b,fA,lambda(i),'AT',fAT,'Verbose',0};
   [log,x, x_debias, obj] = evalc('GPSR_BB(args{:});');
   r =  P.b - P.A(x,1);
   g = -P.A(r,2);
   result.rNorm(i) = norm(r,2);
   result.xNorm(i) = norm(x,1);
   result.gNorm(i) = norm(g,inf);
   result.matvec(i)= evalin('base','sum(matvec)');
end
results{1} = result; clear result;

% -----------------------------------
% SPGL1
% -----------------------------------
result.rNorm  = zeros(nTau,1);
result.xNorm  = zeros(nTau,1);
result.gNorm  = zeros(nTau,1);
result.matvec = zeros(nTau,1);
opts = spgSetParms('verbosity',0);
for i=1:nTau
   fprintf('\rProblem: %2d/%d, solver: SPGL1',i,nTau);
   resetMatvec();
   [x,r,g,sinfo] = spgl1(opA,P.b,tau(i),[],[],opts);
   result.rNorm(i) = norm(P.b - P.A(x,1),2);
   result.xNorm(i) = norm(x,1);
   result.matvec(i)= nAx + nATx;
end
results{2} = result; clear result;


% -----------------------------------
% L1_LS
% -----------------------------------
result.rNorm  = zeros(nTau,1);
result.xNorm  = zeros(nTau,1);
result.gNorm  = zeros(nTau,1);
result.matvec = zeros(nTau,1);
for i=1:nTau
   fprintf('\rProblem: %2d/%d, solver: L1_LS',i,nTau);
   resetMatvec();
   % l1_ls defaults: optTol = 1e-3.
   [x,status,history] = l1_ls(cA,cAT,...
                              m,n,P.b,2*lambda(i),1e-3,1);
   result.rNorm(i) = norm(P.b - P.A(x,1),2);
   result.xNorm(i) = norm(x,1);
   result.matvec(i)= evalin('base','sum(matvec)');
end
results{3} = result; clear result;

% -----------------------------------
% L1-Magic
% -----------------------------------
%{
result.rNorm  = zeros(nTau,1);
result.xNorm  = zeros(nTau,1);
result.gNorm  = zeros(nTau,1);
result.matvec = zeros(nTau,1);
for i=1:nTau
   fprintf('\rProblem: %2d/%d, solver: L1-magic',i,nTau);
   resetMatvec();
   x0 = fAT(P.b);
   args = {x0,fA,fAT,P.b, S.fn(i)};
   [log,x] = evalc('l1qc_logbarrier(args{:});');
   result.rNorm(i) = norm(P.b - P.A(x,1),2);
   result.xNorm(i) = norm(x,1);
   result.matvec(i)= nAx + nATx;
end
results{4} = result; clear result;
%}

% -----------------------------------
% Sparselab
% -----------------------------------
result.rNorm  = zeros(nTau,1);
result.xNorm  = zeros(nTau,1);
result.gNorm  = zeros(nTau,1);
result.matvec = zeros(nTau,1);
for i=1:nTau
   fprintf('\rProblem: %2d/%d, solver: Sparselab', i,nTau);
   resetMatvec();
   args = {sA,P.b,n,20,lambda(i)};
   [log,x] = evalc('SolveBP(args{:});');
   result.rNorm(i) = norm(P.b - P.A(x,1),2);
   result.xNorm(i) = norm(x,1);
   result.matvec(i)= nAx + nATx;
end
results{5} = result; clear result;

% -----------------------------------
% SPGL1
% -----------------------------------
%{
result.rNorm = zeros(length(tau),1);
result.xNorm = zeros(length(tau),1);
result.gNorm = zeros(length(tau),1);
opts = spgSetParms('verbosity',0,'SubspaceMin',1);
for i=1:length(tau)
   fprintf('\rProblem: %2d/%d, solver: SPGL1 Subspace',i,length(tau));
   resetMatvec();
   [x,r,g,sinfo] = spgl1(opA,P.b,tau(i),[],[],opts);
   result.rNorm(i) = norm(P.b - P.A(x,1),2);
   result.xNorm(i) = norm(x,1);
   result.matvec(i)= nAx + nATx;
end
results{6} = result; clear result;
%}

filename = sprintf('comparison%03d.mat',problem);
fprintf('\rDone, results stored in %s%*s\n', ...
        filename, max(0,40-length(filename)),'');

cmd = sprintf('save %s%s results;', solutionpath,filename);
eval(cmd);


%-----------------------------------------------------------------------
% Nested functions.
%-----------------------------------------------------------------------

function resetMatvec()
   nAx  = 0;
   nATx = 0;
   evalin('base','matvec = [0,0];');
   evalin('base','matvec = [0,0];');
end
   
function y = funMatvecA(op,x)
   nAx = nAx + 1;
   y   = op(x,1);
end
   
function y = funMatvecAT(op,x)
   nATx = nATx + 1;
   y    = op(x,2);
end
   
function y = opMatvec(op,x,mode)
   if mode == 1
     nAx  = nAx  + 1;
   else
     nATx = nATx + 1;
   end
   y = op(x,mode);
end
   
function y = sparselabOp(op,mode,m,n,x,idx,dim)
  if mode == 1
    z = zeros(n,1);
    z(idx) = x;
    y = funMatvecA(op,z);
  else
    z = funMatvecAT(op,x);
    y = z(idx);
  end
end

%-----------------------------------------------------------------------

end % function compareSolvers
