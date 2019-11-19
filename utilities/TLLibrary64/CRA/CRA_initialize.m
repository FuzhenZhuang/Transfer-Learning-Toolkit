function theta = CRA_initialize(numK, numM, numS, numX, trainX, trainY, testX)
   %% Initialize parameters randomly based on layer sizes.

    % init the paramters randomly
    %%{
    r  = sqrt(6) / sqrt(numK+numM+1);  
    W1 = rand(numK, numM) * 2 * r - r;
    W2 = rand(numM, numK) * 2 * r - r;
    b1 = zeros(numK, 1);
    b2 = zeros(numM, 1);

    % init W1 W2 b1 b2 by minFunc
    theta = [W1(:) ; W2(:) ; b1(:) ; b2(:)];

    options.Method = 'lbfgs'; % Here, we use L-BFGS to optimize our cost function. 
    options.maxIter = 100;	  % Maximum number of iterations of L-BFGS to run 
    options.display = 'on';
    options.TolFun  = 1e-8;
    options.TolX = 1e-119;
    options.useMex = 0;
    
    lambda1 = 0.0;

    [opttheta, cost] = minFunc( @(p) basic_autoencoder_cost(p, numM, numK, ...
                           lambda1, [trainX testX]), theta, options);

    W1 = reshape(opttheta(1:numK*numM), numK, numM);
    W2 = reshape(opttheta(numK*numM+1:2*numK*numM), numM, numK);
    b1 = opttheta(2*numK*numM+1:2*numK*numM+numK);
    b2 = opttheta(2*numK*numM+numK+1:end);

    C = zeros(numS, numK);   % Î¬¶È[numS,numK]
    tempTrainX = sigmoid(W1 * trainX + b1*ones(1, size(trainX,2)));
    tempTrainXY = scale_cols(tempTrainX, trainY);
    for i = 1 : numS
        c00 = zeros(size(tempTrainXY,1),1);
        lambdaLG = exp(linspace(-0.5,6,20));
        wbest=[];
        f1max = -inf;
        for j = 1 : length(lambdaLG)
            c_0 = train_cg(tempTrainXY(:,numX(1,i)+1 : 1 : numX(1,i+1)),c00,lambdaLG(j));
            f1 = logProb(tempTrainXY(:,numX(1,i)+1 : 1 : numX(1,i+1)),c_0);
            if f1 > f1max
                f1max = f1;
                wbest = c_0;
            end
        end
        C(i,:) = wbest;
    end
    
    % Convert weights and bias gradients to the vector form.
    theta = [W1(:) ; W2(:) ; b1(:) ; b2(:) ; C(:)];
end

function sigm = sigmoid(x)
  
    sigm = 1 ./ (1 + exp(-x));
end