function generateHTML(baseurl, varargin)
%

% NOTE: Nested block diag operators will not output properly
%       (because of additional space HTML interpreters put
%        around tables).

% Set default data or document directory
wikipage      = 'http://www.cs.ubc.ca/labs/scl/sparco/index.php/Main/';
opts         = parseDefaultOpts(varargin{:});
opts.baseurl = baseurl;
builddir     = opts.buildpathhtml;
[thumbtype, thumbext] = getFigureExt(opts.thumbtype);

problems = generateProblem('list');

% Open file
fd = fopen([builddir, 'problems.html'],'w');
if fd == -1
   error(['Error opening file ', builddir, 'index.html'])
end

% Output header
fprintf(fd,'<HTML>\n');
fprintf(fd,'<Title>Sparco Test Suite</Title>\n');
fprintf(fd,'<Body>\n');


% --- Output introduction ----------------------------------------------
%fprintf(fd,'<H2>SPARCO: Sparse reconstruction toolbox</H2>\n');
%fprintf(fd,['Sparco is a test problem suite and operator library ' ...
%            'for sparse reconstruction.' ...
%            '<BR>Information about the operators ' ...
%            'can be found <A HREF="operators.html">here</A>.  The ' ...
%            'test problem are below.<BR>Click on each thumbnail to ' ...
%            'view more information about that problem.\n']);

% --- Output problems --------------------------------------------------
%fprintf(fd,'<H2>Problems</H2>\n');

% Output table header
fprintf(fd,'<Table cellspacing=0>\n');

% Set the number of columns
clm = 1;

% Output selected test problems
for i=1:length(problems)
   % Compute index for column major indexing
   npr = ceil(length(problems) / clm);
   idx = floor((i-1)/clm) + mod(i-1,clm)*npr + 1;
   idx = i; % Use row major indexing for now

   data    = generateProblem(problems(idx));
   info    = data.info;
   opinfo  = data.A([],0);
   indent  = 4;
   

   fprintf('Working on %-50s\r', info.title);
   
   % Generate the problem detail webpage
   idxprev = NaN; idxnext = NaN;
   if idx ~= 1, idxprev = problems(idx-1); end;
   if idx ~= length(problems), idxnext = problems(idx+1); end;
   
   log = outputProblemHTML(problems(idx),idxprev,idxnext,data,info,builddir,opts);

   
   % Background color in main page
   bgcolor = '"#FFFFE0"';
   if mod(ceil(i/clm),2), bgcolor = '"#E0E0FF"'; end

   % Begin row
   if mod(i,clm) <= 1, fprintf(fd,'<Tr>\n'); end
   
   
   fprintf(fd,'   <Td bgcolor=%s valign="top">',bgcolor);
   if isfield(info,'thumb')
     fprintf(fd,'<A HREF="problem%03d.html" border=0><Img border=0 src="%s"></A>',...
                problems(idx),[opts.thumbpath, info.thumb '.' thumbtype]);
     % opts.baseurl
   end
   fprintf(fd,'<BR><Font size=-2 color="#606060">%d x %d</Font>', opinfo{1}, opinfo{2});
   fprintf(fd,'</Td>\n    <Td valign="top" bgcolor=%s>',bgcolor); % width = 47%%
   
   if ~isfield(info,'title'), info.title = ''; end;
   if ~isfield(info,'name'),  info.name  = ''; end;
   fprintf(fd,'<B>%d. %s - %s</B></A><BR>\n',problems(idx),info.name,info.title);
  
   % Output citations
   if (isfield(info,'citations')) && (length(info.citations) > 0)

      % Load the generated bibliography data
      %cmd = sprintf('!cat %sliterature.html', builddir);
      %[log] = evalc(cmd);
      
      % Add font size
      log = strrep(log,'<td>','<td><font size=-3>');
      log = strrep(log,'<td align="right">','<td align="left"><font size=-3>');
      log = strrep(log,'</td>','</font></td>');
      log = strrep(log,builddir,'');
       fprintf(fd,'<B><FONT size=-3>%s</FONT>\n', log);
   end

   fprintf(fd,'    </Td>\n');
   
   % End row
   if (mod(i,clm)+1 == clm) || (i == length(problems))
     fprintf(fd,'</TR>\n');
   end
   
