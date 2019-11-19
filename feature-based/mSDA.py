import numpy as np
import numpy.matlib
import os
from sklearn.externals import joblib


class mSDA(object):
    '''
    Implement mSDA.
    To read more about the SDA, check the following paper:
        Chen M , Xu Z , Weinberger K , et al.
        Marginalized Denoising Autoencoders for Domain Adaptation[J].
        Computer Science, 2012.
    This implementation of mSDA is based on both the sample code the authors provided
    as well as the equations in the paper.
    The code is modified according to https://github.com/douxu896/mSDA
    '''
    def __init__(self, p=None, l=5, act=np.tanh, Ws=None, bias=True):
        '''
        :param p: corruption probability
        :param l: number of layers
        :param act: what nonlinearity to use? if None, not to use nonlinearity.
        :param Ws: model parameters. Can optionally pass in precomputed Ws to use to transform X.
                (e.g. if transforming test X with Ws learned from training X)
        :param bias: Whether to use bias?
        '''
        self.p = p
        self.l = l
        self.act = act
        self.Ws = Ws
        self.bias = bias

    def mDA(self, X, W=None):
        '''
        One layer Marginalized Denoising Autoencoder.
        Learn a representation h of X by reconstructing "corrupted" input but marginalizing out corruption
        :param X: input features, shape:(num_samples,num_features)
        :param W: model parameters. Can optionally pass in precomputed W to use to transform X.
                (e.g. if transforming test X with W learned from training X)
        :return: model parameters, reconstructed representation.
        '''
        if self.bias:
            X=np.hstack((X, np.ones((X.shape[0], 1))))
        if W is None:
            W = self._compute_reconstruction_W(X)
        h = np.dot(X, W)  # no nonlinearity
        if self.act is not None:
            h = self.act(h)  # inject nonlinearity
        return W, h

    def _compute_reconstruction_W(self, X):
        '''
        Learn reconstruction parameters.
        :param X: input features, shape:(num_samples,num_features)
        :return: model parameters.
        '''
        # typecast to correct Xtype
        X.dtype = "float64"
        d = X.shape[1]
        # Represents the probability that a given feature will be corrupted
        if self.bias:
            q = np.ones(
                (d-1, 1)) * (1 - self.p)
            # add bias probability
            q=np.vstack((q,1))
        else:
            q = np.ones(
                (d, 1)) * (1 - self.p)

        S = np.dot(X.transpose(), X)
        Q = S * (np.dot(q, q.transpose()))
        Q[np.diag_indices_from(Q)] = q[:,0] * np.diag(S)
        P = S * numpy.matlib.repmat(q, 1, d)

        # solve equation of the form W = BA^-1
        A = Q + 10**-5 * np.eye(d)
        B = P[:-1,:]
        W = np.linalg.solve(A.transpose(), B.transpose())
        return W

    def fit(self, X):
        '''
        Stack mDA layers on top of each other, using previous layer as input for the next
        :param X: input features, shape:(num_samples,num_features)
        :return: None
        '''
        Ws = list()
        hs = list()
        hs.append(X)
        for layer in range(0, self.l):
            W, h = self.mDA(hs[-1])
            Ws.append(W)
            hs.append(h)
        self.Ws = Ws

    def transform(self, X):
        '''
        Should be called after fit!
        Stack mDA layers on top of each other, using previous layer as input for the next
        :param X: input features, shape:(num_samples,num_features)
        :return: reconstructed representation of the last layer.
        '''
        if self.Ws is None:
            raise ValueError('Please fit on some data first.')
        hs = list()
        hs.append(X)
        for layer in range(0, self.l):
            _, h = self.mDA(hs[-1], self.Ws[layer])
            hs.append(h)
        return hs[-1]

    def fit_transform(self, X):
        '''
        Stack mDA layers on top of each other, using previous layer as input for the next
        :param X: input features, shape:(num_samples,num_features)
        :return: reconstructed representation of the last layer.
        '''
        Ws = list()
        hs = list()
        hs.append(X)
        for layer in range(0, self.l):
            W, h = self.mDA(hs[-1])
            Ws.append(W)
            hs.append(h)
        self.Ws = Ws
        return hs[-1]

# test implementation
if __name__ == "__main__":
    basepath = "../data/processed_acl"
    # load dataset1
    [Xs_train, Ys_train, Xs_test, Ys_test, Xs_unlabeled]=joblib.load(
                os.path.join(basepath, 'K-D.pkl'))
    # load dataset2
    [Xt_train, Xt_train_label, Xt_test, Xt_test_label, Xt_unlabeled]=joblib.load(
                os.path.join(basepath, 'D-K.pkl'))

    from sklearn import svm

    clf = svm.SVC().fit(Xs_train, Ys_train)
    preds_Xs = clf.predict(Xs_test)
    acc = np.mean(preds_Xs == Ys_test)
    print("Xs acc on regular X: ", acc)
    preds_Xt = clf.predict(Xt_test)
    acc = np.mean(preds_Xt == Xt_test_label)
    print("Xt acc on regular X: ", acc)

    # set corruption probability, number of layers and bias.
    pp = 0.3
    ll = 5
    bias = True
    train_X=np.concatenate((Xs_train,Xs_unlabeled,Xt_train,Xt_unlabeled),axis=0)
    msda=mSDA(p=pp, l=ll,act=np.tanh, Ws=None, bias=True)
    msda.fit(train_X)
    Xs_reps = msda.transform(Xs_train)
    print("Shape of mSDA Xs_reps h: ", Xs_reps.shape)
    Xs_test_reps = msda.transform(Xs_test)
    print("Shape of mSDA Xs_test_reps h: ", Xs_test_reps.shape)
    Xt_reps = msda.transform(Xt_test)
    print("Shape of mSDA Xt_test_reps h: ", Xt_reps.shape)

    clf = svm.SVC().fit(Xs_reps, Ys_train)
    preds_Xs=clf.predict(Xs_test_reps)
    acc=np.mean(preds_Xs == Ys_test)
    print("Xs acc with linear SVM on mSDA features: ", acc)
    preds_Xt = clf.predict(Xt_reps)
    acc = np.mean(preds_Xt == Xt_test_label)
    print("Xt acc with linear SVM on mSDA features: ", acc)
