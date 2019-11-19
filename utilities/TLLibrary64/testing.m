alpha=1;
beta=0.5;
gamma=0.00001;
lambda=0.00001;
numK=10;
maxIter=100;
flag=1;
inputPath='D:/chengxh/matlab/TLLibrary64/CRA/data/img/inputData.mat';
% CRA_enterFunc(alpha,beta,gamma,lambda,numK,maxIter,flag,inputPath)

alpha=1;
beta=0.5;
gamma=0.00001;
numK=10;
numC=2;
maxIter=100;
flag=1;
TrainXPath='D:/chengxh/matlab/TLLibrary/TLDA/data/img/TrainData.mat';
TrainYPath='D:/chengxh/matlab/TLLibrary/TLDA/data/img/TrainLabel.mat';
TestXPath='D:/chengxh/matlab/TLLibrary/TLDA/data/img/TestData.mat';
TestYPath='D:/chengxh/matlab/TLLibrary/TLDA/data/img/TestLabel.mat';
InputPath='TLDA/data/img/inputData.mat'
% TLDA_enterFunc(alpha,beta,gamma,numK,maxIter,flag,InputPath)

alpha=1;
beta=0.5;
gamma=0.00001;
lambda=0.00001;
numK=10;
sourceSize='166 200 185';
maxIter=10;
flag=1;
TrainXPath='D:/chengxh/matlab/TLLibrary/CRA/data/img/TrainData.mat';
TrainYPath='D:/chengxh/matlab/TLLibrary/CRA/data/img/TrainLabel.mat';
TestXPath='D:/chengxh/matlab/TLLibrary/CRA/data/img/TestData.mat';
TestYPath='D:/chengxh/matlab/TLLibrary/CRA/data/img/TestLabel.mat';
%CRA_enterFunc(alpha,beta,gamma,lambda,numK,sourceSize,maxIter,flag,TrainXPath,TrainYPath,TestXPath,TestYPath)

alpha=2.4;
beta=2.4;
numCluster=15;
maxIter=200;
TrainXPath='MTrick/data/TrainData.mat';
TrainYPath='MTrick/data/TrainLabel.mat';
TestXPath='MTrick/data/TestData.mat';
TestYPath='MTrick/data/TestLabel.mat';
inputPath='data.mat';
% result = MTrick_enterFunc(alpha,beta,numCluster,maxIter,inputPath);

numIdentical=20;
numAlike=20;
numDistinct=10;
numIter=10;
inputPath='data.mat';
HIDC_enterFunc(numIdentical,numAlike,numDistinct,numIter,inputPath)

numIdentical=20;
numAlike=20;
numDistinct=10;
numIter=100;
sourceSize = '1976';
targetSize = '1977';
TrainXPath='TriTL/data/TrainData.mat';
TrainYPath='TriTL/data/TrainLabel.mat';
TestXPath='TriTL/data/TestData.mat';
TestYPath='TriTL/data/TestLabel.mat';
InputPath='data.mat';
% TriTL_enterFunc(numIdentical,numAlike,numDistinct,numIter,InputPath)

numCluster=64;
maxIter=10;
inputPath='data.mat';
% CDPLSA_enterFunc(numCluster,maxIter,inputPath)

numIdentical=20;
numAlike=20;
numDistinct=10;
numIter=500;
inputPath='data.mat';
% HIDC_enterFunc(numIdentical,numAlike,numDistinct,numIter,inputPath)

alpha=0.4;
beta=15;
gamma=0.12;
threshold=0.1;
inputPath='D:/chengxh/matlab/TLLibrary64/IHR/data/inputData.mat';
neighborPath='D:/chengxh/matlab/TLLibrary64/IHR/data/KneighborFile.txt';
%IHR_enterFunc(alpha,beta,gamma,threshold,inputPath,neighborPath)

inputPath='D:/chengxh/matlab/TLLibrary64/MAMUDA/data/inputData.mat';
ite1=4;
ite2=4;
itermediateD=50;
reducedD=50;
sharedD=50;
% meanF1=MAMUDA_enterFunc(inputPath,ite1,ite2,itermediateD,reducedD,sharedD);

inputPath='D:/chengxh/matlab/TLLibrary64/CSL_MTMV/data/inputData.mat';
ite=20;
h=15;
alpha=0.0039;
beta=0.0078;
gamma=0.0039;
% meanF1=CASO_MVMT_enterFunc(inputPath,ite,h,alpha,beta,gamma);

inputPath='CCR3/data/inputData.mat';
gamma=150;
%results=CCR3_enterFunc(gamma, inputPath);