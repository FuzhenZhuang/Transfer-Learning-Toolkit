function result = TLDA_test(train_predict, test_predict, trainlabel, testlabel)
    % test the train data
    result = zeros(1,2);
    [pro label] = max(train_predict);
    templabel = trainlabel(1,:);
    result(1,1) = mean(label(:) == templabel(:));
    
    % test the test data    
    [pro label] = max(test_predict);
    templabel = testlabel(1,:);
    result(1,2) = mean(label(:) == templabel(:));
end