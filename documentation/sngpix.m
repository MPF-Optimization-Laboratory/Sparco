%% A Sparco Case Study: The Rice Single-Pixel Camera
% <http://www.cs.ubc.ca/~mpf/ Michael P. Friedlander>, June 2009
%
% The aim of the <http://wwww.cs.ubc.ca/labs/scl/sparco Sparco> toolbox is
% to facilitate experiments in signal reconstruction. It provides a library
% of commonly-used operators and a set of benchmark problems. In the
% example below we illustrate some of Sparco's main features on data from
% the <http://dsp.rice.edu/cscamera Rice single-pixel-camera> project.

%% Sparse representation
% At the root of compressed sensing is the assumption that the
% underlying signal can be sparsely represented in some basis. First, we
% load an image into the vector |y|.

S  = imread('ball64.png');           % Load the original signal into S
n  = size(S,1);                      % The square image is n pixels on a side
y  = double(reshape(S,n^2,1));       % Reshape image into an n^2-vector

%%
% and obtain its representation in a wavelet basis:

B  = opHaar2d(n,n);                  % Create a 2d-Haar operator for n-by-n signals
x0 = B'*y;                           % x0 contains the expansion of y in the basis

%%
% The vector |x0| contains the coefficients of the signal in the Haar basis.
% These two lines illustrate one of the core features of the Sparco
% toolbox: the Sparco function |opHaar2d| creates an n-by-n linear operator
% B, which can be used as a regular Matlab matrix. (In the case above, we
% used the adjoint of |B|.) But because |B| implements a fast operator---using
% the <http://dsp.rice.edu/software/rice-wavelet-toolbox Rice Wavelet
% Toolbox>---and not an explicit matrix, it hardly takes any space. Compare
% the Sparco operator |B| with its explicit matrix representation:

%Bmat = opToMatrix(B);                % Convert B to an explicit matrix
%whos  B  Bmat

%%
% Note that |B| is an n^2-by-n^2 matrix. 
% Here are image approximations obtained from a relateively small number of
% the leading coefficients in the wavelet basis:

[tmp,ix] = sort(abs(x0),'descend');  % Sort the coefficients by magnitude
xs = zeros(n^2,1);

% Use the first 200 and then 600 most significant coefficients
for ncoeff = [ 200, 600 ]
    xs(ix(1:ncoeff)) = x0(ix(1:ncoeff));
    ys = B*xs;
    imagesc(reshape(ys,n,n)); axis image; axis off; colormap gray
    title(sprintf('%d coefficients',ncoeff));
    snapnow;
end

%%
% Again, note how we used the operator |B| as a regular matrix in order to
% synthesize an approximate signal from the selected coefficients.

%% Fleeting glances: compressive sampling
% The single-pixel-camera experiment made "measurements" of the signal
% using a micro-mirror array that reflects random parts of the image onto a
% single photodetector. The aim is to get away with as few measurments as
% possible. We simulate a series of |m| such measurements by multiplying
% |y| by an |m|-by-|n^2| random binary matrix. In effect, the observed signal
% is
%
%    b = M y.
%
% We use the Sparco function |opBinary| to generate the required
% measurement matrix. We have two options here: one is to ask Sparco to
% generate an explicit binary matrix, and the other generates an operator
% that stores only the random seeds and applies inner products with the row
% or columns as needed; these options tradeoff speed and memory
% requirements. Here we choose the implicit version:

m = 1600;
M = opBinary(m,n^2,1);  % the 3rd argument asks for an implicit operator
b = M*y;

%% Sparco meta operators
% In order to approximate the true
% signal from the measurement vector |b|, we will apply the basis-pursuit
% approach, and solve the convex problem
%
% $$ \hbox{minimize} \quad \|x\|_1 \quad\mbox{subject to}\quad M B x = b $$
%
% We take advantage of the second important feature of Sparco
% operators that allows us to combine them to form compound operators. In
% this case, we form the compound operator
%
%    A = M B
%
% via the simple command

A = M*B

%%
% where we leave off the semicolon to print the properties of the
% newly-created operator |A|. Internally, Sparco overloads the
% multiplication symbol '*' to call the |opFOG| operator. Thus, we could
% have achieved the same result with the command
%
%   A = opFoG(M,B)
%
% Other meta operators are available. An example (not related to the
% single-pixel-camera experiment) is concatenating operators:

D = [ opDCT(

%% Sparse recovery
% We are now ready to solve the basis-pursuit problem. In this example, we
% use the <http://www.cs.ubc.ca/labs/scl/spgl1 SPGL1> solver:
opts = spgSetParms('optTol',1e-2,'verbosity',1);
xr = spg_bpdn(A,b,0,opts);
yr = B*xr;
imagesc(reshape(yr,n,n)); axis image; axis off; colormap gray
title(sprintf('%d measurements',m));

%%
% $Id: spgexamples.m 1077 2008-08-20 06:15:16Z ewout78 $

