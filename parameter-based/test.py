from sklearn import preprocessing
from sklearn import decomposition
import TrAdaBoost2 as tr
from sklearn.ensemble import AdaBoostClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn import svm
from sklearn import feature_selection
from sklearn import model_selection
from sklearn import metrics
import arff
from sklearn.utils import shuffle
from sklearn.model_selection import train_test_split
import numpy as np

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
pred = tr.tradaboost(Xs, Xt, Ys, Yt, X_test, 10)
fpr, tpr, thresholds = metrics.roc_curve(y_true=Y_test, y_score=pred, pos_label=1)
print('auc:', metrics.auc(fpr, tpr))