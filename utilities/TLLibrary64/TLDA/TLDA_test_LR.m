function result = TLDA_test_LR(traindata, testdata, trainlabel, testlabel)
    %% use the model test the target domain data
    tempTrainXY = scale_cols(traindata, trainlabel);
    
    % train the classifier
    c00 = zeros(size(tempTrainXY,1),1);
    lambdaLG = exp(linspace(-0.5,6,20));
    wbest=c00;
    f1max = -inf;
    for j = 1 : length(lambdaLG)
        c_0 = train_cg(tempTrainXY,c00,lambdaLG(j));
        f1 = logProb(tempTrainXY,c_0);
        if f1 > f1max
            f1max = f1;
            wbest = c_0;
        end
    end
    C = wbest;

    result = zeros(1,2);
    % test the train data   
    probability = 1./(1+1./(exp(C'*traindata)));
    probability(probability >= 0.5) = 1;
    probability(probability < 0.5) = -1;
    result(1,1) = mean(probability(:) == trainlabel(:));
    
    % test the test data    
    probability = 1./(1+1./(exp(C'*testdata)));
    probability(probability >= 0.5) = 1;
    probability(probability < 0.5) = -1;
    result(1,2) = mean(probability(:) == testlabel(:));  