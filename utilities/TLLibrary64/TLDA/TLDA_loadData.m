function [TrainX, TestX, TrainY, TestY] = TLDA_loadData(inputPath)
    load(inputPath);
    TrainX = TrainData;
    TrainY = TrainLabel;
    TestX = TestData;
    TestY = TestLabel;
end