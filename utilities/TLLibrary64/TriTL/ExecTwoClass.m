%% This is demo to run the data set rec vs. sci (including 144 problems)
%% For one source domain and one target domain
%%
clear all;
warning off

array1 = [8 9 10 11]; % the top category rec
array2 = [12 13 14 15]; % the top category sci
combinations = [];
index = 1;
for i1 = 1:length(array1)
    for j1 = 1:length(array2)
        for i2 = 1:length(array1)
            for j2 = 1:length(array2)
                if i2 == i1 || j2 == j1
                    continue;
                end
                combinations(index,1) = array1(i1);
                combinations(index,2) = array2(j1);
                combinations(index,3) = array1(i2);
                combinations(index,4) = array2(j2);
                index = index + 1;
            end
        end
    end
end
Comb = combinations;

AllResults = [];
runingTimes = [];
for tt = 1:size(Comb,1)
    % source domain (train)
    A = load(strcat('data/TrainSelect_',int2str(Comb(tt,1)),'.data'));
    B = spconvert(A);
    n1 = size(B,2);
    for i = 1:n1
        TrainY1(1,i) = 1;
    end
    A1 = load(strcat('data/TrainSelect_',int2str(Comb(tt,2)),'.data'));
    B1 = spconvert(A1);
    n2 = size(B1,2);
    for i = 1:n2
        TrainY1(1,i+n1) = 2;
    end
    TrainX1 = [B,B1];
    
    A1(:,2) = A1(:,2) + n1;
    csvwrite('Train1.data',[A;A1]);
    csvwrite('Train1.label',TrainY1');
    labelset = union(TrainY1,[]);
    initialLable = rand(length(TrainY1),length(labelset))+0.2;
    for u = 1:size(initialLable,1)
        initialLable(u,:) = initialLable(u,:)/sum(initialLable(u,:));
    end
    csvwrite('Train1.initial.label',initialLable);
    clear A;
    clear B;
    clear A1;
    clear B1;
    
    % target domain (test)
    A = load(strcat('data/TrainSelect_',int2str(Comb(tt,3)),'.data'));
    B = spconvert(A);
    n1 = size(B,2);
    for i = 1:n1
        TestY(1,i) = 1;
    end
    A1 = load(strcat('data/TrainSelect_',int2str(Comb(tt,4)),'.data'));
    B1 = spconvert(A1);
    n2 = size(B1,2);
    for i = 1:n2
        TestY(1,i+n1) = 2;
    end
    TestX = [B,B1];
    
    A1(:,2) = A1(:,2) + n1;
    csvwrite('Test.data',[A;A1]);
    csvwrite('Test.label',TestY');
    labelset = union(TestY,[]);
    clear A;
    clear B;
    clear A1;
    clear B1;
    
    Train_Data = 'Train_Data.txt';
    Test_Data = 'Test_Data.txt';
    Parameter_Setting = 'Parameter_Setting.txt';
    
    fid = fopen(Train_Data,'w');
    fprintf(fid,'%s\n',num2str(1));
    fprintf(fid,'%s\n','Train1.data');
    fprintf(fid,'%s\n','Train1.label');
    fclose(fid);
    
    fid = fopen(Test_Data,'w');
    fprintf(fid,'%s\n',num2str(1));
    fprintf(fid,'%s\n','Test.data');
    fprintf(fid,'%s\n','Test.label');
    fclose(fid);
    
    fprintf('Hi, Fuzhen Zhuang!\n');
    t0 = clock;
    [Results_TTL, Gt_TTL, t1, t2] = TriTL(Train_Data,Test_Data,Parameter_Setting);  
    t3 = clock;
    time1 = t2 - t1;
    time1 = time1(6);
    time2 = t3 - t0;
    time2 = time2(6);
    time2 = time2 - time1;
    AllResults(tt,1) = tt;
    for u = 1:size(Results_TTL,2) - 1
        AllResults(tt,2*u) = Results_TTL(1,u+1);
        AllResults(tt,2*u+1) = Results_TTL(size(Results_TTL,1),u+1);
    end 
    runingTimes(tt,1) = tt;
    runingTimes(tt,2) = time1;
    runingTimes(tt,3) = time2;
    xlswrite('AllResults.xls',AllResults); % write the results
    [AllResults  runingTimes]    
    clear TrainY1;
    clear TestY;
end
