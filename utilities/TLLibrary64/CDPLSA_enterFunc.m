function result = CDPLSA_enterFunc(numCluster,numIter,inputPath)
    %% ======================================================================
    %%STEP 1: load the data
    fprintf('start load the data...\n');
     [TrainData, TestData, TrainLabel, TestLabel, numSource, numTrain, numTarget, numTest] = CDPLSA_loadData(inputPath);
%     [TrainData, TestData, TrainLabel, TestLabel, numSource, numTrain, numTarget, numTest] = original_loadData(inputPath);
     TrainData = double(TrainData);
      TestData = double(TestData);
      TrainLabel = double(TrainLabel);
      TestLabel = double(TestLabel);
    TrainData = sparse(TrainData);
     TestData = sparse(TestData);
    fprintf('training the model and testing...\n');
    [Results, pz_d] = CD_PLSA(TrainData, TestData, TrainLabel, TestLabel, numCluster, numIter, numSource, numTrain, numTarget, numTest); 

    result = Results(end);
end