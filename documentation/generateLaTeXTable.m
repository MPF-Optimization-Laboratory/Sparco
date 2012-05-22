function generateLaTeXTable(t, datadir)
% T is a structure containing
% .title       (optional)
% .filename    
% .celldata    String values of the cell contents
% .celltype    m = Math
%              c = center
%              l = left
%              r = right
%              1 = top line
%              2 = right line
%              3 = bottom line
%              4 = left line
%              B = bold

if nargin < 2, datadir = ''; end

fd = fopen(sprintf('%s%s.tex', datadir, t.filename),'w');
if (fd == -1)
  error('Error opening file for writing');
end

% Return on empty table
rows = size(t.celldata,1);
cols = size(t.celldata,2);
if (rows == 1) || (cols == 1)
  return
end

% Get default column alignment
tAlign = repmat(' ',rows,cols);
tLines = zeros(rows,cols,4);
for i=1:rows
  for j=1:cols
    tAlign(i,j)   = getAlign(t.celltype{i,j});
    tLines(i,j,:) = getLines(t.celltype{i,j});
    if (j > 1)
      m = max(tLines(i,j-1,2),tLines(i,j,4));
      tLines(i,j-1,2) = m;
      tLines(i,j,  4) = m;
    end
    if (i > 1)
      m = max(tLines(i-1,j,3),tLines(i,j,1));
      tLines(i-1,j,3) = m;
      tLines(i,  j,1) = m;
    end
  end
end


% Open the tabular environment
def = repmat('|',tLines(1,1,4));
for i=1:cols
  def = [def, tAlign(1,i)];
  def = [def, repmat('|',1,tLines(1,i,2))];
end
fprintf(fd,'\\begin{tabular}{%s}\n',def);


% Output top lines
outputLines_intrnl(fd,tLines(1,:,1));

% Output the rows and internal horizontal lines
for i=1:rows
  

  for j=1:cols

    if (j ~= 1)
      fprintf(fd,' & ');
    end

    realign = '';
    if ((tAlign(i,j)   ~= tAlign(1,j)) || ...
        (tLines(i,j,2) ~= tLines(1,j,2)) || ...
        ((tLines(i,j,4) ~= tLines(1,j,4)) && j==1))
       % Create the new type string
       realign = '';

       % Only output left bars when in first column
       if (i == 1)
         realign = [realign, repmat('|',1,tLines(i,j,4))];
       end
       realign = [realign, tAlign(i,j), repmat('|',1,tLines(i,j,2))];
       
       fprintf(fd,'\\multicolumn{1}{%s}{',realign);
    end
    
    % Format and output cell contents
    mathmode = getMathmode(t.celltype{i,j});
    boldface = getBoldface(t.celltype{i,j});
    if (mathmode), fprintf(fd,'$'); end;
    if (boldface)
      if (mathmode)
        fprintf(fd,'\\mathbf{');
      else
        fprintf(fd,'{\bf ');
      end
    end
    fprintf(fd,'%s',t.celldata{i,j});
    if (boldface)
      fprintf(fd,'}');
    end
    if (mathmode), fprintf(fd,'$'); end;
    
    if ~isempty(realign)
      fprintf(fd,'}');
    end
  end
  fprintf(fd,'\\\\\n');
  
  % Output horizontal separators at the bottom
  outputLines_intrnl(fd,tLines(i,:,3));
end

% Close the tabular environment
fprintf(fd,'\\end{tabular}\n');

fclose(fd);



function v = getAlign(celltype)
  t   = ['l' celltype];
  idx = max([strfind(t,'l'),strfind(t,'c'),strfind(t,'r')]);
  v   = t(idx);

function v = getLines(celltype)
  v = [sum(celltype == '1'), sum(celltype == '2'), ...
       sum(celltype == '3'), sum(celltype == '4')];

function v = getMathmode(celltype)
  v = sum(celltype == 'm');

function v = getBoldface(celltype)
  v = sum(celltype == 'B');
  
function outputLines_intrnl(fd,tLine)

  mn = min(tLine);
  mx = max(tLine);
    
  if (mn == mx)
    if (mn > 0)
       fprintf(fd,repmat('\\hline',1,mn));
       fprintf(fd,'\n');
    end
  else
    % todo
  end
