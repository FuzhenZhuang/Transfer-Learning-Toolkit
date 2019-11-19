function results = CCR3_enterFunc(gamma, inputPath)
     %% ======================================================================
    %%STEP 1: load the data
    fprintf('start load the data...\n');
    load(inputPath);
%     TrainLabel(TrainLabel==0) = -1;
    
    if strcmp(class(TrainData),'cell')
        for x = 1:size(TrainData,2)
            TrainData{1,x} = TrainData{1,x}';
            tem = TrainLabel{1,x};
            TrainLabel{1,x}(tem==0) = -1;
        end
        traindata = TrainData;
        trainlabel = TrainLabel;
    else
        TrainData = TrainData';
        TrainLabel(TrainLabel==0) = -1;
        traindata{1,1} = TrainData;
        trainlabel{1,1} = TrainLabel;
    end
    if strcmp(class(TestData),'cell')
        tem = TestLabel{1,1};
        TestLabel{1,1}(tem==0) = -1;
        testdata = TestData;
        testlabel = TestLabel;
    else
        TestLabel(TestLabel==0) = -1;
        testdata{1,1} = TestData;
        testlabel{1,1} = TestLabel;
    end
    
     %% ======================================================================
    %%STEP 2: train the model    
    results=CCR(traindata, testdata, trainlabel, testlabel, gamma);
end