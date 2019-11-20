from Mtrick import Mtrick
from CDPLSA import CDPLSA
from CCR3 import CCR3
from HIDC import HIDC
from TriTL import TriTL
import numpy as np
import joblib
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.svm import SVC, LinearSVC
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.utils import shuffle
from sklearn.decomposition import PCA
import arff
import logger
import sys

def dimension_reduce(domain):
    # use document frequency 
    mask = domain != 0
    freq = np.sum(mask, axis=0)/domain.shape[0]
    mask = freq >= 0.1
    return domain[:, mask]
    # pca = PCA(n_components=500)
    # domain = pca.fit_transform(domain)
    # return domain

if __name__ == "__main__":
    # in_dataset = arff.load(open('../data/Reuters/PeoplePlaces.src.arff', 'r'))
    # out_dataset = arff.load(open('../data/Reuters/PeoplePlaces.tar.arff', 'r'))
    # in_dataset = arff.load(open('../data/Reuters/OrgsPlaces.src.arff', 'r'))
    # out_dataset = arff.load(open('../data/Reuters/OrgsPlaces.tar.arff', 'r'))
    in_dataset = arff.load(open('../data/Reuters/OrgsPeople.src.arff', 'r'))
    out_dataset = arff.load(open('../data/Reuters/OrgsPeople.tar.arff', 'r'))
    indomain = np.array(in_dataset["data"]).astype(float)
    outdomain = np.array(out_dataset["data"]).astype(float)

    indomain = shuffle(indomain, random_state=42)
    outdomain = shuffle(outdomain, random_state=42)
    Xs = indomain[:, :-1]
    Ys = indomain[:, -1]
    Ys = np.reshape(Ys, (Ys.shape[0],))
    Xt, X_test, Yt, Y_test = train_test_split(outdomain[:,:-1], outdomain[:,-1], test_size=0.2, random_state=42)
    Yt = np.reshape(Yt, (Yt.shape[0],))
    Y_test = np.reshape(Y_test, (Y_test.shape[0],))
        
    #preprocess demensional feature reduction
    # X = np.concatenate((Xs, Xt, X_test), axis=0)
    # X = dimension_reduce(X)
    # Xs = X[:Xs.shape[0],:]
    # Xt = X[Xs.shape[0]:Xs.shape[0]+Xt.shape[0],:]
    # X_test = X[Xs.shape[0]+Xt.shape[0]:,:]
    # Xs = dimension_reduce(Xs)
    # Xt = dimension_reduce(Xt)
    # X_test = dimension_reduce(X_test)

    # sys.stdout = logger(a.log, sys.stdout)
    # sys.stderr = logger(a.log_file, sys.stderr)	
    
    print("data processed")
    print("start training...")
    mtrick = Mtrick(maxIter=500)
    y_pred = mtrick.fit_predict(Xs, Xt, Ys)
    acc = accuracy_score(Yt, y_pred)
    print(acc)
    # ccr = CCR3()
    # ccr.fit_predict(Xs, Xt, Ys, Yt)
    # tritl = TriTL(numIter=1000)
    # tritl.fit_predict(Xs, Xt, Ys, Yt)
    # hidc = HIDC(numIter=500)
    # hidc.fit_predict(Xs, Xt, Ys, Yt)
    # cdplsa = CDPLSA(maxIter=500)
    # cdplsa.fit_predict(Xs, Xt, Ys, Yt)
    # acc = accuracy_score(Yt, Y_pred)
    # print(acc)