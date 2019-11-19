from MTIVM import MTIVM
import numpy as np
import joblib
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.svm import SVC, LinearSVC
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.utils import shuffle
from sklearn.decomposition import PCA
import arff

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
	source_dataset = ['OrgsPlaces', 'PeoplePlaces']
	Xs = []
	Ys = []
	for source_data in source_dataset:
		in_dataset = arff.load(open('../data/Reuters/'+source_data+'.src.arff', 'r'))
		indomain = np.array(in_dataset["data"]).astype(float)
		indomain = shuffle(indomain, random_state=42)
		item_xs = indomain[:,:-1]
		item_xs = dimension_reduce(item_xs)
		Xs.append(item_xs)
		item_ys = indomain[:,-1]
		item_ys = np.reshape(item_ys, (item_ys.shape[0],))
		Ys.append(item_ys)
	
	out_dataset = arff.load(open('../data/Reuters/OrgsPlaces.tar.arff', 'r'))
	outdomain = np.array(out_dataset["data"]).astype(float)
	outdomain_X = dimension_reduce(outdomain[:,:-1])
	Xt, X_test, Yt, Y_test = train_test_split(outdomain_X, outdomain[:,-1], test_size=0.2, random_state=42)
	Yt = np.reshape(Yt, (Yt.shape[0],))
	Y_test = np.reshape(Y_test, (Y_test.shape[0],))
	print("data processed \n start training")
	mtivm = MTIVM()
	Y_pred = mtivm.fit_predict(Xs, Xt, X_test, Ys, Yt)
	acc = accuracy_score(Y_test, Y_pred);
	print(acc)