end

% Output table footer
fprintf(fd,'</Table>\n');

% Output footer
fprintf(fd,['<Font size=-3>', ...
            '(Last updated: %s), ', ...
            'Copyright 2007, University of British Columbia</Font>\n'],date);
fprintf(fd,'</Body>\n</HTML>\n');

% Close file
fclose(fd);

fprintf('%65s\r','');


% Create bibliograph info
cmd = sprintf(['!bibtex2html -o %sliterature -s plain ', ...
               '-nofooter -noheader %sliterature.bib'], ...
              builddir, opts.rootpath);
[log] = evalc(cmd);

% Remove builddir prefix in references (literature.html)
[log] = evalc(sprintf('!cat %sliterature.html',builddir));
p   = getAbsolutePath(builddir);
log = processBibliography(log, [p 'literature_bib.html'], ... 
                               [wikipage 'bibtex'], 0);

log = strrep(log,'<td align="right">','<td align="left">');
fd = fopen(sprintf('%sliterature.html',builddir),'w');
fprintf(fd,'%s',log);
fclose(fd);

% Remove builddir prefix in references (literature_bib.html)
[log] = evalc(sprintf('!cat %sliterature_bib.html',builddir));
log   = strrep(log,'<h1>literature.bib</h1>','');
p     = getAbsolutePath(builddir);
log   = processBibliography(log, [p 'literature.html'], ... 
                                 [wikipage 'References'], 0);
fd = fopen(sprintf('%sliterature_bib.html',builddir),'w');
fprintf(fd,'%s',log);
fclose(fd);

 


% Output operator webpage
outputOperatorHTML(builddir, opts);


% Set ownership flags
cmd = sprintf('!chgrp -R sclweb %s', builddir);
[log] = evalc(cmd);






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function log = outputProblemHTML(idx,idxprev,idxnext,data,info,builddir,opts)

% Open file
fd = fopen(sprintf('%sproblem%03d.html',builddir,idx),'w');
if (fd == -1)
  error(sprintf('Error opening file %sproblem%d.html', builddir, idx));
end

% Set location of wiki and web page 
wikipage = 'http://www.cs.ubc.ca/labs/scl/sparco/index.php/Main/';
webpage  = 'http://www.cs.ubc.ca/labs/scl/sparco/uploads/Main/';

% Output header
fprintf(fd,'<HTML>\n');
fprintf(fd,'<Title>Compressed Sensing Suite - Problem %d</Title>\n', ...
        idx);
fprintf(fd,'<Body>\n');
fprintf(fd,'<HR>\n');        

% ======================================================================
%                     D O C U M E N T   B O D Y 
% ======================================================================

% Output title
fprintf(fd,'<H2>%d. %s - %s</H2>\n',idx,info.name,info.title);

% Output operator
fprintf(fd,'<TABLE><TR>\n');
%optdir = relativepath(opts.opthumbpath,builddir);
optdir = [webpage 'figs/'];
log    = '';

[strm,rm,cm] = outputOperator(data.M,optdir);
[strb,rb,cb] = outputOperator(data.B,optdir);
fprintf(fd,'%s%s', strm, strb);
fprintf(fd,'    </TR>\n');
fprintf(fd,['<TR><TD Bgcolor=#E0FFE8 Colspan=%d Align=center>' ...
            'Measurement</TD>'],cm);
fprintf(fd,'<TD Bgcolor=#E0E0FF Colspan=%d Align=center>Sparsity</TD></TR></TABLE><BR>\n',cb);

% Back to index
fprintf(fd,'<FONT color=#A0A0A0>(');
fprintf(fd,'<A HREF="problems.html">Back to index</A>');
if ~isnan(idxprev)
   fprintf(fd,'&nbsp;|&nbsp;<A HREF="problem%03d.html">prev</A>',idxprev);
