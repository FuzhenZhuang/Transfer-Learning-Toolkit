import numpy as np
import matlab
import matlab.engine
import scipy.io as sio

class CDPLSA:
    def __init__(self, numCluster=64, maxIter=200):
        self.numCluster = numCluster
        self.maxIter = maxIter
        return
    
    def fit_predict(self, Xs, Xt, Ys, Yt):
        inputPath = 'data.mat'
        source_data = []
        source_data.append(Xs.T)
        
        eng = matlab.engine.start_matlab()
        sio.savemat('../utilities/data.mat',{'TrainData': Xs.T, 'TrainLabel': Ys, 'TestData': Xt.T, 'TestLabel':Yt})
        result = eng.CDPLSA_enterFunc(self.numCluster, self.maxIter, inputPath)
        eng.exit()
        # Y_pred = np.asarray(Y_pred)
        # Y_pred = np.reshape(Y_pred, (Y_pred.shape[1],)) 
        return result