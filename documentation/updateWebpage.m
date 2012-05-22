function updateWebpage(updateFigs)

if nargin < 1, error('Please specify updateFigs parameter'); end;

basePath = '/cs/scl/public_html/sparco/uploads/Main';
figPath  = [basePath '/figs'];

if updateFigs
   generateProblem('update-all', ...
                   'thumbpath',figPath, 'figpath', figPath, ...
                   'linewidth',2,'fontsize',16);
end

baseURL = '/labs/scl/sparco/uploads/Main';
baseURLFig = [baseURL '/figs'];

% Generate the webpages
generateHTML(baseURL, ...
             'thumbpath',baseURLFig,'figpath',baseURLFig,...
             'opthumbpath',baseURLFig, ...
             'buildpathHTML',basePath)

% Copy operator thumbnails
[pathstr, name, ext, versn] = fileparts(which('sparcoSetup'));
copyfile([pathstr '/documentation/thumbs/*.png'],figPath);
