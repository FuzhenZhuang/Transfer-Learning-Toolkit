clear all

%define the global variables
global TrainSetX;
global TrainSetY;
global TrainXY;
global TestSetX;
global TestSetY;

global eta;
global gama;
global afa;
global npos;

global kneighbor_test;
global kneighbor_testp;
global kneighbor_mix;

%set the parameters
afa = 0.4;
gama = 15;
eta = 0.12;


kneighbor_testp = textread('KneighborFile.txt'); 
kneighbor_testp = kneighbor_testp(:,1:(size(kneighbor_testp,2)-1));
kneighbor_testp = kneighbor_testp + 1;
A = textread('data/Train1.data');
TrainSetX = spconvert(A);
A = textread('data/Test1.data');
TestSetX = spconvert(A);
clear A;
TrainSetY = textread('data/Train1.label');
TestSetY = textread('data/Test1.label');
indexi = find(TestSetY == 1);
npos = sum(TestSetY(indexi)); 

TrainXY = scale_cols(TrainSetX,TrainSetY);
DataX = [TrainSetX TestSetX];
pos = 0;
% read the model trained from Logistic Regression
wbest = textread('orimodel.model');
ptemp = 1./(1 + exp(-wbest'*TrainSetX));
Uconf_mix = [ptemp',1-ptemp'];
TrainA = getResult(ptemp,TrainSetY);
ptemp = 1./(1 + exp(-wbest'*TestSetX));
TestA = getResult(ptemp,TestSetY);
Uconf_mix = [Uconf_mix;[ptemp',1-ptemp']];
clear ptemp;
fprintf('The original training and testing accuracy:  %g:    %g  ...... %g\n',pos,TrainA*100,TestA*100);result = [];
[W,result] = PRP_CG(wbest,npos,gama,afa,0.1);
ptemp = 1./(1 + exp(-W'*TestSetX));
TestA = getResult(ptemp,TestSetY);
fprintf('The final testing accuracy: %g\n',TestA*100);
result(1,length(result)+1) = TestA;
xlswrite('result.xls',result');


