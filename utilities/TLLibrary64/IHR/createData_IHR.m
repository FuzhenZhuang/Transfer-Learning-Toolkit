function [TrainData, TestData, TrainLabel, TestLabel] = createData_IHR()
    TrainData = load('D:\chengxh\matlab\TLLibrary64\IHR\data\Train1.data');
    TrainData = spconvert(TrainData);
    TrainLabel = load('D:\chengxh\matlab\TLLibrary64\IHR\data\Train1.label');
    TestData = load('D:\chengxh\matlab\TLLibrary64\IHR\data\Test1.data');
    TestData = spconvert(TestData);
    TestLabel = load('D:\chengxh\matlab\TLLibrary64\IHR\data\Test1.label');

%     column = size(TrainData,2);
%     mode_TrainX = sqrt(sum(TrainData.*TrainData,1));
%     for i = 1 : column
%         TrainData(:,i) = TrainData(:,i)/mode_TrainX(1,i);
%     end
%     column = size(TestData,2);
%     mode_TestX = sqrt(sum(TestData.*TestData,1));
%     for i = 1 : column
%         TestData(:,i) = TestData(:,i)/mode_TestX(1,i);
%     end
    
    save inputData.mat TrainData TrainLabel TestData TestLabel;
end