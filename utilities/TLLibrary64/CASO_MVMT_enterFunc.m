function meanF1 = CASO_MVMT_enterFunc(inputPath,ite,h,alpha,beta,gamma)
    load(inputPath);
    [result,F1,meanF1,U,Z,Theta]=CASO_MVMT(fea,label,trainFea,trainLabel,unlabelFea,unlabelLabel,ite,h,alpha,beta,gamma);
end