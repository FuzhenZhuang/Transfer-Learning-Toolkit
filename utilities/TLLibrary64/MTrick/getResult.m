function result = getResult(s,Y)
nCorrect = 0;
for i = 1:length(s)
    if s(i) > 0.5 & Y(i) ~= -1
        nCorrect = nCorrect + 1;
    end
    if s(i) < 0.5 & Y(i) ~= 1
         nCorrect = nCorrect + 1;
    end
end
result = nCorrect/length(s);