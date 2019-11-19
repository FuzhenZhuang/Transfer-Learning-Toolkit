clear all;
warning off;
% WARNING('OFF',msgID);

array1 = [8 9 10 11];
array2 = [12 13 14 15];
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

for triID = 1:10

AllResults = [];
for tt = 1:size(Comb,1)
    % domain1
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
    clear A;
    clear B;
    clear A1;
    clear B1;
    
    % test domain
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
    
    fid = fopen(strcat('lg_models/',num2str(tt),'_model_lg.model'),'r');
    fid1 = fopen(strcat('lg_models/','model_lg.model'),'w');
    while feof(fid) == 0
        sline = fgetl(fid);
        fprintf(fid1,'%s\n',sline);
    end
    fclose(fid1);
    fclose(fid);    
    
    fprintf('Hi, Fuzhen Zhuang!\n');
    [Results_TTL, Gt_TTL] = GenerativeTriTL(Train_Data,Test_Data,Parameter_Setting);
    AllResults(tt,1) = tt;
    AllResults(tt,2) = Results_TTL(1,2);
    AllResults(tt,3) = Results_TTL(size(Results_TTL,1),2);
    
    AllResults
    
    clear TrainY1;
    clear TestY;
end
end

