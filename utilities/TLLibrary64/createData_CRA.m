function [TrainData, TestData, TrainLabel, TestLabel, numX] = createData_CRA()
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
        TrainY1(1,i+n1) = -1;
    end
    TrainX1 = [Cc;D];
    clear Cc;
    clear D;
    % load source domain 2
    A = textread(strcat('data/img/12_color36.txt'));
    B = textread(strcat('data/img/12_texture51.txt'));
    n1 = size(A,1)/ncFeature;
    for i = 1:n1
        Cc(:,i) = A((ncFeature*(i-1)+1):ncFeature*i,1);
        D(:,i) = B((ntFeature*(i-1)+1):ntFeature*i,1);
        TrainY2(1,i) = 1;
    end
    A = textread(strcat('data/img/16_color36.txt'));
    B = textread(strcat('data/img/16_texture51.txt'));
    n2 = size(A,1)/ncFeature;
    for i = 1:n2
        Cc(:,i+n1) = A((ncFeature*(i-1)+1):ncFeature*i,1);
        D(:,i+n1) = B((ntFeature*(i-1)+1):ntFeature*i,1);
        TrainY2(1,i+n1) = -1;
    end
    TrainX2 = [Cc;D];
    clear Cc;
    clear D;
    % load source domain 3
    A = textread(strcat('data/img/13_color36.txt'));
    B = textread(strcat('data/img/13_texture51.txt'));
    n1 = size(A,1)/ncFeature;
    for i = 1:n1
        Cc(:,i) = A((ncFeature*(i-1)+1):ncFeature*i,1);
        D(:,i) = B((ntFeature*(i-1)+1):ntFeature*i,1);
        TrainY3(1,i) = 1;
    end
    A = textread(strcat('data/img/17_color36.txt'));
    B = textread(strcat('data/img/17_texture51.txt'));
    n2 = size(A,1)/ncFeature;
    for i = 1:n2
        Cc(:,i+n1) = A((ncFeature*(i-1)+1):ncFeature*i,1);
        D(:,i+n1) = B((ntFeature*(i-1)+1):ntFeature*i,1);
        TrainY3(1,i+n1) = -1;
    end
    TrainX3 = [Cc;D];
    clear Cc;
    clear D;
    % load target domain
    A = textread(strcat('data/img/14_color36.txt'));
    B = textread(strcat('data/img/14_texture51.txt'));
    n1 = size(A,1)/ncFeature;
    for i = 1:n1
        Cc(:,i) = A((ncFeature*(i-1)+1):ncFeature*i,1);
        D(:,i) = B((ntFeature*(i-1)+1):ntFeature*i,1);
        TestY(1,i) = 1;
    end
    A = textread(strcat('data/img/18_color36.txt'));
    B = textread(strcat('data/img/18_texture51.txt'));
    n2 = size(A,1)/ncFeature;
    for i = 1:n2
        Cc(:,i+n1) = A((ncFeature*(i-1)+1):ncFeature*i,1);
        D(:,i+n1) = B((ntFeature*(i-1)+1):ntFeature*i,1);
        TestY(1,i+n1) = -1;
    end
    TestX = [Cc;D];

    clear A B Cc D;

    %% normalization
    column = size(TrainX1,2);
    mode_TrainX = sqrt(sum(TrainX1.*TrainX1,1));
    for i = 1 : column
        TrainX1(:,i) = TrainX1(:,i)/mode_TrainX(1,i);
    end
    column = size(TrainX2,2);
    mode_TrainX = sqrt(sum(TrainX2.*TrainX2,1));
    for i = 1 : column
        TrainX2(:,i) = TrainX2(:,i)/mode_TrainX(1,i);
    end
    column = size(TrainX3,2);
    mode_TrainX = sqrt(sum(TrainX3.*TrainX3,1));
    for i = 1 : column
        TrainX3(:,i) = TrainX3(:,i)/mode_TrainX(1,i);
    end
    TrainData{1,1} = TrainX1;
    TrainLabel{1,1} = TrainY1;
    TrainData{1,2} = TrainX2;
    TrainLabel{1,2} = TrainY2;
    TrainData{1,3} = TrainX3;
    TrainLabel{1,3} = TrainY3;
    
    column = size(TestX,2);
    mode_TestX = sqrt(sum(TestX.*TestX,1));
    for i = 1 : column
        TestX(:,i) = TestX(:,i)/mode_TestX(1,i);
    end
    TestData{1,1} = TestX;
    TestLabel{1,1} = TestY;
    save inputData.mat TrainData TrainLabel TestData TestLabel
end