else
   fprintf(fd,'&nbsp;|&nbsp;prev');
end     
if ~isnan(idxnext)
   fprintf(fd,'&nbsp;|&nbsp;<A HREF="problem%03d.html">next</A>',idxnext);
else
   fprintf(fd,'&nbsp;|&nbsp;next');
end
fprintf(fd,')</FONT><BR><HR>\n');

% Output list of figures
if isfield(info,'fig')
   fprintf(fd,'<H3>List of Figures</H3>\n');
   fprintf(fd,'<UL>\n');
   for i=1:length(info.fig)
      fprintf(fd,'<LI><!A HREF="problem%d.html#fig%d">%s<!/A>\n', ...
              idx,i,info.fig{i}.title);
   end
   fprintf(fd,'</UL>\n\n');
end

% Output list of tables
if isfield(info,'tab')
   fprintf(fd,'<H3>List of Tables</H3>\n');
   fprintf(fd,'<UL>\n');
   for i=1:length(info.tab)
      fprintf(fd,'<LI><!A HREF="problem%d.html#tab%d">%s<!/A>\n', ...
              idx,i,info.tab{i}.title);
   end
   fprintf(fd,'</UL>\n\n');
end

% Output list of citations
if isfield(info,'citations') && (length(info.citations) > 0)
     fprintf(fd,'<H3>Bibliography</H3>\n');

    % Generate file with keys
    keys = '';
    for j=1:length(info.citations)
      keys = [keys ' ' info.citations{j}];
    end
    cmd = sprintf('!echo %s > %sbibkeys',keys, builddir);
    [log] = evalc(cmd);
    
    % Generate bibliograpy file using bibtex2html
    cmd = sprintf(['!bibtex2html -o %sliterature -s plain ',...
                   '-nodoc -nofooter -noheader -citefile %sbibkeys ',...
                   '%sliterature.bib'], builddir, builddir, opts.rootpath);
    [log] = evalc(cmd);

    % Load the generated data
    cmd = sprintf('!cat %sliterature.html', builddir);
    [log] = evalc(cmd);
    p   = getAbsolutePath(builddir);
    log = processBibliography(log, [p 'literature_bib.html'], ... 
                                   [wikipage 'Bibtex'], 0);
 
    fprintf(fd,'%s\n\n', log);
end

% Output figures
if isfield(info,'fig')
%   figdir = relativepath(opts.figpath,builddir);
    figdir = 'figs/';

   fprintf(fd,'<H3>Figures</H3>\n');
   fprintf(fd,'<TABLE>\n');
   for i=1:length(info.fig)
      % Start row
      if mod(i,2), fprintf(fd,'<TR>\n'); end;
      
      fprintf(fd,'   <TD>');
      fprintf(fd,'<B>Figure %d</B> - %s.<BR>\n', i,info.fig{i}.title);
      fprintf(fd,'       <IMG width=518 SRC="%s%s%s.png"></TD>\n', ...
              webpage,figdir,info.fig{i}.filename);
      
      % End row
      if mod(i+1,2) || i==length(info.fig), fprintf(fd,'</TR>\n'); end;
   end
   fprintf(fd,'</TABLE>\n');
end

% Output tables
if isfield(info,'tab')
  fprintf(fd,'<H3>Tables</H3>\n');
  for i=1:length(info.tab)

    fprintf(fd,'<B>Table %d</B> - %s.<BR>\n', i,info.tab{i}.title);
    fprintf(fd,'<TABLE BORDER=1>\n');
    for r=1:size(info.tab{i}.celldata,1)
      fprintf(fd,'   <TR>\n');
      for c=1:size(info.tab{i}.celldata,2)
        fprintf(fd,'      <TD>%s</TD>\n',info.tab{i}.celldata{r,c});
      end
      fprintf(fd,'   </TR>\n');
    end
    fprintf(fd,'</TABLE><BR>\n');
  end
