%% Hello world, this test is to see
%% if we can do cool things

%% Generate a variable
x = linspace(0,1,100);

%% Two blocks of commands
y = x.^2;
y = y + 1;

% Another one
figure(1);
plot(x,y);
%-
a = 3; % This command is invisible
for i=1:4
  a = a + 1;
end
%+

%% Different steps with same comment
disp(a);
%
a=2;
%
a=3;
