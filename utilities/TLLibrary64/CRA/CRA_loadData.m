function [TrainX, TestX, TrainY, TestY, numX, numS] = CRA_loadData(inputPath)
    load(inputPath);
    numS = size(TrainData,2);                              % number of train file
    numX = zeros(1,numS+2);
    for i = 2 : length(numX)-1
        numX(1,i) = numX(1,i-1) + size(TrainData{1,i-1},2);
    end
    numX(1,i+1) = numX(1,i) + size(TestData{1,1},2);
    TrainX = [];
    TrainY = [];
    for i = 1 : numS
        TrainX = [TrainX TrainData{1,i}];
        TrainY = [TrainY TrainLabel{1,i}];
    end
    TestX = TestData{1,1};
    TestY = TestLabel{1,1};
end