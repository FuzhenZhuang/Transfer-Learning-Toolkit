function result = CRA_enterFunc(alpha,beta,gamma,lambda,numK,maxIter,flag,inputPath)

    %% ======================================================================
    %%STEP 1: load the data
    fprintf('start load the data...\n');
    [TrainData, TestData, TrainLabel, TestLabel, numX, numS] = CRA_loadData(inputPath);

    numM = size(TrainData,1);                % input data feature dimensions
    
    %% ======================================================================
    %%STEP 2: Initialize the parameter
    fprintf('start initialize the parameter...\n');
    theta = CRA_initialize(numK, numM, numS, numX,TrainData,TrainLabel,TestData);    % Randomly initialize the parameters  

    %% ======================================================================
    %%STEP 3: Training the parameters W1 W2 b1 b2 C
    fprintf('start training the parameter...\n');
    [opttheta, cost] = CRA_Train(numM,numK,numS,numX,maxIter,alpha,beta,gamma,lambda,TrainData,TestData,TrainLabel,theta);
    
    %% ======================================================================
    %%STEP4: get parameters W1 W2 W11 W22 b1 b2 b11 b22 after training
    fprintf('get the parameter...\n');
    W1 = reshape(opttheta(1:numK*numM), numK, numM);
    b1 = opttheta(2*numK*numM+1:2*numK*numM+numK);
    C = reshape(opttheta(2*numK*numM+numK+numM+1:end), numS, numK);
    
    %% ======================================================================
    %%STEP4: Testing
    fprintf('testing the model...\n');
    hiddeninputs_train = sigmoid(W1 * TrainData + b1 * ones(1, size(TrainData,2)));
    hiddeninputs_test = sigmoid(W1 * TestData + b1 * ones(1, size(TestData,2)));
    if flag == 1
        predict = CRA_test(hiddeninputs_train, hiddeninputs_test, TrainLabel, TestLabel, numX, numS, C);
    else
        predict = CRA_test_LR(hiddeninputs_train, hiddeninputs_test, TrainLabel, TestLabel, numX, numS);
    end
    result=predict;
    clear hiddeninputs_train hiddeninputs_test
end