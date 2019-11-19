function [TrainData, TestData, TrainLabel, TestLabel] = createData_HIDC()
    % source domain (train)
    A = load(strcat('data/TrainSelect_8.data'));
    B = spconvert(A);
    n1 = size(B,2);
    for i = 1:n1
        TrainY1(1,i) = 1;
    end
    A1 = load(strcat('data/TrainSelect_12.data'));
    B1 = spconvert(A1);
    n2 = size(B1,2);
    for i = 1:n2
        TrainY1(1,i+n1) = 2;
    end
    TrainX1 = [B,B1];
    clear A B A1 B1;
    
    A = load(strcat('data/TrainSelect_9.data'));
    B = spconvert(A);
    n1 = size(B,2);
    for i = 1:n1
        TrainY2(1,i) = 1;
    end
    A1 = load(strcat('data/TrainSelect_13.data'));
    B1 = spconvert(A1);
    n2 = size(B1,2);
    for i = 1:n2
        TrainY2(1,i+n1) = 2;
    end
    TrainX2 = [B,B1];
    clear A B A1 B1;
    
    A = load(strcat('data/TrainSelect_10.data'));
    B = spconvert(A);
    n1 = size(B,2);
    for i = 1:n1
        TrainY3(1,i) = 1;
    end
    A1 = load(strcat('data/TrainSelect_14.data'));
    B1 = spconvert(A1);
    n2 = size(B1,2);
    for i = 1:n2
        TrainY3(1,i+n1) = 2;
    end
    TrainX3 = [B,B1];
    clear A B A1 B1;
    
    % target domain (test)
    A = load(strcat('data/TrainSelect_11.data'));
    B = spconvert(A);
    n1 = size(B,2);
    for i = 1:n1
        TestY(1,i) = 1;
    end
    A1 = load(strcat('data/TrainSelect_15.data'));
    B1 = spconvert(A1);
    n2 = size(B1,2);
    for i = 1:n2
        TestY(1,i+n1) = 2;
    end
    TestX = [B,B1];
    clear A B A1 B1;
    
    TrainData{1,1} = TrainX1;
    TrainLabel{1,1} = TrainY1;
    TrainData{1,2} = TrainX2;
    TrainLabel{1,2} = TrainY2;
    TrainData{1,3} = TrainX3;
    TrainLabel{1,3} = TrainY3;
    TestData{1,1} = TestX;
    TestLabel{1,1} = TestY;
    save inputData.mat TrainData TrainLabel TestData TestLabel
end