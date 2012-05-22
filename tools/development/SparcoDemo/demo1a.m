%% In this demo we will construct a sparsity basis and a
%measurement matrix that together forms a compressed sensing
%operator. For the sparsity basis we use a dictionary consisting of
%a discrete cosine basis and a Dirac basis. For the measurement
%matrix we use a Gaussian ensemble.

%-
clear;
%+

%% Set the size of the DCT and Dirac
n = 64;

%% Construct the DCT operator and Dirac basis
D = opDCT(n);
I = opDirac(n);
% And combine them into a dictionary
B = opDictionary(D,I);

%% Let's plot sparsity basis B using opToMatrix
M = opToMatrix(B);
%-
figure(1); clf;
%+
imagesc(M);

% The image shows that indeed we have a DCT concatenated to a Dirac
% basis
