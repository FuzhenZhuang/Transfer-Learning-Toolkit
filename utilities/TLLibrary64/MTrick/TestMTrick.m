clear all;

TrainX = load('Train.data');
TrainX = spconvert(TrainX);
TrainY = load('Train.label');
TrainY = TrainY';
TestX = load('Test.data');
TestX = spconvert(TestX);
TestY = load('Test.label');
TestY = TestY';

for id = 1:length(TrainY)
    if TrainY(id) == 2
        TrainY(id) = -1;
    end
end

for id = 1:length(TestY)
    if TestY(id) == 2
        TestY(id) = -1;
    end
end

alpha = 1;
beta = 1.5;
numK = 50;
numCircle = 100;
Results = MTrick(TrainX,TrainY,TestX,TestY,alpha,beta,numK,numCircle);
