import numpy as np
import matlab
import matlab.engine
import scipy.io as sio

class Mtrick:
    def __init__(self, alpha=2.4, beta=2.4, numCluster=15, maxIter=200):
        self.alpha = alpha
        self.beta = beta
        self.numCluster = numCluster
        self.maxIter = maxIter
        return

    def fit_predict(self, Xs, Xt, Ys):
        inputPath = 'data.mat'
        eng = matlab.engine.start_matlab()
        sio.savemat('../utilities/data.mat',{'TrainData': Xs.T, 'TrainLabel': Ys, 'TestData': Xt.T})
        Y_pred = eng.MTrick_enterFunc(self.alpha, self.beta, self.numCluster, self.maxIter, inputPath)
        eng.exit()
        Y_pred = np.asarray(Y_pred)
        Y_pred = np.reshape(Y_pred, (Y_pred.shape[1],)) 
        return Y_pred
