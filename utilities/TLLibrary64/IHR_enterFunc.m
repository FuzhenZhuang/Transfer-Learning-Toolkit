function result = IHR_enterFunc(alpha,beta,gamma,threshold,inputPath,neighborPath)
    global TrainSetX;
    global TrainSetY;
    global TrainXY;
    global TestSetX;
    global TestSetY;
    global kneighbor_testp;
    
    global eta;
    global gama;
    global afa;
    global npos;
    
    afa = alpha;
    gama = beta;
    eta = gamma;
    %% ======================================================================
    %%STEP 1: load the data
    fprintf('start load the data...\n');
    [TrainSetX, TestSetX, TrainSetY, TestSetY] = IHR_loadData(inputPath);
    indexi = find(TestSetY == 1);
    npos = sum(TestSetY(indexi)); 
    %% ======================================================================
    %%STEP 2: load the neighbors
    kneighbor_testp = textread(neighborPath); 
    kneighbor_testp = kneighbor_testp(:,1:(size(kneighbor_testp,2)-1));
    kneighbor_testp = kneighbor_testp + 1;
    
     %% ======================================================================
    %%STEP 3: train the Logistic Regression model
    TrainXY = scale_cols(TrainSetX,TrainSetY);
    tempTrainXY = scale_cols(TrainSetX,TrainSetY);
    c00 = zeros(size(tempTrainXY,1),1);
    lambda = exp(linspace(-0.5,6,20));
    wbest=[];
    f1max = -inf;
    for j = 1 : length(lambda)
        c_0 = train_cg(tempTrainXY,c00,lambda(j));
        f1 = logProb(tempTrainXY,c_0);
        if f1 > f1max
            f1max = f1;
            wbest = c_0;
        end
    end
    size(wbest)
      %% ======================================================================
    %%STEP 4: train the model and testing
    fprintf('training the model and testing...\n');
    [W,results] = PRP_CG_IHR(wbest,npos,gama,afa,threshold);
    ptemp = 1./(1 + exp(-W'*TestSetX));
    TestA = getResult(ptemp,TestSetY);
    fprintf('The final testing accuracy: %g\n',TestA*100);
    
    result = TestA;
end