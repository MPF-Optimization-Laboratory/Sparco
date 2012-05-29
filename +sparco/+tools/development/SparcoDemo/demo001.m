%% Sparco test problems are instantiated using the generateProblem
%% function. This command returns a problem structure containing all
%% relevant information.


P = generateProblem(5);

% Sometimes it is more convenient to remember the problem name
% rather than its number. Therefore we can equivalently instantiate
% problem 5 by its name 'gcosspike'

P = generateProblem('gcosspike');

% The next command will show the contents of structure P. The
% output will appear in the main window

%-
fprintf('\n\n\n');
disp('--------------------------------------------------------------');
%+
disp(P);
%-
disp('--------------------------------------------------------------');
%+

%% Each Sparco problem consists of an observation vector b which is
%% formed by applying measurement matrix M on a signal that has a
%% sparse representation in sparsity basis B:
%%  
%%      b = M*y
%%  
%% or
%%  
%%      b = M*B*x0 = A*x0
%%  
%% where x0 is a sparse vector. By convention A is defined as M*B.
%% For some problems noise is added to the observation b to make
%% the scenario more realistic.
%%  
%% We can access these vectors and operators using the following
%% commands. For more information on the use of operators, see the
%% Sparco operator demo.

b = P.b;

%

A = P.A;
B = P.B;
M = P.B;

%% The 'info' field provides additional information about the problem.

ID          = P.info.sparcoID;
name        = P.info.name;
description = P.info.title;

%% The 'op' field contains the operators used to construct the
%% sparsity basis and measurement operator. In addition it contains
%% a string representation of the three main operators A, B and M.
%% (See output in main window)

%-
fprintf('\n\n\n');
disp('--------------------------------------------------------------');
%+
disp(P.op);
%-
disp('--------------------------------------------------------------');
%+

% The string representation for operator B
%  
%   'Dictionary(DCT, Dirac)'
%  
% shows that B in this case consists of a DCT-Dirac dictionary. The
% operators used to construct the dictionary are stored in the DCT
% and Diract fields of P.op.

%% When benchmarking a solver it is convenient to have access to
%% the complete list of problems. This list can be generated using
%% the 'list' option in the generateProblem function

list = generateProblem('list');

% This list contains the problem numbers of all known problems.
% When documenting the results of a solver on a certain problem it
% is better to use the problem name rather than its number. One way
% to get the name is by instantiating the problem and looking at
% the info.name field. Alternatively the name can be queried using
% the generateProblem function with the 'getname' flag.

name = generateProblem(5,'getname');

% Vice versa, given the name, the problem number can be found by
% instantiating the problem and looking at the info.sparcoID field
% or using the 'lookup' flag:

id = generateProblem('gcosspike','lookup');

%% The following loop displays the name for each problem in the
%% list we created in the previous slide.
%% (See output in main window)

%-
fprintf('\n\n\n');
disp('--------------------------------------------------------------');
%+
for i=1:length(list)
   name = generateProblem(list(i),'getname');
   fprintf('%3d. %s\n', list(i), name);
end
%-
disp('--------------------------------------------------------------');
%+
