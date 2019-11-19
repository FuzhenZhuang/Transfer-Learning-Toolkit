function f = objfun(beta)
%%%%%
global TestX;
global TrainXY;
%%%%%%
global d0;
global tempW0;
global size_sets;
global afa;
global gama;
%%%%%
tempw = tempW0 + beta*d0;

ndomain = size(size_sets,1);
vp = zeros(ndomain-1,size(TestX,2));
sump = 0;
for i=1:(ndomain-1)
    tmp_1 = 0;
    if i>1
        for j=1:(i-1)
            tmp_1 = tmp_1+size_sets(j,2);
        end
    end
    %tempTrainX = TrainX(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
    %tempTrainY = TrainY(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
    tempTrainXY = TrainXY(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
    tmp_2 = 0;
    if i>1
        for j=1:(i-1)
            tmp_2 = tmp_2+size_sets(j,1);
        end
    end
    w1 = tempw((tmp_2+1):(tmp_2+size_sets(i,1)),1);
    s1 = w1'*tempTrainXY;
    p1 = 1./(1 + exp(-s1));
    %080224modify
    ii = find(p1 > 0.00001);
    p1 = log(p1(ii));
    
    sump = sump + sum(p1);
    s1 = w1'*TestX;
    p1 = 1./(1 + exp(-s1));
    vp(i,:) = p1;
end
p = sum(vp)/(ndomain-1);
if ndomain == 2
        p = p1;
end
f = -(sump+afa*(2*p-1)*(2*p-1)'-0.5*gama*(tempw'*tempw)); %07-12-31