end

% ======================================================================

% Output footer
if isfield(info,'fig') || isfield(info,'tab')
   fprintf(fd,['<Font size=-3>', ...
               '(Last updated: %s), ', ...
               'Copyright 2007, University of British Columbia' ...
               '<Font>\n'],date);
end
fprintf(fd,'</Body>\n</HTML>\n');

% Close file
fclose(fd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COUNTER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function outputCounter(fd)
   fprintf(fd,'<!-- Start of StatCounter Code -->\n');
   fprintf(fd,'<script type="text/javascript">\n');
   fprintf(fd,'var sc_project=3102994;\n');
   fprintf(fd,'var sc_invisible=0;\n');
   fprintf(fd,'var sc_partition=33;\n');
   fprintf(fd,'var sc_security="8cad4258";\n');
   fprintf(fd,'</script>\n');
   fprintf(fd,'<script type="text/javascript" src="http://www.statcounter.com/counter/counter_xhtml.js">\n');
   fprintf(fd,'</script>\n');
   fprintf(fd,'<noscript><div class="statcounter">\n');
   fprintf(fd,'<a class="statcounter" href="http://www.statcounter.com/">\n');
   fprintf(fd,'<img class="statcounter" src="http://c34.statcounter.com/3102994/0/8cad4258/0/" alt="hit counter script" />\n');
   fprintf(fd,'</a></div></noscript>\n');
   fprintf(fd,'<!-- End of StatCounter Code -->\n');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [str,rows,cols] = outputOperator(op,relpath)
info = op([],0);
type = info{4};
str  = '';
cols = 0;
rows = 0;

switch type{1}
   case {'Dictionary'}
      str = sprintf('<TD><IMG SRC="%smiscLBracket.png" Border=0></TD>', relpath);
      
      oplist = type{2};
      for i=1:length(oplist)
         if i~=1, str = [str sprintf('<TD>,</TD>')]; end
         [s,r,c] = outputOperator(oplist{i},relpath);
         str  = [str s];
         cols = cols + c;
         rows = max(rows,r);
      end

      str = [str sprintf('<TD><IMG SRC="%smiscRBracket.png" Border=0></TD>', relpath)];
      
      cols = cols + (length(oplist)-1) + 2;

   case {'FoG'}
      oplist = type{2};
      for i=1:length(oplist)
         [s,r,c] = outputOperator(oplist{i},relpath);
         str  = [str s];
         cols = cols + c;
         rows = max(rows,r);
      end

   case {'Transpose'}
      oplist = type{2};
      str = sprintf('<TD><IMG SRC="%smiscLBracket.png" Border=0></TD>', ...
                 relpath);
      
      [s,r,c] = outputOperator(oplist,relpath);
      str = [str s];
      
      str = [str sprintf('<TD><IMG SRC="%smiscRBracket.png" Border=0></TD>', ...
                 relpath)];
      
      str = [str sprintf(['<TD><A HREF="operators.html"><!"#Transpose">' ...
                          '<IMG SRC="%sopTranspose.png" Border=0>' ...
                          '</A></TD>'],relpath)];

      cols = cols + c + 3;
      rows = r;

   case {'WindowedOp'}
       subop = type{2};
       
       str = sprintf(['<TD><A HREF="operators.html"><!"#%s">' ...
                      '<IMG Title="%dx%d %s" SRC="%sop%s.png" Border=0>' ...
                      '</A></TD>'], ...
                      type{1},info{1},info{2},type{1},relpath, type{1});
       
       str = [str sprintf('<TD><IMG SRC="%smiscLBracket.png" Border=0></TD>', relpath)];

       [s,r,c] = outputOperator(subop,relpath);
       str = [str s];
              
       str = [str sprintf('<TD><IMG SRC="%smiscRBracket.png" Border=0></TD>', relpath)];
       cols = c + 3;
       rows = r;
              
   case {'BlockDiag'}
       oplist  = type{2};
       weights = type{3};
       blocks  = max(length(type{2}),length(type{3}));
       str = sprintf('<TD><TABLE cellspacing = 0 cellpadding = 0 border=0>\n');

       cols = zeros(blocks,1);
       rows = zeros(blocks,1);
       strb = cell(blocks,1);
              
       for i=1:blocks
         opidx = i; if (length(oplist) == 1), opidx = 1; end;
         
         [s,r,c] = outputOperator(oplist{opidx},relpath);
         rows(i) = r;
         cols(i) = c;
         strb{i} = s;
       end

       for i=1:blocks
         if     (blocks == 1), img = 'Bracket';
         elseif (i      == 1), img = 'BracketTop';
         elseif (blocks == i), img = 'BracketBottom';
         else,                 img = 'BracketCenter';
         end

         str = [str sprintf('<TR><TD><IMG SRC="%smiscL%s.png"></TD>', ...
                            relpath, img)];

         colspan = sum(cols(1:i-1));
         if (colspan ~= 0)
           str = [str sprintf('<TD Colspan=%d></TD>', colspan)];
         end;

         str = [str strb{i}];
         
         colspan = sum(cols(i+1:blocks));
         if (colspan ~= 0)
           str = [str sprintf('<TD Colspan=%d></TD>', colspan)];
         end;

         str = [str sprintf('<TD><IMG SRC="%smiscR%s.png"></TD></TR>\n', ...
                            relpath, img)];
       end
      
       str = [str sprintf('</TABLE></TD>\n')];
       cols = 1;
       rows = max(rows);
 
   case {'Kron'}
       op1 = type{2};
       op2 = type{3};
       
       str = sprintf('<TD><IMG SRC="%sopLBracket.png" Border=0></TD>', relpath);
       [s,r1,c1] = outputOperator(op1,relpath);
       str = [str s];
       str = [str sprintf(['<TD><A HREF="operators.html"><!"#%s">' ...
                           '<IMG SRC="%sopKron.png" Border=0></A></TD>'], ...
                           type{1},relpath)];
       [s,r2,c2] = outputOperator(op2,relpath);
       str = [str s];
       str = [str sprintf('<TD><IMG SRC="%sopRBracket.png" Border=0></TD>', relpath)];

       cols = c1 + c2 + 3;
       rows = max(r1,r2);
              
   otherwise
  

      if strcmp(type{1},'Matrix')
        name = type{1};
        if ~isempty(type{2})
          name = [name ' - ' type{2}];
        end
      else
        name = type{1};
      end
      
      str = sprintf(['<TD><A HREF="operators.html"><!"#%s">' ...
                     '<IMG Title="%dx%d %s" SRC="%sop%s.png" Border=0>' ...
                     '</A></TD>'], ...
                     type{1},info{1},info{2},name,relpath,type{1});
      cols = 1;
      rows = 1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pathdiff = relativepath(pathDest, pathSource)

n    = min(length(pathDest),length(pathSource));
cmp  = (pathDest(1:n) == pathSource(1:n));
idx0 = min(find(cmp == 0));
idxd = find(pathDest   == filesep);
idxs = find(pathSource == filesep);


if isempty(idx0), idx0 = n+1; end
idx0 = min(idx0, length(pathSource));
idx0 = max(find(pathSource(1:idx0) == filesep));
if isempty(idx0), idx0 = 0; end;

updir = length(find(pathSource(idx0+1:end) == filesep));
str   = repmat(['..' filesep],1,updir);

pathdiff = [str pathDest(idx0+1:end)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function outputOperatorHTML(builddir, opts)

% Get list of operators
opname = {};
files = dir([opts.oppath 'op*.m']);
for i=1:length(files)
   opname{i} = files(i).name(3:end-2);
end

opname = sort(opname);
%optdir = relativepath(opts.opthumbpath,builddir);
optdir = 'http://www.cs.ubc.ca/labs/scl/sparco/uploads/Main/figs/';

% Open file
fd = fopen([builddir, 'operators.html'],'w');
if fd == -1
   error(['Error opening file ', builddir, 'operators.html'])
end

% Output header
fprintf(fd,'<HTML>\n');
fprintf(fd,'<Title>Sparco Test Suite - Operators</Title>\n');
fprintf(fd,'<Body>\n');
%fprintf(fd,'<H2>Operators</H2>\n');


% Output table header
fprintf(fd,'<Table>\n');

% Set number of columns 
clm = 1;

% Output operators
n = length(opname);
for i=0:ceil(n/clm)-1
  % Generate operator description
  for j=1:clm
     if clm*i+j <= n  
       eval(sprintf('descr{j} = help(''op%s'');',opname{clm*i+j}));
     else
       descr{j} = [];
     end
  end
   
  for j=1:clm
     description = descr{j};
    
     % Remove intial blank lines from description
     while ~isempty(description) && (description(1) == char(10))
       description = description(2:end);
     end
  
     if ~isempty(description)
        % Extract the short description from the first line
        idx = min(find(description == char(10)));
        if ~isempty(idx)
           title       = description(1:idx-1);
           description = description(idx+1:end);
       
           title = strtrim(title);
           idx = min(find(title == char(32)));
           if ~isempty(idx)
              title = strtrim(title(idx+1:end));
           end;
        else
           title = [];
        end

        % Replace a blank line by <P>
        % blankln = [char(10) ' ' char(10)];
        % description = strrep(description,blankln,sprintf('<P>\n'));
        
        description = strrep(description,char(10),sprintf('\n'));
     else
        description = '<I>No description available</I>';       
        title       = [];
     end
     
     if isempty(title) && (clm*i+j <= n)
       title = opname{clm*i+j};
     end
     captn{j} = title;
     descr{j} = description;
  end % j=1:clm

  fprintf(fd,'<TR>\n');
  for j=1:clm
    if clm*i+j <= n
       fprintf(fd,['   <TD valign="top" rowspan=2>'          ...
                   '<IMG SRC="%sop%s.png"></TD>\n'           ...
                   '    <TD width=500 valign="top" '         ...
                   'bgcolor=#000045><FONT color=#FFFFFF><B>' ...
                   '%s</B></FONT></TD>\n'], ...
                   optdir,opname{clm*i+j},captn{j});
    else
       fprintf(fd,'   <TD rowspan=2 colspan=2></TD>\n');
    end

    % Add padding between two consecutive columns
    if j~=clm, fprintf(fd,'    <TD rowspan=2></TD>\n'); end;
  end
  
  fprintf(fd,'</TR>\n<TR>\n');

  for j=1:clm
    if clm*i+j <= n
       fprintf(fd,['   <TD valign="top" width=500 ' ...
                   'bgcolor=#E4E4E4><PRE>\n%s\n</PRE></TD>'],      ...
                   descr{j});
    end
  end
 
  fprintf(fd,'</TR>\n');
end

% Output table footer
fprintf(fd,'</Table>\n');

% Output footer
fprintf(fd,['<Font size=-3>', ...
            '(Last updated: %s), ', ...
            'Copyright 2007, University of British Columbia</Font>\n'],date);
fprintf(fd,'</Body>\n</HTML>\n');

% Close file
fclose(fd);


function p = getAbsolutePath(p)

if p(1) == '~'
  p = [getenv('HOME') p(2:end)];
elseif p(1) ~= filesep
  s = pwd; cd(p); p = pwd; cd(s);
end


function s = processBibliography(s,url0, urlnew, localref)

log = s;

if ~localref
   % Remove local references
   idx = find(log == '#') - length(url0);
   idx = idx(idx > 0);
   idx = sort(idx,'descend');
   for j=1:length(idx)
     if strncmp(log(idx(j):end),[url0 '#'],length(url0)+1)
       k = min(find(log(idx(j):end) == '"')) - 1;
       log = [log(1:idx(j)-1) url0 log(idx(j)+k:end)];
     end
   end
end

% Replace URL
log = strrep(log,url0, urlnew);

s = log;
