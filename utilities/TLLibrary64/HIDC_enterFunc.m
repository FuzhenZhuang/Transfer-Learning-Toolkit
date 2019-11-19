function result = HIDC_enterFunc(numIdentical,numAlike,numDistinct,numIter,inputPath)
    %% ======================================================================
    %%STEP 1: load the data
    fprintf('start load the data...\n');
%     fprintf(inputPath);
%     fprintf('\n');
    [TrainData, TestData, TrainLabel, TestLabel, numSource, numTrain, numTarget, numTest] = HIDC_loadData(inputPath);
      TrainData = double(TrainData);
      TestData = double(TestData);
      TrainLabel = double(TrainLabel);
      TestLabel = double(TestLabel);
      
      TrainData = sparse(TrainData);
      TestData = sparse(TestData);

    fprintf('training the model and testing...\n');
    [Results_TTL, Gt_TTL] = GenerativeTriTL(TrainData, TestData, TrainLabel, TestLabel, numIdentical, numAlike, numDistinct, numIter, numSource, numTrain, numTarget, numTest); 

    result = Results_TTL(:,2)';
    result = result(end);
end