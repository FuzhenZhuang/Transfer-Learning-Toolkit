function [TrainData, TestData, TrainLabel, TestLabel] = createData_CDPLSA()
   
    % load source domain 1
    A = csvread('CD_PLSA/data/Train1.data');
    TrainX1 = spconvert(A);
    C = textread('CD_PLSA/data/Train1.label');
    TrainY1 = C';
    % load source domain 2
    A = csvread('CD_PLSA/data/Train2.data');
    TrainX2 = spconvert(A);
    C = textread('CD_PLSA/data/Train2.label');
    TrainY2 = C';
    % load source domain 3
    A = csvread('CD_PLSA/data/Train3.data');
    TrainX3 = spconvert(A);
    C = textread('CD_PLSA/data/Train3.label');
    TrainY3 = C';
    
    % load target domain
    A = csvread('CD_PLSA/data/Test.data');
    TestX = spconvert(A);
    C = textread('CD_PLSA/data/Test.label');
    TestY = C';
    
    TrainData{1,1} = TrainX1;
    TrainLabel{1,1} = TrainY1;
    TrainData{1,2} = TrainX2;
    TrainLabel{1,2} = TrainY2;
    TrainData{1,3} = TrainX3;
    TrainLabel{1,3} = TrainY3;
    TestData{1,1} = TestX;
    TestLabel{1,1} = TestY;
    save inputData.mat TrainData TrainLabel TestData TestLabel
    clear TrainX1 TrainX2 TrainX3 TrainY1 TrainY2 TrainY3 TestX TestY
end