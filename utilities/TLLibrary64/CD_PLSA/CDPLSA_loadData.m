function [TrainX, TestX, TrainY, TestY, numSource, numTrain, numTarget, numTest] = CDPLSA_loadData(inputPath)
    load(inputPath);
    traindata{1,1} = TrainData;
    trainlabel{1,1} = TrainLabel;
    testdata{1,1} = TestData;
    testlabel{1,1} = TestLabel;
    numSource = size(traindata,2);                              % number of train file
    numTrain = zeros(1,numSource);
    TrainX = [];
    TrainY = [];
    for i = 1 : length(numTrain)
        numTrain(1,i) = size(traindata{1,i},2);
        TrainX = [TrainX traindata{1,i}];
        TrainY = [TrainY trainlabel{1,i}];
    end
    
    numTarget = size(testdata,2);                              % number of train file
    numTest = zeros(1,numTarget);
    TestX = [];
    TestY = [];
    for i = 1 : length(numTest)
        numTest(1,i) = size(testdata{1,i},2);
        TestX = [TestX testdata{1,i}];
        TestY = [TestY testlabel{1,i}];
    end
end