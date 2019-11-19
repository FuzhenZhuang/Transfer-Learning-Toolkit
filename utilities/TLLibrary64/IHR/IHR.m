function [W,result] = IHR(Ws,npos,gama,afa,yuzhi)
global eta;
global TrainSetX;
global TestSetX;
global TestSetY;
global kneighbor_testp;

global W0;
global s11;
global w1;
global index1;
W0 = Ws;
w1 = Ws;

tempsum1 = 0;
for i=1:size(TestSetX,2)
    tempKN = kneighbor_testp(i,:);
    tempTuples = TestSetX(:,tempKN);
    s1 = w1'*tempTuples;
    p1 = 1./(1 + exp(-s1));
    tempsum1 = tempsum1 + (sum(p1)/size(kneighbor_testp,2)-1/(1+exp(-w1'*TestSetX(:,i))))^2;
end

tempsum2 = 0;
for i=1:size(TestSetX,2)
    tempsum2 = tempsum2 + (1/(1+exp(-w1'*TestSetX(:,i))) - 0.5)^2;
end

s1 = w1'*TestSetX;
p1 = 1./(1 + exp(-s1));

f = ((w1)'*(w1))+afa*tempsum1/size(TestSetX,2)-gama*tempsum2/size(TestSetX,2)+eta*(sum(p1)-npos)^2/size(TestSetX,2); %07-12-31
fprintf('initial value...%g\n',f);
index1 = 0;

result(1,1) = getResult(p1,TestSetY);
ff(1,1) = f;
warning off;
while index1 < 100

    temp11 = zeros(size(TestSetX,1),1);
    s11 = zeros(size(TestSetX,1),1);
    for i=1:size(TestSetX,2)
        tempKN = kneighbor_testp(i,:);
        tempTuples = TestSetX(:,tempKN);
        s1 = w1'*tempTuples;
        p1 = 1./(1 + exp(-s1));
        tmp_p1 = sum(p1)/size(kneighbor_testp,2)-1/(1+exp(-w1'*TestSetX(:,i)));
        p2 = exp(-s1)./((1 + exp(-s1)).^2);
        for k = 1:size(kneighbor_testp,2)
            temp11 = temp11 + tempTuples(:,k)*p2(1,k);
        end
        temp11 = temp11/size(kneighbor_testp,2) - (exp(-w1'*TestSetX(:,i))/(1+exp(-w1'*TestSetX(:,i)))^2)*TestSetX(:,i);
        s11 = s11 + 2*tmp_p1*temp11;
    end
    s11 = afa*s11/size(TestSetX,2); % 



    s12 = zeros(size(TestSetX,1),1);
    for i = 1:size(TestSetX,2)
        s12 = s12 + 2*gama*(1/(1+exp(-w1'*TestSetX(:,i))) - 0.5)*((exp(-w1'*TestSetX(:,i)))/(1+exp(-w1'*TestSetX(:,i)))^2)*TestSetX(:,i);
    end
    s12 = s12/size(TestSetX,2);

    s1 = w1'*TestSetX;
    p1 = 1./(1 + exp(-s1));
    tmps13 = 2*eta*(sum(p1)-npos)*(exp(-w1'*TestSetX)./(1+exp(-w1'*TestSetX)).^2);
    s13 = sum(scale_cols(TestSetX,tmps13),2);
    s13 = s13/size(TestSetX,2);

    if [s11-s12+s13+2*(w1)]'*[s11-s12+s13+2*(w1)] < yuzhi^2
        break;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if index1 == 0
        d0 = -s11+s12-s13-2*(w1);
    end
    if index1 > 0
        afa0 = ([s11-s12+s13+2*(w1)]'*[s11-s12+s13+2*(w1)-temp_s11-temp_s12])/([temp_s11+temp_s12]'*[temp_s11+temp_s12]);
        d1 = [-s11+s12-s13-2*(w1)] + afa0*d0;
        d0 = d1;
    end

    temp_s11 = s11;
    temp_s12 = -s12+s13+2*(w1);

    s11 = d0;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    beta = 0;

    options = optimset('LargeScale','on');
    [x,fval] = fminunc(@objfun,beta,options);

    beta = x;
    if beta == 0
        break;
    end
    w1 = w1 + beta*d0;

    tempsum1 = 0;
    for i=1:size(TestSetX,2)
        tempKN = kneighbor_testp(i,:);
        tempTuples = TestSetX(:,tempKN);
        s1 = w1'*tempTuples;
        p1 = 1./(1 + exp(-s1));
        tempsum1 = tempsum1 + (sum(p1)/size(kneighbor_testp,2)-1/(1+exp(-w1'*TestSetX(:,i))))^2;
    end

    tempsum2 = 0;
    for i=1:size(TestSetX,2)
        tempsum2 = tempsum2 + (1/(1+exp(-w1'*TestSetX(:,i))) - 0.5)^2;
    end

    s1 = w1'*TestSetX;
    p1 = 1./(1 + exp(-s1));

    f = ((w1)'*(w1))+afa*tempsum1/size(TestSetX,2)-gama*tempsum2/size(TestSetX,2)+eta*(sum(p1)-npos)^2/size(TestSetX,2); %07-12-31

    s1 = w1'*TestSetX;
    p1 = 1./(1 + exp(-s1));
    index1 = index1+1;
    result(1,index1+1) = getResult(p1,TestSetY);
    ff(1,index1+1) = f;

    fprintf('iterating...%g value : %g...the accuracy:%g\n',index1,f,getResult(p1,TestSetY));

end
W = w1;
