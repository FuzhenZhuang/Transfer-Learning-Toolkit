import numpy as np
import matlab
import matlab.engine
import scipy.io as sio

#? test accuracy = 1  
class CCR3:
    def __init__(self, gamma=150):
        self.gamma = gamma
        return
    
    def fit_predict(self, Xs, Xt, Ys, Yt):
        inputPath = 'data.mat'
        eng = matlab.engine.start_matlab()
        sio.savemat('../utilities/data.mat',{'TrainData': Xs, 'TrainLabel': Ys, 'TestData': Xt.T, 'TestLabel':Yt})
        eng.CCR3_enterFunc(self.gamma, inputPath)
        eng.exit()
        # Y_pred = np.asarray(Y_pred)
        # Y_pred = np.reshape(Y_pred, (Y_pred.shape[1],)) 
        return