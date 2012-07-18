% Produce an HTML page with all the Sparco problems help

   % Get parent directory
   fullpath = mfilename('fullpath');
   idx      = find(fullpath == filesep);
   htmlpath = fullpath(1:idx(end));
   
   % Augmented d with H1, fullpath, etc.
   d = dir(fullfile(sparco.path,'+sparco','+problems', '*.m'));   
   
   % Create/open the methods_list.html file for appending
   htmlfile = fullfile(htmlpath, 'problems_list.html');
   delete(htmlfile);
   FID = fopen(htmlfile, 'a');
   
   % Append each htmlhelp to the file
   for i=1:numel(d)
       name = d(i).name(1:end-2);
       if(~strcmp(name, 'probSparseman')&&~strcmp(name,'probMondrian')) % divide is protected, so it won't find help
           linktext = strcat('<html><a name="', name, '"></a>'); % Give each htmlhelp a link to use in the table of contents
           helptext = help2html(fullfile(sparco.path, '+sparco','+problems', name));
           text = strrep(helptext, '<html>', linktext);
           % Give an image to illustrate the problem
           srcname = '<div class="title">';
           figname = sprintf('%s<img src="figProblem%s.png" alt="%s" style="border: solid 1px black"/>',srcname,name(end-2:end),name);
           text = strrep(text, srcname, figname);
           fprintf(FID, '%s', text);
       end
   end
   
   fclose(FID);
   
   % Read the problems_list.html file as a string
   filetext = fileread(htmlfile);
   
   % Open the problems_list.html file for writing
   FID = fopen(htmlfile, 'w');
   
   % Delete everything in the header table
   tablerexp = '<table(.*?)</table>';
   newtext = regexprep(filetext, tablerexp, '');
  % fprintf(FID, '%s\n', newtext);
   
   % Change the stylesheet link
   stylestr = '<link rel="stylesheet" href="file:////cs/local/generic/lib/pkg/matlab-7.14/toolbox/matlab/helptools/private/helpwin.css">';
   newstylestr = '<link rel="stylesheet" href="style.css"/>';
   newtext = strrep(newtext, stylestr, newstylestr);
   
   % Change the generateProblem link
   generatestr = '"matlab:helpwin generateProblem"';
   newgeneratestr = '"generate.html"';
   newtext = strrep(newtext, generatestr, newgeneratestr);
   fprintf(FID, '%s\n', newtext);
   
   
   
   fclose(FID);