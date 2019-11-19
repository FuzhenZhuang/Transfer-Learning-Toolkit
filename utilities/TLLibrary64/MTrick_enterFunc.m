function result = MTrick_enterFunc(alpha,beta,numCluster,maxIter,inputPath)
    %% ======================================================================
    %%STEP 1: load the data
    fprintf('start load the data...\n');
%     TrainData = load('MTrick/Train.data');
%     TrainData = spconvert(TrainData);
%     TrainLabel = load('MTrick/Train.label');
%     TrainLabel = TrainLabel';
%     TestData = load('MTrick/Test.data');
%     TestData = spconvert(TestData);
%     TestLabel = load('MTrick/Test.label');
%     TestLabel = TestLabel';
    [TrainData, TestData, TrainLabel] = MTrick_loadData(inputPath);
    TrainData = double(TrainData);
    TestData = double(TestData);
    TrainLabel = double(TrainLabel);
%     
%     TrainData = sparse(TrainData);
%     TestData = sparse(TestData);
%     
%     mex -largeArrayDims mex_Pw_d.c
%     mex -largeArrayDims mex_EMstep.c
%     mex -largeArrayDims mex_logL.c
    TrainData = sparse(TrainData);
    TestData = sparse(TestData);

    result = MTrick1(TrainData,TrainLabel,TestData,alpha,beta,numCluster,maxIter);
end