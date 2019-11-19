__author__ = 'GongLi'
import math
import numpy as np
import pickle
import random

def constructBaseKernels(kernel_type, kernel_params, D2):

    baseKernels = []

    for i in range(len(kernel_type)):

        for j in range(len(kernel_params)):

            type = kernel_type[i]
            param = kernel_params[j]

            if type == "rbf":
                baseKernels.append(math.e **(- param * D2))
            elif type == "lap":
                baseKernels.append(math.e **(- (param * D2) ** (0.5)))
            elif type == "id":
                baseKernels.append(1.0 / ((param * D2) ** (0.5) + 1))
            elif type == "isd":
                baseKernels.append(1.0 / (param * D2 + 1))

    return baseKernels

def sliceArray(testArray, indices):

    return testArray[np.ix_(indices, indices)]

def loadObject(fileName):
    file = open(fileName, "rb")
    obj = pickle.load(file)
    return obj

def storeObject(fileName, obj):
    file = open(fileName, "wb")
    pickle.dump(obj, file)
    file.close()

def generateBinaryLabels(compressedLabels):

    setlabels = ["birthday","parade","picnic","show", "sports", "wedding"]
    binaryLabels = np.zeros((len(compressedLabels))).reshape((len(compressedLabels), 1))

    for label in setlabels:

        tempLabel = np.zeros((len(compressedLabels))).reshape((len(compressedLabels), 1))
        for i in range(len(compressedLabels)):
            if compressedLabels[i] == label:
                tempLabel[i][0] = 1
            else:
                tempLabel[i][0] = -1

        binaryLabels = np.concatenate((binaryLabels, tempLabel), axis=1)

    binaryLabels = binaryLabels[::, 1::]

    return binaryLabels

def generateRandomIndices(semanticLabels, sampleNumberFromEachClass):

    labelIndices = []
    setlabels = ["birthday","parade","picnic","show", "sports", "wedding"]

    for label in setlabels:
        labelIndices.append([i for i in range(len(semanticLabels)) if semanticLabels[i] == label])

    trainingIndice = []
    for labelIndice in labelIndices:
        # Select 30 indices from labelIndice
        trainingIndice += random.sample(labelIndice, sampleNumberFromEachClass)

    testingIndice = [i for i in range(len(semanticLabels))]
    for indice in trainingIndice:
        testingIndice.remove(indice)

    return trainingIndice, testingIndice

def averagePrecision(scores, labels):

    scores = scores.flatten()
    sortingIndice = np.argsort(scores)
    sortedLabels = [labels[i] for i in sortingIndice[::-1]]

    times = 0
    accumulated = 0
    for i in range(len(sortedLabels)):
        if sortedLabels[i] == 1:

            times += 1
            postive = 0
            for item in sortedLabels[:i+1]:
                if item == 1:
                    postive += 1
            accumulated += postive / float(i+1)

    return accumulated / times


def evaluateAccuracy(predictions, trueLabels):

    temp = predictions == trueLabels
    correct = sum(1.0 * (predictions == trueLabels))
    accuracy = correct / len(trueLabels)
    return accuracy

def paris(classes):

    results = []
    for i in range(0 ,len(classes) - 1):
        for j in range(i + 1, len(classes)):
            temp = []
            temp.append(classes[i])
            temp.append(classes[j])
            results.append(temp)
    return results
