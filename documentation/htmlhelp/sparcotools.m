% Produce an HTML page with all the Sparco problems help

   % Get parent directory
   fullpath = mfilename('fullpath');
   idx      = find(fullpath == filesep);
   htmlpath = fullpath(1:idx(end));
   
   % Augmented d1 with H1, fullpath, etc.
   d1 = dir(fullfile(sparco.path,'+sparco', '*.m'));   
   
   % Augmented d2 with H1, fullpath, etc.
   d2 = dir(fullfile(sparco.path,'+sparco','+tools', '*.m'));
   
   % Create/open the methods_list.html file for appending
   htmlfile = fullfile(htmlpath, 'tools_list.html');
   delete(htmlfile);
   FID = fopen(htmlfile, 'a');
   
   % Append each htmlhelp to the file
   for i=1:numel(d1)
       name = d1(i).name(1:end-2);
       if(strcmp(name, 'sparcoColumnRestrict')||strcmp(name,'sparcoBlur')) % Only choose those 2 in +sparco/
           linktext = strcat('<html><a name="', name, '"></a>'); % Give each htmlhelp a link to use in the table of contents
           helptext = help2html(fullfile(sparco.path, '+sparco', name));
           text = strrep(helptext, '<html>', linktext);
           fprintf(FID, '%s', text);
       end
   end
   
   for i=1:numel(d2)
       name = d2(i).name(1:end-2);
       linktext = strcat('<html><a name="', name, '"></a>'); % Give each htmlhelp a link to use in the table of contents
       helptext = help2html(fullfile(sparco.path, '+sparco','+tools', name));
       text = strrep(helptext, '<html>', linktext);
       fprintf(FID, '%s', text);
   end
   
   fclose(FID);
   
   % Read the tools_list.html file as a string
   filetext = fileread(htmlfile);
   
   % Open the tools_list.html file for writing
   FID = fopen(htmlfile, 'w');
   
   % Delete everything in the header table
   tablerexp = '<table(.*?)</table>';
   newtext = regexprep(filetext, tablerexp, '');
  % fprintf(FID, '%s\n', newtext);
   
   % Change the stylesheet link
   stylestr = '<link rel="stylesheet" href="file:////cs/local/generic/lib/pkg/matlab-7.14/toolbox/matlab/helptools/private/helpwin.css">';
   newstylestr = '<link rel="stylesheet" href="style.css"/>';
   newtext = strrep(newtext, stylestr, newstylestr);
   
   % Change the ellipses link
   generatestr = '"matlab:helpwin sparco.tools.ellipses"';
   newgeneratestr = '"tools.html#ellipses"';
   newtext = strrep(newtext, generatestr, newgeneratestr);
   
   % Change the ellipsoids link
   generatestr = '"matlab:helpwin sparco.tools.ellipsoids"';
   newgeneratestr = '"tools.html#ellipsoids"';
   newtext = strrep(newtext, generatestr, newgeneratestr);
   fprintf(FID, '%s\n', newtext);
   
   
   fclose(FID);