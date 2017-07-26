function sparcoSetup(varargin)
%SPARCOSETUP Setup the SPARCO toolbox.
%
%   SPARCOSETUP will install the SPARCO toolbox.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: sparcoSetup.m 1027 2008-06-24 23:42:28Z ewout78 $


import sparco.tools.*

pathlist = {};

% Get root location of sparcoSetup
root = fileparts(which(mfilename));

% ----------------------------------------------------------------------
% Add Sparco subdirs to path.
% ----------------------------------------------------------------------
addtopath(root,'');

% Make sure that the build subdir exists
buildpath = {['build'],                          ...
             ['build' filesep 'figures'],        ...
             ['build' filesep 'html'],           ...
             ['build' filesep 'latex'],          ...
             ['build' filesep 'thumbs']};
for i=1:length(buildpath)
    p = buildpath{i};
    if ~exist([root filesep p],'dir')
       [success,message,messageid] = mkdir(root, p);
       if ~success
          error('Could not create directory %s%s\n',root,p);
       end
    end
end

% ----------------------------------------------------------------------
% Check if Spot toolbox is installed and install it if not 
% ----------------------------------------------------------------------
try spot.path;
    fprintf('Spot toolbox found and in your path\n');
catch err
    fprintf('Spot toolbox not in the path\n');
    if(~exist(fullfile(root,'spotbox'),'dir'))
        fprintf('Spot toolbox not found\n');
        fprintf('   Downloading Spot...\n');
        spotwebsite = 'http://www.cs.ubc.ca/labs/scl/spot/';
        website = urlread(spotwebsite);
        dl = strfind(website, 'Download');
        website = website(dl(1):size(website,2));
        spotURL = strfind(website, '<a href="');
        website = website((spotURL(1)+9):size(website,2));
        endofURL = strfind(website,'"');
        website = website(1:(endofURL-1));

        if(~contains(website,'www')&&~contains(website,'http'))
            website = strcat(spotwebsite,website);
        end

        [path,status] = urlwrite(website,'spot.zip');

        if(status==0)
            warning('Warn:noDL','Could not download Spot toolbox from website\n You must have Spot for Sparco to work\n')
        else
            fprintf('   Unzipping Spot toolbox...\n');
            unzip(path,root);
        end

        delete(path);

    else
        fprintf('Spot toolbox found\n');
    end
    
    list = dir(root);

    for i=1:length(list)
        if(~isempty(strfind(list(i).name,'spot-')))
            if(list(i).isdir)
                if(strcmp(list(i).name,'spotbox')) %Rename folder if needed
                    break
                else
                    spotDirName = list(i).name;
                    newspotDirname = 'spotbox';
                    movefile(spotDirName,newspotDirname);
                    break
                end
            end
        end
    end

    addtopath(root,'spotbox');
end


% ----------------------------------------------------------------------
% NESTED FUNCTIONS
% ----------------------------------------------------------------------

function addtopath(root,dirname)
if ~exist([root filesep dirname],'dir')
   error('Required directory "%s%s%s" is missing!.\n',root,filesep,dirname);
else
   newdir = [root filesep dirname];
   fprintf('Adding to path: %s\n',newdir);
   addpath(newdir);
   pathlist{end+1} = newdir;
end
end % function adddirtopath

end % function sparcoSetup


% ----------------------------------------------------------------------
% PRIVATE FUNCTIONS
% ----------------------------------------------------------------------

function available = checkFunction(funname)

available = false;
w = which(funname);
if ~isempty(w)
   available = true;
   [root, name, ext, versn] = fileparts(w);
   if ~strcmp(name,funname)
      available = false;
      fprintf('Warning: Found case-insensitive match for %s.\n', funname);
   end
end

end % function checkFunction


