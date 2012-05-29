function demoFrame(demoList,header)
% DEMOFRAME  Demonstrantion framework
%
%    DEMOFRAME(DEMOLIST,HEADER) shows an interface from which demos
%    can be selected and ran. The DEMOLIST is a cell array
%    of demos. Each demo cell contains a name, description and the
%    filename of the script. The HEADER option specifies the title
%    of the window.

if nargin < 2, header = ''; end;

% ===========================================================================
% Create a figure and configure
% ===========================================================================
handles = struct();
handles.hFig = figure(240); clf;
set(handles.hFig, 'Visible',     'off'             );
set(handles.hFig, 'Name',        header            );
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
% Extract the list of demo names, descriptions, and filenames
% ---------------------------------------------------------------------
demoNames        = {};
demoDescriptions = {};
demoFilenames    = {};
for i=1:length(demoList)
  demo = demoList{i};
  demoNames{end+1}        = demo{1};
  demoDescriptions{end+1} = demo{2};
  demoFilenames{end+1}    = demo{3};
end



% ---------------------------------------------------------------------
% Add the UI controls
% ---------------------------------------------------------------------
handles.hButtonQuit = uicontrol(handles.hFig,...
                               'Style','pushbutton', ...
                               'Units',           'pixels', ...
                               'Position',        [sz(1)-60, 5,50,30], ...
                               'BackgroundColor', get(handles.hFig,'Color'), ...
                               'String',          'Quit',...
                               'Callback',         @OnButtonQuit);

handles.hButtonNext = uicontrol(handles.hFig,...
                               'Style','pushbutton', ...
                               'Units',           'pixels', ...
                               'Position',        [sz(1)-155, 5,70,30], ...
                               'BackgroundColor', get(handles.hFig,'Color'), ...
                               'String',          'Next >>',...
                               'Callback',         @OnButtonNext);

handles.hButtonRun = uicontrol(handles.hFig,...
                               'Style','pushbutton', ...
                               'Units',           'pixels', ...
                               'Position',        [sz(1)-155, 5,85,30], ...
                               'BackgroundColor', get(handles.hFig,'Color'), ...
                               'String',          'Run demo',...
                               'Callback',         @OnButtonRun);

handles.hDemoList = uicontrol(handles.hFig, 'Style', 'listbox', ...
                              'Position',[sz(1)-155, 45, 150, sz(2)-60], ...
                              'String', demoNames, ...
                              'BackgroundColor', [1 1 1], ...
                              'Callback', @OnDemoListChange);

handles.hDescriptionPanel = uipanel(handles.hFig, ...
                              'Units',           'pixels', ...
                              'Position',        [10,230,sz(1)-180,sz(2)-240], ...
                              'BackgroundColor', get(handles.hFig,'Color'), ...
                              'ShadowColor',     [0.5 0.5 0.5], ...
                              'Title',           'Description');

handles.hDescription = uitext(handles.hFig, ...
                              [15, 235, sz(1)-190, sz(2)-260], ...
                              get(handles.hFig,'Color'), ...
                              15, 0);

handles.hCommandPanel = uipanel(handles.hFig, ...
                              'Units',           'pixels', ...
                              'Position',        [10,10,sz(1)-180,215], ...
                              'BackgroundColor', get(handles.hFig,'Color'), ...
                              'ShadowColor',     [0.5 0.5 0.5], ...
                              'Title',           'Commands');

handles.hCommands = uitext(handles.hFig, ...
                           [15, 15, sz(1)-190, 195], ...
                           get(handles.hFig,'Color'), ...
                           15, 0);


% ---------------------------------------------------------------------
% Final configurations
% ---------------------------------------------------------------------
% Update the figure data
data = guidata(handles.hFig);
data.handles      = handles;
data.sz           = sz;
guidata(handles.hFig,data);


% Add additional data
data.demoNames        = demoNames;
data.demoDescriptions = demoDescriptions;
data.demoFilenames    = demoFilenames;
data.slides           = {};
data.slide            = 1;
data.step             = 1;
data.mode             = '-';
guidata(handles.hFig,data);

% Set the correct mode
OnDemoListChange(handles.hDemoList);

% Show the figure
set(handles.hFig,'Visible','on');


% ---------------------------------------------------------------------
% Main loop
% ---------------------------------------------------------------------
try
  uiwait(handles.hFig)
catch
  errordlg({'Unexpected termination. Last message:',lasterr}, 'Sparco Demo error')
end

% ---------------------------------------------------------------------
% Delete the figure
% ---------------------------------------------------------------------
delete(handles.hFig);

% ===========================================================================






% ===========================================================================
% Event handlers
% ===========================================================================

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
function OnButtonQuit(hObject,varargin)
% ---------------------------------------------------------------------------

% Return to Matlab's built-in user interface
OnQuit(hObject);

% ---------------------------------------------------------------------------
function OnButtonNext(hObject,varargin)
% ---------------------------------------------------------------------------
data = guidata(hObject);

slide = data.slides{data.slide};
step  = data.step;

% Get slide description
steps = floor(length(slide)/2);
description = {''};
for i = data.step:-1:1
   comment = slide{2*i-1};
  
   if step <= data.step && ~isempty(comment)
     if ~iscell(comment)
         description = {comment};
         break
     else
         description = comment;
         break
     end;
   end
end

% Get commands
command = slide{2*data.step};
cmd     = ''; newline = sprintf('\n');
for i=1:length(command)
   cmdi = command{i};
   if cmdi(1) == '-', cmdi = cmdi(2:end); end;
   cmd = [cmd,newline,cmdi];
end

if ~isempty(cmd)
   evalin('base',cmd);
