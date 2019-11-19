from LWE import LWE
import numpy as np
import joblib
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.svm import LinearSVC
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.utils import shuffle
from sklearn.decomposition import PCA
import arff
import scipy.io as sio

# from MTIVM import MTIVM

def dimension_reduce(domain):
    #use document frequency 
    mask = domain != 0
    freq = np.sum(mask, axis=0)/domain.shape[0]
    mask = freq >= 0.2
    return domain[:, mask]
    # pca = PCA(n_components=200)
    # domain = pca.fit_transform(domain)
    # return domain

if __name__ == "__main__":
    in_dataset = arff.load(open('../data/Reuters/PeoplePlaces.src.arff', 'r'))
    out_dataset = arff.load(open('../data/Reuters/PeoplePlaces.tar.arff', 'r'))
    indomain = np.array(in_dataset["data"]).astype(float)
    outdomain = np.array(out_dataset["data"]).astype(float)

    indomain = shuffle(indomain, random_state=42)
    Xs = indomain[:, :-1]
    Ys = indomain[:, -1]
    Ys = np.reshape(Ys, (Ys.shape[0],))
    Xt, X_test, Yt, Y_test = train_test_split(outdomain[:,:-1], outdomain[:,-1], test_size=0.5, random_state=42)
    Yt = np.reshape(Yt, (Yt.shape[0],))
    Y_test = np.reshape(Y_test, (Y_test.shape[0],))
        
    #preprocess demensional feature reduction
    # Xs = dimension_reduce(Xs)
    # Xt = dimension_reduce(Xt)
    # X_test = dimension_reduce(X_test)
    # X = np.concatenate((Xs, Xt, X_test), axis=0)
    # X = dimension_reduce(X)
    # Xs = X[:Xs.shape[0],:]
    # Xt = X[Xs.shape[0]:Xs.shape[0]+Xt.shape[0],:]
    # X_test = X[Xs.shape[0]+Xt.shape[0]:,:]

    print("data processed")
    print("start training...")
    sio.savemat('../utilities/data.mat',{'Xs': Xs, 'Ys': Ys, 'Xt': Xt, 'Yt':Yt, 'X_test':X_test})

    # model = MTIVM()
    # Y_pred = model.fit_predict(Xs, Xt, X_test, Ys, Yt)
    # # Y_pred = tradaboost(Xt, Xs, Yt, Ys, X_test, N=100)
    # acc = accuracy_score(Y_test, Y_pred)
    # print(acc)