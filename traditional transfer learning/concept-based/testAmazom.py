import numpy as np
import numpy.matlib
import os
from sklearn.externals import joblib
from sklearn import svm
import json
from Mtrick import Mtrick
from CDPLSA import CDPLSA
from CCR3 import CCR3
from HIDC import HIDC
from TriTL import TriTL
from mySFA import SFA
from sklearn.metrics import accuracy_score

if __name__ == "__main__":
	basepath = "../data/processed_acl"
	# load dataset1
	datasets = ['K', 'D', 'B', 'E']
	results = {}
	for dataset1 in datasets:
		for dataset2 in datasets:
			if dataset1 == dataset2:
				continue
			[Xs, Ys, X_test, Y_test, Xt]=joblib.load(
						os.path.join(basepath, dataset1+'-'+dataset2+'.pkl'))
			tritl = CDPLSA(numCluster=128 ,maxIter=100)
			result = tritl.fit_predict(Xs, X_test, Ys, Y_test)
			results[dataset1+dataset2] = result
			# acc = accuracy_score(Y_test, y_pred)
			# results[dataset1+dataset2]= acc
			# print(acc)
	
	with open("CDPLSA_record.json",'w') as json_file:
		json.dump(results, json_file)
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


	# clf = svm.SVC().fit(Xs_train, Ys_train)
	# preds_Xs = clf.predict(Xs_test)
	# acc = np.mean(preds_Xs == Ys_test)
	# print("Xs acc on regular X: ", acc)
	# preds_Xt = clf.predict(Xt_test)
	# acc = np.mean(preds_Xt == Xt_test_label)
	# print("Xt acc on regular X: ", acc)

	# set corruption probability, number of layers and bias.
	# pp = 0.3
	# ll = 5
	# bias = True
	# train_X=np.concatenate((Xs_train,Xs_unlabeled,Xt_train,Xt_unlabeled),axis=0)
	# msda=mSDA(p=pp, l=ll,act=np.tanh, Ws=None, bias=True)
	# msda.fit(train_X)
	# Xs_reps = msda.transform(Xs_train)
	# print("Shape of mSDA Xs_reps h: ", Xs_reps.shape)
	# Xs_test_reps = msda.transform(Xs_test)
	# print("Shape of mSDA Xs_test_reps h: ", Xs_test_reps.shape)
	# Xt_reps = msda.transform(Xt_test)
	# print("Shape of mSDA Xt_test_reps h: ", Xt_reps.shape)

	# clf = svm.SVC().fit(Xs_reps, Ys_train)
	# preds_Xs=clf.predict(Xs_test_reps)
	# acc=np.mean(preds_Xs == Ys_test)
	# print("Xs acc with linear SVM on mSDA features: ", acc)
	# preds_Xt = clf.predict(Xt_reps)
	# acc = np.mean(preds_Xt == Xt_test_label)
	# print("Xt acc with linear SVM on mSDA features: ", acc)