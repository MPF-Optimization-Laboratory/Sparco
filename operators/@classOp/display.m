function display(A)

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: display.m 1027 2008-06-24 23:42:28Z ewout78 $

%   Note that the getHandle is necessary to properly deal with
%   printing of an operator in its transpose mode.
fprintf('%s\n',opToString(getHandle(A)));
