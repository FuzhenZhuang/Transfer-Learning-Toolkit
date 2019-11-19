function Results = MTrick(TrainX,TrainY,TestX,TestY,alpha,beta,numK,numCircle)

for id = 1:length(TrainY)
    if TrainY(id) == 2
        TrainY(id) = -1;
    end
end

for id = 1:length(TestY)
    if TestY(id) == 2
        TestY(id) = -1;
    end
end

G0 = [];
for i = 1:length(TrainY)
    if TrainY(i) == 1
        G0(i,1) = 1;
        G0(i,2) = 0;
    else
        G0(i,1) = 0;
        G0(i,2) = 1;
    end
end

TrainXY = scale_cols(TrainX,TrainY);
fprintf('......start to train logistic regression model1111.........\n');
w00 = zeros(size(TrainXY,1),1);
lambda = exp(linspace(-0.5,6,20));
wbest = [];
f1max = -inf;
for i = 1:length(lambda)
    w_0 = train_cg(TrainXY,w00,lambda(i));
    f1 = logProb(TrainXY,w_0);
    if f1 > f1max
        f1max = f1;
        wbest = w_0;
        se_lambda = lambda(i);
    end
end
% csvwrite(strcat('model_','test','.model'),wbest);
% wbest = load(strcat('model_','test','.model'));

ptemp = 1./(1 + exp(-wbest'*TrainX));
oriA = getResult(ptemp,TrainY);
fprintf('Test accuracy on source domain is :%g\n',oriA);
ptemp = 1./(1 + exp(-wbest'*TestX));
oriA = getResult(ptemp,TestY);
fprintf('Test accuracy on target domain is :%g\n',oriA);

fprintf('......start to learn PLSA model.........\n');
DataSetX = [TrainX TestX];
% set some variables
Learn.Verbosity = 1;
Learn.Max_Iterations = 50;
Learn.heldout = .1; % for tempered EM only, percentage of held out data
Learn.Min_Likelihood_Change = 1;
Learn.Folding_Iterations = 20; % for TEM only: number of fiolding
% in iterations
Learn.TEM = 0; %tempered or not tempered

[Pw_z,Pz_d,Pd,Li,perp,eta] = pLSA(DataSetX,[],numK,Learn);
pz = Pz_d*Pd';
pw = Pw_z*pz;
A = Pw_z;
for i = 1:size(Pw_z,1)
    A(i,:) = A(i,:).*pz';
end

for i = 1:size(Pw_z,2)
    for j = 1:length(A(:,i))
        if pw(j) > 0
            A(j,i) = A(j,i)./pw(j);
        else
            A(j,i) = 1/size(Pw_z,2);
        end
    end
end
pwz = A;
clear A;
% csvwrite(strcat('pwz_common.pwz'),pwz);
% 
% pwz = load(strcat('pwz_common.pwz'));

Fs = pwz;
Ft = Fs;

Gs = G0;
Gt = [];
for i = 1:length(TestY)
    Gt(i,1) = ptemp(i);
    Gt(i,2) = 1 - ptemp(i);
end

Xs = TrainX;
Xt = TestX;
Xs = Xs/sum(sum(Xs));
Xt = Xt/sum(sum(Xt));

b = 1/(size(Gs,1));

S = ones(size(Fs,2),size(Gs,2));
for i = 1:size(S,1)
    S(i,:) = S(i,:)/sum(S(i,:));
end

fvalue = trace(Xs'*Xs-2*Xs'*Fs*S*Gs'+Gs*S'*Fs'*Fs*S*Gs')+alpha*b*trace(Gs*Gs'-2*Gs*G0'+G0*G0')+beta*trace(Xt'*Xt-2*Xt'*Ft*S*Gt'+Gt*S'*Ft'*Ft*S*Gt');
tempf = 0;
for circleID = 1:numCircle
    tempM = (Fs*S*Gs'*Gs*S');
    tempM1 = Xs*Gs*S';
    for i = 1:size(Fs,1)
        for j = 1:size(Fs,2)
            if tempM(i,j)~=0
                Fs(i,j) = Fs(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Fs(i,j) = 0;
            end
        end
    end
    for i = 1:size(Fs,1)
        if sum(Fs(i,:))~= 0
            Fs(i,:) = Fs(i,:)/sum(Fs(i,:));
        else
            for j = 1:size(Fs,2)
                Fs(i,j) = 1/(size(Fs,2));
            end
        end
    end
    tempM = (Gs*S'*Fs'*Fs*S+alpha*b*Gs);
    tempM1 = Xs'*Fs*S + alpha*b*G0;
    for i = 1:size(Gs,1)
        for j = 1:size(Gs,2)
            if tempM(i,j)~=0
                Gs(i,j) = Gs(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Gs(i,j) = 0;
            end
        end
    end
    for i = 1:size(Gs,1)
        if sum(Gs(i,:))~= 0
            Gs(i,:) = Gs(i,:)/sum(Gs(i,:));
        else
            for j = 1:size(Gs,2)
                Gs(i,j) = 1/(size(Gs,2));
            end
        end
    end
    
    tempM = (Ft*S*Gt'*Gt*S');
    tempM1 = Xt*Gt*S';
    for i = 1:size(Ft,1)
        for j = 1:size(Ft,2)
            if tempM(i,j)~=0
                Ft(i,j) = Ft(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Ft(i,j) =0;
            end
        end
    end
    for i = 1:size(Ft,1)
        if sum(Ft(i,:))~= 0
            Ft(i,:) = Ft(i,:)/sum(Ft(i,:));
        else
            for j = 1:size(Ft,2)
                Ft(i,j) = 1/(size(Ft,2));
            end
        end
    end
    
    tempM = (Gt*S'*Ft'*Ft*S);
    tempM1 = Xt'*Ft*S;
    for i = 1:size(Gt,1)
        for j = 1:size(Gt,2)
            if tempM(i,j)~=0
                Gt(i,j) = Gt(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Gt(i,j) = 0;
            end
        end
    end
    for i = 1:size(Gt,1)
        if sum(Gt(i,:))~= 0
            Gt(i,:) = Gt(i,:)/sum(Gt(i,:));
        else
            for j = 1:size(Gt,2)
                Gt(i,j) = 1/(size(Gt,2));
            end
        end
    end
    
    
    tempM = (Fs'*Fs*S*Gs'*Gs+beta*Ft'*Ft*S*Gt'*Gt);
    tempM1 = Fs'*Xs*Gs+beta*Ft'*Xt*Gt;
    for i = 1:size(S,1)
        for j = 1:size(S,2)
            if tempM(i,j)~=0
                S(i,j) = S(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                S(i,j) = 0;
            end
        end
    end
    
    fvalue = trace(Xs'*Xs-2*Xs'*Fs*S*Gs'+Gs*S'*Fs'*Fs*S*Gs')+alpha*b*trace(Gs*Gs'-2*Gs*G0'+G0*G0')+beta*trace(Xt'*Xt-2*Xt'*Ft*S*Gt'+Gt*S'*Ft'*Ft*S*Gt');
    
    pp = [];
    for i = 1:length(TestY)
        if sum(Gt(i,:))~= 0
            pp(1,i) = Gt(i,1)/sum(Gt(i,:));
        else
            pp(1,i) = 0.5;
        end
    end
    Results(circleID) = getResult(pp,TestY);
    fprintf('the %g iteration is %g,the value of objective is %g\n',circleID,getResult(pp,TestY),fvalue);
    
    if circleID == 1
        tempf = fvalue;
    end
    if circleID > 1
        if abs(tempf - fvalue) < 10^(-11)
            break;
        end
        tempf = fvalue;
    end
end