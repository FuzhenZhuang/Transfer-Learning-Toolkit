%%%
%%% This function is for the produce of high dimentional matrixes 
%%%
function MP = MatrixProduce(MA,MB,stepLen)
MP = zeros(size(MA,1),size(MB,2));
numStep = fix(size(MA,2)/stepLen);
if numStep == 0
    numStep = 1;
end
step = fix(size(MA,2)/numStep);
for i = 1:numStep-1
    MP = MP + MA(:,(i-1)*step+1:i*step)*MB((i-1)*step+1:i*step,:);
end
MP = MP + MA(:,(numStep-1)*step+1:size(MA,2))*MB((numStep-1)*step+1:size(MA,2),:);