end


if data.step < steps
   data.step = data.step + 1;
else
   data.step = 1;
   data.slide = data.slide + 1;
end

% Update slide and step information
guidata(hObject,data);

% Display current step
showSlide(data);


% ---------------------------------------------------------------------------
function OnButtonRun(hObject,varargin)
% ---------------------------------------------------------------------------
data = guidata(hObject);
handles = data.handles;

v = get(handles.hDemoList,'Value');
if (v <= length(data.demoNames))
   % Try to load the data
   try
      script = loadScript(data.demoFilenames{v});
      data.slides = script;
      guidata(hObject,data);
      
      % Switch to slide mode
      setMode(hObject,'slides');
   catch
     lasterror
   end   
end



% ---------------------------------------------------------------------------
function OnDemoListChange(hObject,varargin)
% ---------------------------------------------------------------------------
data = guidata(hObject);

if ~strcmp(data.mode,'selection')
   setMode(hObject,'selection');
   data = guidata(hObject);
end

v = get(hObject,'Value');

if (v <= length(data.demoNames))
    text   = data.demoDescriptions{v};
    if ~iscell(text), text = {text}; end
    handle = data.handles.hDescription;
    sdata  = get(handle,'UserData');
    sdata.SetLines(handle, text, [1.0 1.0 1.0], 0);
end


% ===========================================================================
% Miscellaneous functions
% ===========================================================================


% ---------------------------------------------------------------------------
function showSlide(data)
% ---------------------------------------------------------------------------

if data.slide <= length(data.slides)
   set(data.handles.hButtonNext,'Enable','on');
else
   set(data.handles.hButtonNext,'Enable','off');
   return;
end

% Get slide
slide = data.slides{data.slide};


% Construct command list
cmdList = {};
clrList = {};
description = {''};

for step=1:floor(length(slide)/2)
   comment = slide{2*step-1};
   command = slide{2*step  };
   
   if step <= data.step && ~isempty(comment)
     if ~iscell(comment)
         description = {comment};
     else
         description = comment;
     end;           
   end

   if ~isempty(command)
      if step < data.step
         clr = [0.7 0.8 1.0];
      elseif step == data.step
         clr = [1 1 0.4];
      else
         clr = [0.7 0.8 1.0];
      end

      for j=1:length(command)
         cmd = command{j};
         if cmd(1) ~= '-'
            cmdList{end+1} = cmd;
            clrList{end+1} = clr;     
         end
      end
   end
end   

handle = data.handles.hCommands;
sdata  = get(handle,'UserData');
sdata.SetLines(handle, cmdList, clrList, 0);

handle = data.handles.hDescription;
sdata  = get(handle,'UserData');
sdata.SetLines(handle, description, [1 1 1], 0);



% ---------------------------------------------------------------------------
function script = loadScript(filename)
% ---------------------------------------------------------------------------

script = {};
slide  = {};

% Open file for reading
fp = fopen(filename,'r');
if fp == -1, return; end;

% Parse file
comment = ''; command = {}; whitespace = 0; visible = 1;

while(1)
   str = fgetl(fp);
   if ~ischar(str), break; end;
   if isempty(str), whitespace = 1; continue; end;
   
   % Check for visibility statements
   if strcmp(str,'%-'), visible = 0; continue; end;
   if strcmp(str,'%+'), visible = 1; continue; end;
   
   % Check for comment
   if str(1) == '%'
      if whitespace || ~isempty(command)
         % Append previous comment and command information to slide
         if ~isempty(comment)
            slide{end+1} = comment;
         else
            slide{end+1} = '';
         end
         
         slide{end+1} = command;
         
         comment = {};
         command = {};
         whitespace = 0;
         
         % Create new slide if needed
         if strncmp(str,'%%',2)
            script{end+1} = slide;
            slide         = {};
            visible       = 1; % Reset visibility
         end
      end

      % Add non-empty comment
      if strncmp(str,'%%',2)
         str = str(3:end);
      elseif length(strtrim(str)) > 1 || length(str) > 2
         str = str(2:end);
      else
         str = '';
      end
      if (length(str) > 0)
         if (str(1) == ' '), str = str(2:end); end;
         comment{end+1} = str;
      end
      
   else
      if ~visible
         command{end+1} = ['-',str];
      else
         command{end+1} = str;
      end
   end
end

% Add final slide
if ~isempty(comment) || ~isempty(command)
   slide{end+1} = comment;
   slide{end+1} = command;
   script{end+1} = slide;
end


% Close file
fclose(fp);


% ---------------------------------------------------------------------------
function setMode(hObject,mode)
% ---------------------------------------------------------------------------

data   = guidata(hObject);
handles = data.handles;

switch mode
 case {'selection'}
     set(handles.hButtonNext,  'Visible', 'off');
     set(handles.hButtonRun,   'Visible', 'on' );
     set(handles.hCommandPanel,'Visible', 'off');
     
     shandle = data.handles.hCommands;
     sdata  = get(shandle,'UserData');
     sdata.SetVisibility(shandle,'off');

     data.slides = {};
     data.slide  = 1;
     data.step   = 1;
     data.mode   = mode;
     guidata(hObject,data);
     
     OnDemoListChange(handles.hDemoList);

 case {'slides'}
     set(handles.hButtonNext,  'Visible', 'on' );
     set(handles.hButtonRun,   'Visible', 'off');
     set(handles.hCommandPanel,'Visible', 'on' );

     showSlide(data);

     shandle = data.handles.hCommands;
     sdata  = get(shandle,'UserData');
     sdata.SetVisibility(shandle,'on');
     
     data.mode   = mode;
     guidata(hObject,data);
     
end
