function results = CCR(TrainData, TestData, TrainLabel, TestLabel, gamma)

global TrainX;
global TrainY;
global TrainXY;
global TestX;
global TestY;
global size_sets;
global rr;

global gama;
gama = double(gamma);
ndomain = size(TrainData,2) + size(TestData,2);

%%%------------以上部分是产生所有组合，并且保存在Combs中-------------------------%%%
global index1; %记录迭代收敛的次数

%---------以下是要打印出的全局变量-------------------%
global AL; %记录各个domain对自身测试结果准确率
global AT; %记录各个domain对测试集测试的准确率
global AT0;
global Ensemble0; %记录优化前各个domain进行测试，然后Ensemble的结果
global Ensemble; %记录各个domain进行测试，然后Ensemble的结果
global Time_initial; %记录得到初始值的时间
global Time_3;  %记录总的消耗时间
AL = zeros(1,ndomain-1); %存放对本身测试的准确率
AT = zeros(1,ndomain-1); %存放对测试集测试的准确率
AT0 = zeros(1,ndomain-1); %存放未优化前对测试集的准确率
totalA = 0;
%-------------------------------------------------------------%
index1 = 0; %Inilization
%-------------------------------------------------------------%

%//////////////////////////////////////////////////
fid = fopen('outputlatex.dat','w');

Ensemble = 0;
Time_3 = 0;

size_sets = zeros(ndomain,2); %存储每个domain的特征个数及样本个数，每一行第一个数是特征数，第二个数为样本数，共有ndomain行
TrainX = [];
TrainY = [];
TrainXY = [];
for j=1:(ndomain-1)
    size_sets(j,1) = size(TrainData{1,j},1);
    size_sets(j,2) = size(TrainData{1,j},2);
    TrainX = [TrainX,TrainData{1,j}];
    TrainY = [TrainY,TrainLabel{1,j}];
    TrainXY = [TrainXY,scale_cols(TrainData{1,j},TrainLabel{1,j})];
end
size_sets(ndomain,1) = size(TestData{1,1},1);
size_sets(ndomain,2) = size(TestData{1,1},2);
TestX = TestData{1,1};
TestY = TestLabel{1,1};
fprintf('...................finish...........\n');
tstart = cputime;
W0 = mul_predict_luop(TrainXY,size_sets);
tend = cputime;
Time_initial = tend - tstart;
for i=1:ndomain-1
    tmp_1 = 0;
    if i>1
        for j=1:(i-1)
            tmp_1 = tmp_1+size_sets(j,2);
        end
    end
    tempTrainX = TrainX(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
    tempTrainY = TrainY(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
    tmp_2 = 0;
    if i>1
        for j=1:(i-1)
            tmp_2 = tmp_2+size_sets(j,1);
        end
    end
    w1 = W0((tmp_2+1):(tmp_2+size_sets(i,1)),1);
    s1 = w1'*tempTrainX;
    p1 = 1./(1 + exp(-s1));
    AL(1,i) = getResult(p1,tempTrainY);
end
%         fprintf('close test:Respective result is one:%g   two:%g  three:%g\n',AL(1,1),AL(1,2),AL(1,3));
fprintf('.....................................\n');

w00 = zeros(size(TrainX,1),1);
lambda = exp(linspace(-0.5,6,20));
f1max = -inf;
for i = 1:length(lambda)
    w_0 = train_cg(TrainXY,w00,lambda(i));
    f1 = logProb(TrainXY,w_0);
    if f1 > f1max
        f1max = f1;
        wbest = w_0;
    end
end
ptemp = 1./(1 + exp(-wbest'*TestX));
totalA = getResult(ptemp,TestY);
fprintf('total result:%g\n',totalA);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
afas = 0:0.05:0.25;
for afasindex=1:length(afas)
    afa = afas(afasindex);
    tstart = cputime;

    %[W,result] = quickDown(W0,afa,0.1);
    [W,result] = PRP_CG(W0,afa,size_sets,0.1); %size_sets记录各个domain的大小
    %[W,result] = FR_CG(W0,afa,0.1);
    tend = cputime;
    Time_3 = tend - tstart + Time_initial; %计算总的消耗时间

    for i=1:ndomain-1
        tmp_1 = 0;
        if i>1
            for j=1:(i-1)
                tmp_1 = tmp_1+size_sets(j,2);
            end
        end
        tempTrainX = TrainX(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
        tempTrainY = TrainY(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
        tmp_2 = 0;
        if i>1
            for j=1:(i-1)
                tmp_2 = tmp_2+size_sets(j,1);
            end
        end
        w1 = W((tmp_2+1):(tmp_2+size_sets(i,1)),1);
        s1 = w1'*tempTrainX;
        p1 = 1./(1 + exp(-s1));
        AL(1,i) = getResult(p1,tempTrainY);%记录为优化后对本身的预测准确率
    end

    %             fprintf('close test:Respective result is one:%g   two:%g  three:%g\n',AL(1,1),AL(1,2),AL(1,3));
end
results = rr;
clear TrainX;
clear TrainY;
clear TrainXY;
clear TestX;
clear TestY;
clear size_sets;