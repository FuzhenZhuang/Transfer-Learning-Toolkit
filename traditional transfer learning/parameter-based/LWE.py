import numpy as np
from sklearn.cluster import SpectralClustering, KMeans
from sklearn.cluster import AgglomerativeClustering, DBSCAN
from sklearn.metrics import accuracy_score
from sklearn.base import clone
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression as LR
from sklearn.linear_model import Perceptron
from collections import Counter
from sklearn import metrics

#TODO add interface for user to choose proper clustering algorithm
#! CLUTO are used in the origianl paper
#? where is the proper clustering algorithm
#! the parameter threshold 0.5 for purity of clustering is unreasonable 
#! for binary classification, the purity of clustering is always higher than 0.5
class LWE:
    def __init__(self, delta=0.7, c_cluster=2):
        self.delta = delta
        self.c_cluster = c_cluster
        return 
    def purity(self, y_pred, y_true):
        contingency_matrix = metrics.cluster.contingency_matrix(y_true, y_pred)
        # return purity
        return np.sum(np.amax(contingency_matrix, axis=0)) / np.sum(contingency_matrix) 

    def weighting(self, CLU, CLA):
        '''
        weighting: compute local model weights according to the similarity
            between the model and the clustering structure. (works for
            binary classification problems)
        Input: 
            CLU- a column vector where each element represents the cluster
                membership (0 or 1).
            CLA- a clumn vector where each element represents the model membership (0 or 1)
        Output:           
            weight- a colum vector where each element represents the model
                    weight at the test example.
        '''
        num = len(CLU)
        weight = np.zeros((num,))
        for i in range(num):
            tem = np.arange(num)
            index = tem != i
            id1 = CLU[index] == CLU[i]
            id2 = CLA[index] == CLA[i]
            tem = np.arange(num-1)
            inter = np.intersect1d(tem[id1], tem[id2])
            uinon = np.union1d(tem[id1], tem[id2])
            weight[i] = len(inter)/len(uinon)
        return weight
    def fit_predict(self, Xs, Ys, X_test, classifers=None):
        
        if classifers==None:
            classifers=[]
            classifers.append(SVC(kernel="linear", C=0.025))
            classifers.append(SVC(gamma=2, C=1))
            classifers.append(LR(random_state=0, solver='lbfgs'))
            classifers.append(Perceptron(tol=1e-3, random_state=0))
        # clustering on the training set, IF the average purity of clustering is less than 0.5
        # set W = 1/k for all Mi and X
        K = len(classifers)
        W = np.ones(shape=(len(classifers),X_test.shape[0]))
        cluster_alg = SpectralClustering(n_clusters=self.c_cluster)
        y_pred = cluster_alg.fit_predict(Xs)
        pur = self.purity(y_pred, Ys)
        result = np.zeros((K, X_test.shape[0]))
        print('pur ', pur)
        if pur < 0.5:
            W = W*(1/K)
            for i in range(K):
                result[i,:] = classifers[i].fit(Xs, Ys).predict(X_test).T
            result = result*W
            result = np.sum(result, axis=0)
            result = np.around(result)
            return result
        # group test examples into c' clusters and construct 
        # neighborhood graphs based on the clustering results and all the k models
        cluster_alg = SpectralClustering(n_clusters=self.c_cluster)
        clustering_structure = cluster_alg.fit_predict(X_test)
        y_pred = np.zeros((K, X_test.shape[0]))
        for i, est in enumerate(classifers):
            y_pred[i,:] = est.fit(Xs, Ys).predict(X_test)
            W[i,:] = self.weighting(clustering_structure, y_pred[i,:])
        filter_delta = np.sum(W, axis=0)/K < self.delta
        y_pred = np.sum(y_pred*W, axis=0)
        y_pred = np.around(y_pred)
        # predict the X label in T_hat 
        tem_range = np.arange(X_test.shape[0])
        for i in tem_range[filter_delta]:
            the_cluster = clustering_structure == clustering_structure[i]
            y_pred[i] = Counter(y_pred[the_cluster]).most_common(1)[0][0]
        return y_pred