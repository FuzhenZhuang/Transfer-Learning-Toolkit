function result = CRA_test(traindata, testdata, trainlabel, testlabel, numX, numS, C)
    %% use the model test the target domain data

    % test the train data
    result = zeros(1,7);
    iCnt = 1;
    for i = 1 : numS
        temp_hiddeninputs = traindata(:,numX(1,i)+1 : 1 : numX(1,i+1));
        probability = 1./(1+1./(exp(C(i,:)*temp_hiddeninputs)));
        probability(probability >= 0.5) = 1;
        probability(probability < 0.5) = -1;
        templabel = trainlabel(:,numX(1,i)+1 : 1 : numX(1,i+1));
        result(1,iCnt) = mean(probability(:) == templabel(:));
        iCnt = iCnt+1;
    end
    
    % test the test data
    sum_probability = zeros(1,size(testdata,2));
    for i = 1 : numS
        probability = 1./(1+1./(exp(C(i,:)*testdata)));
        sum_probability = sum_probability + probability;
        probability(probability >= 0.5) = 1;
        probability(probability < 0.5) = -1;
        result(1,iCnt) = mean(probability(:) == testlabel(:));
        iCnt = iCnt+1;
    end
    sum_probability = sum_probability/3;
    sum_probability(sum_probability >= 0.5) = 1;
    sum_probability(sum_probability < 0.5) = -1;
    result(1,iCnt) = mean(sum_probability(:) == testlabel(:));
end