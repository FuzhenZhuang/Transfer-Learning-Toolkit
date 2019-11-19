function Temp_Text(datafiles,labelfiles,afa)
%datafiles = ['domain_1_7_I.txt';'domain_4_8_I.txt';'domain_5_9_I.txt';'domain_2_6_I.txt'];
%labelfiles = ['label_1_7_I.txt';'label_4_8_I.txt';'label_5_9_I.txt';'label_2_6_I.txt'];
global TrainX;
global TrainY;
global TrainXY;
global TestX;
global TestY;
global size_sets;

global gama;
gama = 145;
%data_file = datafiles;
%label_file = labelfiles;

data_file = datafiles;
label_file= labelfiles;

ndomain = size(data_file,1);


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
StrText = strcat('\begin{table} ','\centering');
fprintf(fid,'%s\n',StrText);
StrText = strcat('\caption{XXXXXXXXX}\label{tb_ss}',' \begin{scriptsize}');
fprintf(fid,'%s\n',StrText);
StrText = strcat('\begin{tabular}{@{}c c c c c c c c c c c c c c c@{}}',' \hline');
fprintf(fid,'%s\n',StrText);
StrText = strcat('\multirow{2}{*}{$\alpha$} & \multicolumn{2}{c}{Domain1} & & \multicolumn{2}{c}{Domain2}& & \multicolumn{2}{c}{Domain3} & \multirow{2}{*}{Ensemble(\%)} & \multirow{2}{*}{Time(s)}\\');
fprintf(fid,'%s\n',StrText);
StrText = strcat('\cline{2-3} \cline{5-6} \cline{8-9}',' &  AL$_{1}${(\%)} & AT$_{1}${(\%)} & &  AL$_{2}${(\%)} & AT$_{2}${(\%)} & & AL$_{3}${(\%)} & AT$_{3}${(\%)} & & ');
fprintf(fid,'%s\n',StrText);

size_sets = zeros(ndomain,2); %存储每个domain的特征个数及样本个数，每一行第一个数是特征数，第二个数为样本数，共有ndomain行
TrainX = [];
TrainY = [];
TrainXY = [];
for j=1:(ndomain-1)
    A = load(data_file(j,:));
    A = spconvert(A);
    B = textread(label_file(j,:));
    size_sets(j,1) = size(A,1);
    size_sets(j,2) = size(A,2);
    tmpnum_1 = 0;
    if j>1
        for h=1:(j-1)
            tmpnum_1 = tmpnum_1+size_sets(h,2);
        end
    end
    TrainX = [TrainX,A];
    TrainY = [TrainY,B];
    TrainXY = [TrainXY,scale_cols(A,B)];
    %TrainX(:,(tmpnum_1+1):(tmpnum_1+size(A,2))) = A;
    %TrainY(1,(tmpnum_1+1):(tmpnum_1+size(B,2))) = B;
    %TrainXY(:,(tmpnum_1+1):(tmpnum_1+size(A,2))) = scale_cols(A,B);
end
A = load(data_file(ndomain,:));
A = spconvert(A);
B = textread(label_file(ndomain,:));
size_sets(ndomain,1) = size(A,1);
size_sets(ndomain,2) = size(A,2);
TestX = A;
TestY = B;
clear A;
clear B;
fprintf('.....................................\n');
%TrainXY = scale_cols(TrainX,TrainY);
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

    if afasindex == 1
        StrText = ('\\\hline');
        fprintf(fid,'%s\n',StrText);
        StrText = strcat(num2str(0),' &');
        for dd = 1:(ndomain-1)
            StrText = strcat(StrText,num2str(AL(dd)*100),' & ',num2str(AT0(dd)*100));
            if dd < (ndomain-1)
                StrText = strcat(StrText,' & & ');
            else
                StrText = strcat(StrText,' & ');
            end
        end
        StrText = strcat(StrText,num2str(Ensemble0*100),' & ',num2str(Time_initial));
        fprintf(fid,'%s\n',StrText);
    end
    
    StrText = ('\\\hline');
    fprintf(fid,'%s\n',StrText);


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
    StrText = strcat(num2str(afa),' &');
    for dd = 1:(ndomain-1)
        StrText = strcat(StrText,num2str(AL(dd)*100),' & ',num2str(AT(dd)*100));
        if dd < (ndomain-1)
            StrText = strcat(StrText,' & & ');
        else
            StrText = strcat(StrText,' & ');
        end
    end
    StrText = strcat(StrText,num2str(Ensemble*100),' & ',num2str(Time_3));

    fprintf(fid,'%s\n',StrText);

end

StrText = strcat('\\\hline ','\end{tabular} ','\\ The accuracy of total samples-sets:' ,num2str(totalA));

StrText = strcat(StrText,' \end{scriptsize} ','\end{table} ');
fprintf(fid,'%s\n\n',StrText);

fclose(fid);

clear TrainX;
clear TrainY;
clear TrainXY;
clear TestX;
clear TestY;
clear size_sets;