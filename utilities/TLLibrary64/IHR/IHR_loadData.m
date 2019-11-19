function [TrainX, TestX, TrainY, TestY] = IHR_loadData(inputPath)
    load(inputPath);
    TrainX = TrainData;
    TrainY = TrainLabel;
    TestX = TestData;
    TestY = TestLabel;
end