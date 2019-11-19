function result = TLDA_enterFunc(alpha,beta,gamma,numK,maxIter,flag,inputPath)
    %% ======================================================================
    %%STEP 1: load the data
    fprintf('start load the data...\n');
    [TrainData, TestData, TrainLabel, TestLabel] = TLDA_loadData(inputPath);

    labelset = union(TestLabel,[]);
    numC = length(labelset);
    numM = size(TrainData,1);                % input data feature dimensions
    numX = zeros(1,numC+1);
    for i = 1 : numC
        label_i = size(TrainLabel(TrainLabel==i),2);
        numX(1,i+1) = numX(1,i) + label_i;
    end

    %% ======================================================================
    %%STEP 2: Initialize the parameter
    fprintf('start initialize the parameter...\n');
    theta = TLDA_initialize_SAE(numK, numM, numC,TrainData,TestData);    % Randomly initialize the parameters  

    %% ======================================================================
    %%STEP 3: Training the parameters W1 W2 W11 W22 b1 b2 b11 b22
    fprintf('start training the parameter...\n');
    [opttheta, cost] = TLDA_Train(numM,numK,numC,numX,maxIter,alpha,beta,gamma,TrainData,TestData,theta);
    
    %% ======================================================================
    %%STEP4: get parameters W1 W2 W11 W22 b1 b2 b11 b22 after training
    fprintf('get the parameter...\n');
    W1 = reshape(opttheta(1:numK*numM), numK, numM);
    W2 = reshape(opttheta(numK*numM+1:numK*numM+numK*numC), numC, numK);
    b1 = opttheta(2*numK*numM+2*numK*numC+1:2*numK*numM+2*numK*numC+numK);
    b2 = opttheta(2*numK*numM+2*numK*numC+numK+1:2*numK*numM+2*numK*numC+numK+numC);
    
    %% ======================================================================
    %%STEP4: Testing
    fprintf('testing the model...\n');
    hiddeninputs_train = sigmoid(W1 * TrainData + b1 * ones(1, size(TrainData,2)));
    hiddeninputs_test = sigmoid(W1 * TestData + b1 * ones(1, size(TestData,2)));
    if flag == 1
        label_train = sigmoid(W2 * hiddeninputs_train + b2 * ones(1, size(hiddeninputs_train,2)));
        label_test = sigmoid(W2 * hiddeninputs_test + b2 * ones(1, size(hiddeninputs_test,2)));
        predict = TLDA_test(label_train, label_test, TrainLabel, TestLabel);
    else
        predict = TLDA_test_LR(hiddeninputs_train, hiddeninputs_test, TrainLabel, TestLabel);
    end
    result=predict;
    clear hiddeninputs_train hiddeninputs_test
end