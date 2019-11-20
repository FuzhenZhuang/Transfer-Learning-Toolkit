import numpy as np
import matlab
import matlab.engine
import scipy.io as sio

# ?! HIDC matlab中存在steplen的设置，at matrixproduce
class HIDC:
    def __init__(self, numIdentical=20, numAlike=20, numDistinct=10, numIter=10):
        self.numIdentical = numIdentical
        self.numAlike = numAlike
        self.numDistinct = numDistinct
        self.numIter = numIter
        return
    
    def fit_predict(self, Xs, Xt, Ys, Yt):
        inputPath = 'data.mat'
        
        eng = matlab.engine.start_matlab()
        sio.savemat('../utilities/data.mat',{'TrainData': Xs.T, 'TrainLabel': Ys, 'TestData': Xt.T, 'TestLabel':Yt})
        result = eng.HIDC_enterFunc(self.numIdentical, self.numAlike, self.numDistinct, self.numIter, inputPath)
        
        eng.exit()
        # Y_pred = np.asarray(Y_pred)
        # Y_pred = np.reshape(Y_pred, (Y_pred.shape[1],)) 
        return result