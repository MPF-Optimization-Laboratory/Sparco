% selectable does not work :S

function hScroll = uitext(hParent, position, bgcolor, linespacing, selectable)

% ===========================================================================
n = ceil(position(4) / linespacing);

hScroll = uicontrol(hParent, 'Style',      'slider',       ...
                             'Max',        0,              ...
                             'Min',        -100,           ...
                             'Value',      0,              ...
                             'SliderStep', [0.01,0.5], ...
                             'Callback',   @OnMoveSlider,  ...
                             'Position',   [(position(1) + position(3) - 16), position(2), 16, position(4)]);

for i=1:n
   pos(1) = position(1);
   pos(2) = max(position(2), position(2) + position(4) - i * linespacing);
   pos(3) = position(3) - 16;
   pos(4) = min(linespacing, position(4) - (i-1) * linespacing);

   hText(i) = uicontrol(hParent, 'Style',               'text',           ...
                                 'String',              '',               ...
                                 'FontName',            'Courier',        ...
                                 'HorizontalAlignment', 'left',           ...
                                 'Position',             pos,             ...
                                 'SelectionHighlight',   'off',           ...
                                 'BackgroundColor',      bgcolor,         ...
                                 'UserData',             hScroll);
end

data.hScroll  = hScroll;
data.hText    = hText;
data.offset   = 0;
data.lines    = floor(position(4) / linespacing);
data.color    = [];
data.text     = {};
data.selected = [];
data.bgcolor  = bgcolor; % Default background color
data.Update   = @OnUpdateSlider;
data.AddLine  = @OnAddLine;
data.AddLines = @OnAddLines;
data.SetLines = @OnSetLines;
data.Delete   = @OnDelete;

set(hScroll, 'UserData', data);

% Currently the handles seem not to work --- UNTESTED FEATURE ---
if (selectable)
   for i=1:length(hText)
      set(hText(i),'ButtonDownFcn',@OnTextClick);
      set(hText(i),'Callback',@OnTextClick);
   end
end

OnUpdateSlider(hScroll);
% ===========================================================================




% ---------------------------------------------------------------------------
function OnMoveSlider(hObject,varargin)
% ---------------------------------------------------------------------------
data   = get(hObject, 'UserData');
offset = floor(-get(hObject,'Value'));

if (offset == data.offset), return; end;

data.offset = offset;
set(hObject,'UserData',data);

for i=1:length(data.hText)
   if (i+offset <= length(data.text))
      OnDrawText(data.hText(i), data.text{i+offset}, data.color(i+offset,1:3), data.selected(i+offset));
   else
      %OnDrawText(data.hText(i), '', data.bgcolor, 0);
      OnDrawText(data.hText(i), '', [1 1 1], 0);
   end
end



% ---------------------------------------------------------------------------
function OnDrawText(hObject, text, color, selected)
% ---------------------------------------------------------------------------
if (selected), color = min(color * 1.2 + [0.05 0.05 0.15], 1); end;

set(hObject, 'String', text, 'BackgroundColor', color);



% ---------------------------------------------------------------------------
function OnTextClick(hObject,varargin)
% ---------------------------------------------------------------------------
hScroll = get(hObject, 'UserData');
data    = get(hScroll, 'UserData');
offset  = data.offset;

i = find(data.hText, hObject);
if (~isempty(i))
   i = i(1); % Ensure we are using a scalar
   if (i+offset <= length(data.text))
      data.selected(i+offset) = 1 - data.selected(i+offset);
      OnDrawText(hObject, data.text{i+offset}, data.color(i+offset,1:3), data.selected(i+offset));
      set(hScroll,'UserData',data);
   end
end



% ---------------------------------------------------------------------------
function OnUpdateSlider(hObject)
% ---------------------------------------------------------------------------
data    = get(hObject, 'UserData');
delta   = 0;
visible = get(hObject, 'Visible');

v = min(0, (data.lines - length(data.text)));

set(hObject,'Min', v, 'Max', 0);
if (get(hObject,'Value') < v), set(hObject,'Value', v); end
if (get(hObject,'Value') > 0), set(hObject,'Value', 0); end

minor = 0; if (length(data.text ) > data.lines), minor = 1/(length(data.text) - data.lines); end
major = 1; if (length(data.hText) > 2), major = min(minor * (length(data.hText)-2), 1); end

set(hObject,'SliderStep', [minor, major]);

if (length(data.text) < length(data.hText))
   if (strcmp(get(hObject,'Visible'),'on'))
      visible = 'off';
      delta = 16;
   end
else
   if (strcmp(get(hObject,'Visible'),'off'))
      visible = 'on';
      delta = -16;
   end
end

if (delta ~= 0)
   for i=1:length(data.hText)
      pos = get(data.hText(i),'Position');
      pos(3) = pos(3) + delta;
      set(data.hText(i),'Position',pos);
   end
end

data.offset = -1; set(hObject, 'UserData', data, 'Visible', visible, 'Enable', visible);
OnMoveSlider(hObject);

% Force a redraw of the scrollbar
data       = get(hObject, 'UserData');
color      = get(data.hScroll, 'BackgroundColor');
pos        = get(data.hScroll,'Position');
posDirty   = pos + [0, 1, 0, -1];
colorDirty = color + [0 0 0.2]; if(colorDirty(3) > 1), colorDirty(3) = 0; end;

set(data.hScroll, 'BackgroundColor', colorDirty, 'BackgroundColor', color,'Position', posDirty, 'Position', pos);





% ---------------------------------------------------------------------------
function OnAddLine(hObject, text, color, selected)
% ---------------------------------------------------------------------------
data  = get(hObject, 'UserData');

data.text{end+1}      = text;
data.color(end+1,1:3) = color;
data.selected(end+1)  = selected;

set(hObject, 'UserData', data);

if (length(data.text) > data.lines)
   set(hObject, 'Value', data.lines - length(data.text));
end

OnUpdateSlider(data.hScroll);



% ---------------------------------------------------------------------------
function OnAddLines(hObject, text, color, selected)
% ---------------------------------------------------------------------------
data  = get(hObject, 'UserData');

for i = 1:length(text)
   data.text{end+1}      = text{i};
   data.color(end+1,1:3) = color;
   data.selected(end+1)  = selected;
end

set(hObject, 'UserData', data);

if (length(data.text) > data.lines)
   set(hObject, 'Value', data.lines - length(data.text));
end


OnUpdateSlider(data.hScroll);



% ---------------------------------------------------------------------------
function OnSetLines(hObject, text, color, selected)
% ---------------------------------------------------------------------------
data  = get(hObject, 'UserData');

data.text     = {};
data.color    = [];
data.selected = [];

for i = 1:length(text)
   data.text{end+1}      = text{i};
   data.color(end+1,1:3) = color;
   data.selected(end+1)  = selected;
end

set(hObject, 'UserData', data, 'Value', 0);
OnUpdateSlider(data.hScroll)



% ---------------------------------------------------------------------------
function OnDelete(hObject)
% ---------------------------------------------------------------------------
data  = get(hObject, 'UserData');

% Delete all associated text lines
for i=1:length(data.hText)
   delete(data.hText(i));
end

% Delete the scrollbar
delete(hObject);
