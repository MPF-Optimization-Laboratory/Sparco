function SparcoBrowser

% ===========================================================================
% Create a figure and configure
handles = struct();
handles.hFig = figure; clf;
set(handles.hFig, 'Visible',     'off'             );
set(handles.hFig, 'Name',        generateProblem('version'));
set(handles.hFig, 'NumberTitle', 'off'             );
set(handles.hFig, 'ToolBar',     'None'            );
set(handles.hFig, 'Menubar',     'None'            );
set(handles.hFig, 'Resize',      'off'             );
set(handles.hFig, 'CloseRequestFcn', @OnCloseRequest)

sz = get(handles.hFig,'Position');
sz = [360-140   504-120   560+140   420+120];
set(handles.hFig,'Position', sz);
sz = sz([3 4])+[1 1];


% ---------------------------------------------------------------------
% Add the UI controls
% ---------------------------------------------------------------------
[operatorList,operatorHelp] = getOperatorList();
[problemList,problemHelp]   = getProblemList();

szn = round((sz(2)-65)/2);

handles.hProbList = uicontrol(handles.hFig, 'Style', 'listbox', ...
                              'Position',[sz(1)-155, 50+szn, 150, szn], ...
                              'String', problemList(:,1), ...
                              'BackgroundColor', [1 1 1], ...
                              'Callback', @OnProbListChange);

handles.hOpList = uicontrol(handles.hFig, 'Style', 'listbox', ...
                              'Position',[sz(1)-155, 45, 150, szn], ...
                              'String', operatorList, ...
                              'BackgroundColor', [1 1 1], ...
                              'Callback', @OnOpListChange);

handles.hHelpPanel = uipanel(handles.hFig, ...
                        'Units',           'pixels', ...
                        'Position',        [10,5,sz(1)-170,sz(2)-10], ...
                        'BackgroundColor', get(handles.hFig,'Color'), ...
                        'ShadowColor',     [0.5 0.5 0.5], ...
                        'Title',           'Description');

handle.hButtonQuit = uicontrol(handles.hFig,'Style','pushbutton', ...
                        'Units',           'pixels', ...
                        'Position',        [sz(1)-155, 5,138,30], ...
                        'BackgroundColor', get(handles.hFig,'Color'), ...
                        'String',          'Quit',...
                        'Callback',         @OnButtonQuit);

handles.hOpHelp = uitext(handles.hFig, [20 20 sz(1)-190 sz(2)-40], get(handles.hFig,'Color'), 15, 0);



% ---------------------------------------------------------------------
% Final configurations
% ---------------------------------------------------------------------
% Update the figure data
data = guidata(handles.hFig);
data.handles      = handles;
data.operatorList = operatorList;
data.operatorHelp = operatorHelp;
data.problemList  = problemList;
data.problemHelp  = problemHelp;
data.sz           = sz;
guidata(handles.hFig,data);

% Update the information
OnProbListChange(handles.hProbList);

% Show the figure
set(handles.hFig,'Visible','on');



% ----------
% Main loop
% ----------
try
  uiwait(handles.hFig)
catch
  errordlg({'Unexpected termination. Last message:',lasterr}, 'Model edit error')
end

% ------------------
% Delete the figure
% ------------------
delete(handles.hFig);

% ===========================================================================



% ---------------------------------------------------------------------------
function OnButtonQuit(hObject,varargin)
% ---------------------------------------------------------------------------

% Return to Matlab's built-in user interface
OnQuit(hObject);

% ---------------------------------------------------------------------------
function OnQuit(hObject)
% ---------------------------------------------------------------------------
uiresume;


% ---------------------------------------------------------------------------
function OnCloseRequest(hObject,varargin)
% ---------------------------------------------------------------------------

% Return to Matlab's built-in user interface
OnQuit(hObject);


% ---------------------------------------------------------------------------
function OnOpListChange(hObject,varargin)
% ---------------------------------------------------------------------------
data = guidata(hObject);

v = get(hObject,'Value');

if (v <= length(data.operatorList))
    if isempty(data.operatorHelp{v})
       try
          helpstr = evalc(sprintf('help %s',data.operatorList{v}));
          data.operatorHelp{v} = helpstr;
          guidata(hObject,data);
       catch
       end
    end

    text   = splitLines(data.operatorHelp{v});
    handle = data.handles.hOpHelp;
    sdata  = get(handle,'UserData');
    sdata.SetLines(handle, text, [1.0 1.0 0.9], 0);
end

% ---------------------------------------------------------------------------
function OnProbListChange(hObject,varargin)
% ---------------------------------------------------------------------------
data = guidata(hObject);

v = get(hObject,'Value');

if (v <= length(data.problemList))
    if isempty(data.problemHelp{v})
       helpstr = evalc(sprintf('generateProblem(data.problemList{v,2},''help'');'));
       data.problemHelp{v} = helpstr;
       guidata(hObject,data);
    end

    text   = splitLines(data.problemHelp{v});
    handle = data.handles.hOpHelp;
    sdata  = get(handle,'UserData');
    sdata.SetLines(handle, text, [1.0 1.0 0.9], 0);
end




% ===========================================================================
function [operatorList,operatorHelp] = getOperatorList()
% ===========================================================================
operatorList = {};
operatorHelp = {};

location = which('generateProblem');
if ~isempty(location)
   [pathstr,name,ext,versn] = fileparts(location);
   pathstr = [pathstr, filesep, 'operators'];
   d = dir([pathstr, filesep, 'op*.m']);

   for i=1:length(d)
      namestr = d(i).name;
      try
         operatorList{end+1} = namestr(1:end-2);
         operatorHelp{end+1} = [];
      catch
         % Ignore this operator
      end
   end
end


% ===========================================================================
function [problemList,problemHelp] = getProblemList()
% ===========================================================================
problemList = cell(0,3);
problemHelp = {};

p = generateProblem('list');
for probId = p
  probName = generateProblem(probId,'getname');
  problemList{end+1,1} = sprintf('%3d. %s',probId,probName);
  problemList{end  ,2} = probId;
  problemList{end  ,3} = probName;
  problemHelp{end+1} = [];
end
