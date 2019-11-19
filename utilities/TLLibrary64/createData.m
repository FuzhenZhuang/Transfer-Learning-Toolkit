function [TrainData, TestData, TrainLabel, TestLabel, numX] = createData()
    ncFeature = 36;  % features of color
    ntFeature = 51;  % features of text

    % load source domain 1
    A = textread(strcat('data/img/11_color36.txt'));
    B = textread(strcat('data/img/11_texture51.txt'));
    n1 = size(A,1)/ncFeature;
    for i = 1:n1
        Cc(:,i) = A((ncFeature*(i-1)+1):ncFeature*i,1);
        D(:,i) = B((ntFeature*(i-1)+1):ntFeature*i,1);
        TrainY1(1,i) = 1;
    end
    A = textread(strcat('data/img/15_color36.txt'));
    B = textread(strcat('data/img/15_texture51.txt'));
    n2 = size(A,1)/ncFeature;
    for i = 1:n2
        Cc(:,i+n1) = A((ncFeature*(i-1)+1):ncFeature*i,1);
        D(:,i+n1) = B((ntFeature*(i-1)+1):ntFeature*i,1);
        TrainY1(1,i+n1) = 2;
    end
    numX = [n1,n2];
    TrainX1 = [Cc;D];
    clear Cc;
    clear D;
    % load target domain
    A = textread(strcat('data/img/12_color36.txt'));
    B = textread(strcat('data/img/12_texture51.txt'));
    n1 = size(A,1)/ncFeature;
    for i = 1:n1
        Cc(:,i) = A((ncFeature*(i-1)+1):ncFeature*i,1);
        D(:,i) = B((ntFeature*(i-1)+1):ntFeature*i,1);
        TestY(1,i) = 1;
    end
    A = textread(strcat('data/img/16_color36.txt'));
    B = textread(strcat('data/img/16_texture51.txt'));
    n2 = size(A,1)/ncFeature;
    for i = 1:n2
        Cc(:,i+n1) = A((ncFeature*(i-1)+1):ncFeature*i,1);
        D(:,i+n1) = B((ntFeature*(i-1)+1):ntFeature*i,1);
        TestY(1,i+n1) = 2;
    end
    TestX = [Cc;D];

    clear A B Cc D;

    %% normalization
    TrainData = TrainX1;
    TrainLabel = TrainY1;
    TestData = TestX;
    TestLabel = TestY;
    column = size(TrainData,2);
    mode_TrainX = sqrt(sum(TrainData.*TrainData,1));
    for i = 1 : column
        TrainData(:,i) = TrainData(:,i)/mode_TrainX(1,i);
    end
    column = size(TestData,2);
    mode_TestX = sqrt(sum(TestData.*TestData,1));
    for i = 1 : column
        TestData(:,i) = TestData(:,i)/mode_TestX(1,i);
    end
    save TrainData.mat TrainData
    save TrainLabel.mat TrainLabel
    save TestData.mat TestData
    save TestLabel.mat TestLabel
    clear TrainX1 TrainY1 TestX TestY
end