function generateLaTeX(varargin)

% Set default data or document directory
opts   = parseDefaultOpts(varargin);
docdir = [opts.buildpath 'latex' filesep];

problems = generateProblem('list');

for i=problems
  
   % -------------------------------------------------------------
   %              P R O B L E M   F O R M U L A T I O N 
   % -------------------------------------------------------------
   % Open file
   fd = fopen(sprintf('%sformulation_%d.tex',docdir,i),'w');
   if fd == -1
      error(sprintf('Error opening file %sformulation_%d.tex', ...
         docdir,i))
   end
   
   % Get problem information
   data = generateProblem(i);
   info = data.info;
   opinfo = data.A([],0);
   
   OutputFormulation(fd,2,opinfo,i, opts.opthumbpath);
   
   % Close file
   fclose(fd);

   % -------------------------------------------------------------
   %                          T A B L E S  
   % -------------------------------------------------------------
   if isfield(info,'tab')
      for t=1:length(info.tab)
         generateLaTeXTable(info.tab{t},docdir);
      end
   end
end

end % function generateLaTeX

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function OutputFormulation(fd,type,op,idx,path)

switch type
 case 1
    fprintf(fd,'\\begin{center}\n');
    OutputLaTeXBlocks(fd,op,path);
    fprintf(fd,'\n\\end{center}\n');
 case 2
    fprintf(fd,'\\setlength{\\arraycolsep}{0mm}\n');
%    fprintf(fd,'\\begin{equation}\\label{Eq:Formulation_%d}\n', idx);
    fprintf(fd,'\\begin{displaymath}\n');
    fprintf(fd,'\\begin{array}{ll}');
    fprintf(fd,'\\begin{minipage}{10.1cm}\\begin{center}\n');
    OutputLaTeXBlocks(fd,op,path);
    fprintf(fd,'\\end{center}\\end{minipage} & \n');
    fprintf(fd,'\\begin{minipage}{2.0cm}\\hfill$(%d\\times%d)$', op{1},op{2});
    fprintf(fd,'\\end{minipage}\n\\end{array}');
    
%    fprintf(fd,'\n\\end{equation}\n');
    fprintf(fd,'\n\\end{displaymath}\n');

 case 3
    fprintf(fd,'\\begin{displaymath}\n');
    OutputLaTeXMath(fd,op);
    fprintf(fd,'\\end{displaymath}\n');
 case 4
    fprintf(fd,'\\begin{equation}\\label{Eq:Formulation_%d}\n',idx);
    OutputLaTeXMath(fd,op);
    fprintf(fd,'\\end{equation}\n');
end

end % function OutputFormulation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function OutputLaTeXBlocks(fd,op,path)
type = op{4};
switch type{1}
 case {'Dictionary'}
      fprintf(fd,'\\setlength{\\fboxsep}{2pt}');
      fprintf(fd,'\\fbox{');
      oplist = type{2};
      for i=1:length(oplist)
         if i ~= 1
           fprintf(fd,'\n\\includegraphics[height=1cm]{%sopSeparator.pdf}\n',path);
         end
         OutputLaTeXBlocks(fd,oplist{i},path);
      end
      fprintf(fd,'}');
   case {'FoG'}
      oplist = type{2}; str = '';
      for i=1:length(oplist)
         if i ~= 1, fprintf(fd,'\\ \n'); end;
         OutputLaTeXBlocks(fd,oplist{i},path);
      end

   case {'Transpose'}
      oplist = type{2};
      OutputLaTeXBlocks(fd,oplist,path);
      fprintf(fd,'\\raisebox{0.9cm}{T}');

 otherwise
      fprintf(fd,'\\includegraphics[height=1cm]{%sop%s.pdf}',path,type{1});
end

end % function OutputLaTeXBlocks

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function OutputLaTeXMath(fd,op)
type = op{4};
switch type{1}
 case {'Dictionary'}
      fprintf(fd,'\\left[');
      oplist = type{2};
      for i=1:length(oplist)
         if i ~= 1
           fprintf(fd,'\\ \\vdots\\ ');
         end
         OutputLaTeXMath(fd,oplist{i});
      end
      fprintf(fd,'\\right]');
   case {'FoG'}
      oplist = type{2}; str = '';
      for i=1:length(oplist)
         if i ~= 1, fprintf(fd,'\\cdot '); end;
         OutputLaTeXMath(fd,oplist{i});
      end

   case {'Transpose'}
      oplist = type{2};
      OutputLaTeXMath(fd,oplist);
      fprintf(fd,'^T');

 otherwise
      fprintf(fd,'\\mathrm{%s}',type{1});
end

end % functionOutputLaTeXMat