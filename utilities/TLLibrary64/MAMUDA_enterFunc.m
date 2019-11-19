function meanF1 = MAMUDA_enterFunc(inputPath,ite1,ite2,itermediateD,reducedD,sharedD)
    load(inputPath); 
    [result,F1,meanF1,R,Rt,Q]=MAMUDA(testfea,testlabel,trainFea,trainLabel,unlabelFea,unlabelLabel,ite1,ite2,0.0,itermediateD,reducedD,sharedD,2);
end