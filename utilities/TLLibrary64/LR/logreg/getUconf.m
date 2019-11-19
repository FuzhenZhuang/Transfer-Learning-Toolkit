clear all;
load Trainselect.data
TrainX = spconvert(Trainselect);
TrainY = textread('trainset_label.txt')';
load Testselect.data
TestX = spconvert(Testselect);
 
load Trainselect_1.data
TrainX1 = spconvert(Trainselect_1);
TrainY1 = textread('trainset_label_1.txt')';
load Testselect_1.data
TestX1 = spconvert(Testselect_1);
load Trainselect_2.data
TrainX2 = spconvert(Trainselect_2);
TrainY2 = textread('trainset_label_2.txt')';
load Testselect_2.data
TestX2 = spconvert(Testselect_2);
load Trainselect_3.data
TrainX3 = spconvert(Trainselect_3);
TrainY3 = textread('trainset_label_3.txt')';
load Testselect_3.data
TestX3 = spconvert(Testselect_3);
TestY = textread('testset_label_1.txt')';
TrainXY = scale_cols(TrainX,TrainY);
TrainXY1 = scale_cols(TrainX1,TrainY1);
TrainXY2 = scale_cols(TrainX2,TrainY2);
TrainXY3 = scale_cols(TrainX3,TrainY3);
fprintf('.....................................\n');
w00 = zeros(size(TrainXY,1),1);
lambda = exp(linspace(-0.5,6,8));
f1max = -inf;
for i = 1:length(lambda)
   w_0 = train_cg(TrainXY,w00,lambda(i));
   f1 = logProb(TrainXY,w_0);
   if f1 > f1max
       f1max = f1;
       wbest = w_0;
   end        
end
ptemp = 1./(1 + exp(-wbest'*TestX));
fprintf('total result:%g\n',getResult(ptemp,TestY));
mergeUConf = [1./(1+exp(-wbest'*TrainX)),ptemp]';

csvwrite('Uconf_mix.txt',[mergeUConf,1-mergeUConf]);

W0 = textread('W_3_0.001.txt');
w1 = W0(1:size(TrainXY1),1);
w2 = W0((size(TrainXY1)+1):(size(TrainXY1)+size(TrainXY2)),1);
w3 = W0((size(TrainXY1)+size(TrainXY2)+1):(size(TrainXY1)+size(TrainXY2)+size(TrainXY3)),1);

ptemp = 1./(1 + exp(-w1'*TestX1));
fprintf('domain result:%g\n',getResult(ptemp,TestY));
domianUConf = [1./(1+exp(-w1'*TrainX1)),ptemp]';
csvwrite('domain_Uconf_1.txt',[domianUConf,1-domianUConf]);

ptemp = 1./(1 + exp(-w2'*TestX2));
fprintf('domain result:%g\n',getResult(ptemp,TestY));
domianUConf = [1./(1+exp(-w2'*TrainX2)),ptemp]';
csvwrite('domain_Uconf_2.txt',[domianUConf,1-domianUConf]);

ptemp = 1./(1 + exp(-w3'*TestX3));
fprintf('domain result:%g\n',getResult(ptemp,TestY));
domianUConf = [1./(1+exp(-w3'*TrainX3)),ptemp]';
csvwrite('domain_Uconf_3.txt',[domianUConf,1-domianUConf]);

