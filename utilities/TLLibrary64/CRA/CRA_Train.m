function [opttheta, cost] = CRA_Train(numM,numK,numS,numX,maxIter,alpha,beta,gamma,lambda,TrainData,TestData,TrainLabel,theta)
    options.Method = 'lbfgs'; % Here, we use L-BFGS to optimize our cost function. 
    options.maxIter = maxIter;	  % Maximum number of iterations of L-BFGS to run 
    options.display = 'on';
    options.TolFun  = 1e-6;
    options.TolX = 1e-1119;
    options.maxFunEvals = 4000;
    options.useMex = 0;

    [opttheta, cost] = minFunc( @(p) CRA_computeObjectAndGradiend(p, numM, numK,...
         numS, numX, alpha, beta, gamma, lambda, TrainData, TestData, TrainLabel), theta, options);  
end