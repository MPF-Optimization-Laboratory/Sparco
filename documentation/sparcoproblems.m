% Produce an HTML page with all the Sparco problems help

   % Get parent directory
   fullpath = mfilename('fullpath');
   idx      = find(fullpath == filesep);
   htmlpath = fullpath(1:idx(end));
   
   % Augmented d with H1, fullpath, etc.
   d = dir(fullfile(sparco.path,'+sparco','+problems', '*.m'));   
   
   % Create/open the methods_list.html file for appending
   htmlfile = fullfile(htmlpath, 'problems_list.html');
   %delete(htmlfile);
   FID = fopen(htmlfile, 'a');
   
   % Append each htmlhelp to the file
   for i=1:numel(d)
       name = d(i).name(1:end-2);
       if(~strcmp(name, 'divide')) % divide is protected, so it won't find help
           linktext = strcat('<html><a name="', name, '"></a>'); % Give each htmlhelp a link to use in the table of contents
           helptext = help2html(fullfile(sparco.path, '+sparco','+problems', name));
           text = strrep(helptext, '<html>', linktext);
           fprintf(FID, '%s', text);
       end
   end
   
   fclose(FID);
   
   % Read the methods_list.html file as a string
   filetext = fileread(htmlfile);
   
   % Open the methods_list.html file for writing
   FID = fopen(htmlfile, 'w');
   
   % Delete everything in the header table
   tablerexp = '<table(.*?)</table>';
   newtext = regexprep(filetext, tablerexp, '');
  % fprintf(FID, '%s\n', newtext);
   
   % Change the stylesheet link
   stylestr = '<link rel="stylesheet" href="../helpwin.css">';
   newstylestr = '<link rel="stylesheet" href="../style.css"/>';
   newtext = strrep(newtext, stylestr, newstylestr);
   fprintf(FID, '%s\n', newtext);
   
   fclose(FID);