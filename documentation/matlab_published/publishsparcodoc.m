% Publish all the .m files in matlab_published/mfiles. Edit the resulting
% html files to match the formatting of the Sparco website (using style.css)
% and reference the images in matlab_published/html.

clear all;

% Get parent directory
fullpath = mfilename('fullpath');
idx      = find(fullpath == filesep);
path = fullpath(1:idx(end));

fprintf('If you have created a new .m file  or changed an existing one\n');
fprintf('in the matlab_published/mfiles directory, you should publish it.\n\n');

% publish all the mfiles
mfiles = dir(fullfile(path, 'mfiles', '*.m'));
options = struct('outputDir', fullfile(path, 'html'));
for i = 1:numel(mfiles)
    reply = input(['Publish ', mfiles(i).name, '? (y/n)\n'], 's');
    no = {'n', 'N', 'no', 'No'};
    if any(strcmp(reply, no))
        % Do nothing
    else publish(mfiles(i).name, options);
    end
end

htmlfiles = dir(fullfile(path, 'html', '*.html'));
idx      = find(fullpath == filesep); % Reput it here because some mfiles change it.
for k = 1:numel(htmlfiles)
    name = htmlfiles(k).name;
    % Convert the input file into a string
    text = fileread(fullfile(path, 'html', name));
    
    % Replace the formatting information with a reference to style.css
    stexp = '<style.*</style>';
    streplace = '\n<link rel="stylesheet" type="text/css" href="../../style.css"/>\n';
    text = regexprep(text, stexp, streplace);
    
    % Change all the image "src" tags to the html directory
    imgexp = ['src="(' path, 'html', filesep, ')*'];
    imgreplace = ['src="', path, 'html', filesep];
    text = regexprep(text, imgexp, imgreplace);
    
    % Make a new text file
    %newfilepath = fullfile(path, 'html', htmlfiles(k).name);
    FID = fopen(fullfile(path, 'html', name), 'w');
    
    % Print the modified string to the text file
    result = fprintf(FID, '%s\n', text);
    
    % Close the text file
    fclose(FID);
    
    % Make a jemdoc page if it doesn't already exist
    extexp = '\.html';
    extreplace = '2\.jemdoc';
    filename = regexprep(name, extexp, extreplace);
    jemdocfile = fullfile(path(1:idx(end-1)), filename);
    
    % Name of the final html file
    extreplace2 = '2\.html';
    finalfile = regexprep(name, extexp, extreplace2);
    
    if(exist(jemdocfile, 'file') ~=2)
        FID2 = fopen(jemdocfile, 'a');
        pagetitle = input(['\nEnter a title for the ', filename, ' page\n'], 's');
        
        fprintf(FID2, ['# jemdoc: menu{MENU}{', finalfile, '}, notime\n']);
        fprintf(FID2, ['= ', pagetitle, '\n\n']);
        fprintf(FID2, ['#includeraw{matlab_published/html/', name, ' }']);
        fclose(FID2);
    end
end

fprintf('All done! Look for the new jemdoc pages in the spotdoc/web directory\n');
fprintf('and run "make" to generate the html pages from them.\n');

clear all;