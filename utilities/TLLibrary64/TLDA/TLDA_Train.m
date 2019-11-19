function [opttheta, cost] = TLDA_Train(numM,numK,numC,numX,maxIter,alpha,beta,gamma,TrainData,TestData,theta)
    options.Method = 'lbfgs'; % Here, we use L-BFGS to optimize our cost function. 
    options.maxIter = maxIter;	  % Maximum number of iterations of L-BFGS to run 
    options.display = 'on';
    options.TolFun  = 1e-6;
    options.TolX = 1e-1119;
    options.maxFunEvals = 4000;
    options.useMex = 0;
    [opttheta, cost] = minFunc( @(p) TLDA_computeObjectAndGradiend(p, numM, numK,...
            numC, numX, alpha, beta, gamma, TrainData, TestData), theta, options); 
end