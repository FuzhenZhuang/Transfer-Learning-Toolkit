TrainData = load('Train.data');
TrainData = spconvert(TrainData);
TrainLabel = load('Train.label');
TrainLabel = TrainLabel';
TestData = load('Test.data');
TestData = spconvert(TestData);
TestLabel = load('Test.label');
TestLabel = TestLabel';

save TestLabel.mat TestLabel
save TrainLabel.mat TrainLabel
save TrainData.mat TrainData
save TestData.mat TestData