function [TrainX, TestX, TrainY] = MTrick_loadData(inputPath)
    load(inputPath);
    TrainX = TrainData;
    TrainY = TrainLabel;
    TestX = TestData;
end