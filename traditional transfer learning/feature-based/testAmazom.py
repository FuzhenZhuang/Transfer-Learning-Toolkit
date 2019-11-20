import numpy as np
import numpy.matlib
import os
from sklearn.externals import joblib
from sklearn import svm
import json
from SFA import SFA
from sklearn.metrics import accuracy_score
from JDA import JDA
# from SDA import SDA
from SCL import SCL
from TCA import TCA

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
			Xs = Xs.astype('float')
			X_test = X_test.astype('float')
			Xt = Xt.astype('float')
			# model = JDA()
			model = TCA()
			acc = model.fit_predict(Xs, Xt, X_test, Ys, Y_test)
			print(acc)
			results[dataset1+dataset2] = acc
			
	
	with open("JDA_record.json",'w') as json_file:
		
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
	