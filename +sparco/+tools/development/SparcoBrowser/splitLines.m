function text = splitLines(rawtext)

idx = [0 find(int16(rawtext) == 10) length(rawtext)+1];

text = {};
for i=length(idx):-1:2
   if (idx(i) == idx(i-1)+1), idx = [idx(1:i-2) idx(i:end)]; end;
end

for i = 2:length(idx)
   text{i-1} = rawtext((idx(i-1)+1):(idx(i)-1));
end
