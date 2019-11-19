import numpy as np
from scipy.linalg import eig
import scipy
import sklearn
from sklearn import svm
from sklearn.metrics import accuracy_score

class TCA:
    def __init__(self, kernel_type='linear', dim=20, lamb=0.1, gamma=1, base_classifer=svm.LinearSVC()):
        '''
        Init func
        :param kernel_type: kernel, values: 'primal' | 'linear' | 'rbf' | 'sam'
        :param dim: dimension after transfer
        :param lamb: lambda value in equation
        :param gamma: kernel bandwidth for rbf kernel
        '''
        self.kernel_type = kernel_type
        self.dim = dim
        self.lamb = lamb
        self.gamma = gamma
        self.base_classifer = base_classifer
        self.V = None
        self.X = None
    
    def kernel(self, kernel_type, X1, X2, gamma):
        K = None
        X1[np.isnan(X1)]=0
        if not kernel_type or kernel_type == 'primal':
            K = X1
        elif kernel_type == 'linear':
            if X2 is not None:
                X2[np.isnan(X2)]=0
                K = sklearn.metrics.pairwise.linear_kernel(np.asarray(X1).T, np.asarray(X2).T)
            else:
                K = sklearn.metrics.pairwise.linear_kernel(np.asarray(X1).T)
        elif kernel_type == 'rbf':
            if X2 is not None:
                X2[np.isnan(X2)]=0
                K = sklearn.metrics.pairwise.rbf_kernel(np.asarray(X1).T, np.asarray(X2).T, gamma)
            else:
                K = sklearn.metrics.pairwise.rbf_kernel(np.asarray(X1).T, None, gamma)
        return K


    def fit(self, Xs, Xt):
        '''
        Transform Xs and Xt
        :param Xs: ns * n_feature, source feature
        :param Xt: nt * n_feature, target feature
        :return: Xs_new and Xt_new after TCA
        '''
        # get input dataset and normalize it
        X = np.hstack((Xs.T, Xt.T))
        X = X/np.linalg.norm(X, axis = 0)
        # get parameter for the input dataset
        m, n = X.shape
        ns, nt = len(Xs), len(Xt)
        # get L in the paper and normalize it
        e = np.vstack((1/ns*np.ones((ns, 1)), -1/nt*np.ones((nt, 1))))
        M = e*e.T
        M = M/np.linalg.norm(M, 'fro')
        # get H
        H = np.eye(n) - 1/n*np.ones((n,n))
        # define Kernel function
        K = self.kernel(self.kernel_type, X, None, gamma=self.gamma)
        # calculate the final solution
        n_eye = m if self.kernel == 'primal' else n
        a = np.linalg.multi_dot([K, M, K.T])+self.lamb*np.eye(n_eye)
        b = np.linalg.multi_dot([K, H, K.T])
        Kc = np.linalg.pinv(a).dot(b)
        Kc[np.isnan(Kc)] = 0
        w, v= scipy.sparse.linalg.eigs(Kc)
        # extract the most important featrues
        w = w.astype('float')
        ind = np.argsort(w)
        A = v[:, ind[:self.dim]].astype('float')
        Z = np.dot(A.T, K)

        # save neccessary metrics for transforming
        self.X = X
        self.V = A.T

        Z /= np.linalg.norm(Z, axis=0)
        Xs_new, Xt_new = Z[:,:ns].T, Z[:, ns:].T
        return Xs_new, Xt_new

    def transform(self, x_test):
        '''
        transform test data
        :param x_test: test data
        :return: transformed test data
        '''
        x_test_k = self.kernel(self.kernel_type, self.X, x_test.T, gamma=self.gamma)
        x_test_tca = np.dot(self.V, x_test_k)
        x_test_tca /= np.linalg.norm(x_test_tca, axis=0)
        return x_test_tca.T

    def fit_predict(self, Xs, Xt, X_test, Ys, Y_test):
        ut = self.fit(Xs, Xt)
        Xs = self.transform(Xs)
        self.base_classifer.fit(Xs, Ys)
        X_test = self.transform(X_test)
        y_pred = self.base_classifer.predict(X_test)
        acc = accuracy_score(Y_test, y_pred)
        return acc