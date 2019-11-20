import numpy as np
import joblib
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.svm import SVC, LinearSVC
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.utils import shuffle
from sklearn.decomposition import PCA
import arff
import sys
from mSDA import mSDA
from JDA import JDA
# from SDA import SDA
import json
from SCL import SCL
from TCA import TCA
from GFK import GFK
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
    domains = ['Orgs', 'People', 'Places']
    results = {}
    for index1, domain1 in enumerate(domains):
        for index2, domain2 in enumerate(domains):
            if domain1 < domain2:
                in_dataset = arff.load(open('data/Reuters/'+domain1+domain2+'.src.arff', 'r'))
                out_dataset = arff.load(open('data/Reuters/'+domain1+domain2+'.tar.arff', 'r'))
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
                
                # train_X=np.concatenate((Xs,Xt),axis=0)
                # shuffle_train_index = np.random.permutation(np.arange(train_X.shape[0]))
                # train_X=train_X[shuffle_train_index]
                # sda=SDA(nb_layers=2,nb_hid=[100],dropout=[0.1],enc_act=['tanh'],
                #         dec_act=['linear'])
                # split=int(0.9*train_X.shape[0])
                # sda.fit(X_train=train_X[:split], X_val=train_X[split:])
                # Xs = sda.transform(Xs)
                # #print("Shape of mSDA Xs_reps: ", Xs_reps.shape)
                # X_test = sda.transform(X_test)

                # clf = SVC().fit(Xs, Ys)
                # preds_Xs = clf.predict(X_test)
                # acc = np.mean(preds_Xs == Y_test)
                results[domain1+domain2] = acc
                # print("data processed")
                # print("start training...")
                # iters = 3
                # acc = 0.0
                # for i in range(iters):
                #     model = JDA()
                #     acc += model.fit_predict(Xs, Xt, X_test, Ys, Y_test)
                # acc /= 3
                # print(acc)
                # results[domain1+domain2] = acc
    
    with open("JDA_reuters_record.json",'w') as json_file:
        json.dump(results, json_file)