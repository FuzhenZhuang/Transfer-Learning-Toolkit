import numpy as np
import scipy.io
import scipy.linalg
import sklearn.metrics
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score
from sklearn.svm import LinearSVC
from scipy.linalg import eig
class JDA:
    '''
        Implements Joint Distribution Adaptation.
        To read more about the JDA, check the following paper:
            Long M, Wang J, Ding G, et al.
            Transfer feature learning with joint distribution adaptation[C]//
            Proceedings of the IEEE international conference on computer vision. 2013: 2200-2207.
        The code is modified according to https://github.com/jindongwang/transferlearning/tree/master/code/traditional/JDA
    '''
    def __init__(self, kernel_type='linear', dim=20, lamb=0.1, gamma=1, iter=10, base_classifer=LinearSVC()):
        '''
        :param kernel_type: kernel, values: 'primal' | 'linear' | 'rbf' | 'sam'
        :param dim: dimension after transfer
        :param lamb: lambda value in equation
        :param gamma: kernel bandwidth for rbf kernel
        :param iter: iterations
        '''
        self.kernel_type = kernel_type
        self.dim = dim
        self.lamb = lamb
        self.gamma = gamma
        self.base_classifer = base_classifer
        self.iter = iter
        self.X = None
        self.V = None

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

    def fit(self, Xs, Xt, Ys):
        '''
        get the transform weight matrix and neccessary parameters
        :param: Xs source feature, shape:(num_samples,num_features)
        :param: Xt target feature, shape:(num_samples,num_features)
        :param: Ys source data label
        :return: Xs_new and Xt_new after JDA
        '''
        X = np.hstack((Xs.T, Xt.T))
        X = X/np.linalg.norm(X, axis=0)
        m, n = X.shape
        ns, nt = len(Xs), len(Xt)
        e = np.vstack((1 / ns * np.ones((ns, 1)), -1 / nt * np.ones((nt, 1))))
        C = len(np.unique(Ys))
        H = np.eye(n) - 1 / n * np.ones((n, n))
        M = e * e.T * C
        Y_tar_pseudo = None
        clf = KNeighborsClassifier(n_neighbors=1)
        for t in range(self.iter):
            print('iteration %d/%d'%(t+1,self.iter))
            N = 0
            if Y_tar_pseudo is not None and len(Y_tar_pseudo) == nt:
                # the source code is 'for c in range(1, C + 1)', but in our case, the true label start from 0
                for c in range(C):
                    e = np.zeros((n, 1))
                    tt = Ys == c
                    e[np.where(tt == True)] = 1 / len(Ys[np.where(Ys == c)])
                    yy = Y_tar_pseudo == c
                    ind = np.where(yy == True)
                    inds = [item + ns for item in ind]
                    e[tuple(inds)] = -1 / len(Y_tar_pseudo[np.where(Y_tar_pseudo == c)])
                    e[np.isinf(e)] = 0
                    N = N + np.dot(e, e.T)
            M += N
            M = M / np.linalg.norm(M, 'fro')
            K = self.kernel(self.kernel_type, X, None, gamma=self.gamma)
            n_eye = m if self.kernel_type == 'primal' else n
            a = np.linalg.multi_dot([K, M, K.T])+self.lamb*np.eye(n_eye)
            b = np.linalg.multi_dot([K, H, K.T])
            a[np.isnan(a)] = 0.0
            b[np.isnan(b)] = 0.0
            Kc = np.linalg.inv(a).dot(b)
            Kc[np.isnan(Kc)] = 0
            w, v= scipy.sparse.linalg.eigs(Kc)
            # w, v = eig(a, b)
            w = w.astype('float')
            ind = np.argsort(w)
            A = v[:, ind[:self.dim]].astype('float')
            Z = np.dot(A.T, K)
            Z /= np.linalg.norm(Z, axis=0)
            Z[np.isnan(Z)] = 0
            # save neccessary metrics for transforming
            self.X = X
            self.V = A.T
            Xs_new, Xt_new = Z[:, :ns].T, Z[:, ns:].T

            clf.fit(Xs_new, Ys.ravel())
            Y_tar_pseudo = clf.predict(Xt_new)
        return Xs_new, Xt_new

    def transform(self, x_test):
        '''
        transform test data
        :param x_test: test data
        :return: transformed test data
        '''
        if self.X is None:
            raise ValueError('Please fit on some data first.')
        x_test_k = self.kernel(self.kernel_type, self.X, x_test.T, gamma=self.gamma)
        x_test_jda = np.dot(self.V, x_test_k)
        x_test_jda /= np.linalg.norm(x_test_jda, axis=0)
        return x_test_jda.T

    def fit_predict(self, Xs, Xt, X_test, Ys, Y_test):
        self.fit(Xs, Xt, Ys)
        Xs = self.transform(Xs)
        self.base_classifer.fit(Xs, Ys)
        X_test = self.transform(X_test)
        y_pred = self.base_classifer.predict(X_test)
        acc = accuracy_score(Y_test, y_pred)
        return acc