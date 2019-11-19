%TrainX is dataset of trainset, which size is d x n, d is the size of dimensions, n is the size of dataset
%TrainY is label of trainset, which size is 1 x n
%TestX, TestY are the similar statement as above
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%只能处理每个domain特征数相同的情况
function W = mul_predict_luop(TrainXY,size_sets)
%global TrainXY;
ndomain = size(size_sets,1);
lambda1 = exp(linspace(-0.5,6,20));
for i=1:(ndomain-1)
    tmp_1 = 0;
    if i>1
        for j=1:(i-1)
            tmp_1 = tmp_1+size_sets(j,2);
        end
    end
    %tempTrainX = TrainX(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
    %tempTrainY = TrainY(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
    tempTrainXY = TrainXY(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
    %tempTrainXY = scale_cols(tempTrainX,tempTrainY);
    %find the best lambda
    w01 = zeros(size_sets(i,1),1);
    tmp_2 = 0;
    if i>1
        for j=1:(i-1)
            tmp_2 = tmp_2+size_sets(j,1);
        end
    end
    f1max = -inf;
    for j = 1:length(lambda1)
        w_1 = train_cg(tempTrainXY,w01,lambda1(j));
        f1 = logProb(tempTrainXY,w_1);
        if f1 > f1max
            f1max = f1;
            w1 = w_1;
        end
    end
    W((tmp_2+1):(tmp_2+size_sets(i,1)),1) = w1;
end


