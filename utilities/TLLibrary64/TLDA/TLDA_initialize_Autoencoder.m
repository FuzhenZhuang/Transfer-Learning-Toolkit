function theta = initialize_Autoencoder(numK, numM, numC, TrainData, TestData)
   %% Initialize parameters randomly based on layer sizes.
    
	% init the paramters randomly 
	W1 = rand(numK, numM);
	W2 = rand(numC, numK);
    W22 = rand(numK, numC);
	W11 = rand(numM, numK);
	b1 = zeros(numK, 1);
	b2 = zeros(numC, 1);
    b22 = zeros(numK, 1);
	b11 = zeros(numM, 1);
    
    theta1 = [W1(:) ; W11(:) ; b1(:) ; b11(:)];

    options.Method = 'lbfgs'; % Here, we use L-BFGS to optimize our cost function. 
    options.maxIter = 100;	  % Maximum number of iterations of L-BFGS to run 
    options.display = 'on';
    options.TolFun  = 1e-8;
    options.TolX = 1e-119;
    
    lambda1 = 0.0;

    [opttheta, cost] = minFunc( @(p) basic_autoencoder_cost(p, numM, numK, ...
                           lambda1, [TrainData TestData]), theta1, options);

    W1 = reshape(opttheta(1:numK*numM), numK, numM);
    W11 = reshape(opttheta(numK*numM+1:2*numK*numM), numM, numK);
    b1 = opttheta(2*numK*numM+1:2*numK*numM+numK);
    b11 = opttheta(2*numK*numM+numK+1:end);
 
    theta2 = [W2(:) ; W22(:) ; b2(:) ; b22(:)];

    options.Method = 'lbfgs'; % Here, we use L-BFGS to optimize our cost function. 
    options.maxIter = 100;	  % Maximum number of iterations of L-BFGS to run 
    options.display = 'on';
    options.TolFun  = 1e-8;
    options.TolX = 1e-119;
    
    lambda1 = 0.0;
    data=[TrainData TestData];
    hiddeninputs = W1 * data + b1 * ones(1, size(data,2)); % hiddensize * numpatches
    hiddenvalues = sigmoid( hiddeninputs ); % hiddensize * numpatches
    
    [opttheta, cost] = minFunc( @(p) basic_autoencoder_cost(p, numK, numC, ...
                           lambda1, hiddenvalues), theta2, options);

    W2 = reshape(opttheta(1:numK*numC), numC, numK);
    W22 = reshape(opttheta(numK*numC+1:2*numK*numC), numK, numC);
    b2 = opttheta(2*numK*numC+1:2*numK*numC+numC);
    b22 = opttheta(2*numK*numC+numC+1:end);
 
	% Convert weights and bias gradients to the vector form.
	theta = [W1(:) ; W2(:) ; W22(:) ; W11(:) ; b1(:) ; b2(:) ; b22(:) ; b11(:)];
end

function sigm = sigmoid(x)
  
    sigm = 1 ./ (1 + exp(-x));
end