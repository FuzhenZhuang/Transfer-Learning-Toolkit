function [result,F1,meanF1,U,Z,Theta]=CASO_MVMT(fea,label,trainFea,trainLabel,unlabelFea,unlabelLabel,ite,h,alpha,beta,gamma)
%**  Program for the following paper:
%    Xin Jin, Fuzhen Zhuang, Shuhui Wang, Qing He and Zhongzhi Shi. 
%    Shared Structure Learning for Multiple Tasks with Multiple Views. 
%    European Conference on Machine Learning and Principles and Practice of
%    Knowledge Discovery in Databases (ECML-PKDD 2013)
%***********************

%%%%-input parameters
% --fea:    a taskNum-by-viewNum cell array of matrices, each matirx 
%           represents the feature matrix for a views in a task. If a
%           view does not exist for a task, then it is an empty matrix. It
%           contains the testing samples' features.
% --label:  a taskNum dimension cell array of matrices, each matrix 
%           contains the true class labels for a task,it is a column vector (n-by-1
%           matrix), labels are -1 or 1. It contains testing samples' label.
% --trainFea:   a taskNum-by-viewNum cell array of matrices, each matirx 
%           represents the feature matrix for a views in a task. If a
%           view does not exist for a task, then it is an empty matrix. It
%           contains the labeled training samples' features.
% --trainLabel:  a taskNum dimension cell array of matrices, each matrix 
%           contains the true class labels for a task,it is a column vector (n-by-1
%           matrix), labels are -1 or 1. It contains labeled training samples'
%           ture class label.
% --unlabelFea:    a taskNum-by-viewNum cell array of matrices, each matirx 
%           represents the feature matrix for a views in a task. If a
%           view does not exist for a task, then it is an empty matrix. It
%           contains the unlabeled  samples' features.
% --unlabelLabel:  a taskNum dimension cell array of matrices, each matrix 
%           contains the true class labels for a task,it is a column vector (n-by-1
%           matrix), labels are -1 or 1. It contains unlabeled  samples'
%           label. This information is not used in the current version.
%--ite:     the maximum iteration number
%--h:       the dimension of the shared low dimensional feature space
%--alpha,beta,gamma: parameters used in Eq.(13),(15) in the paper

%%%%-return values
%--result:  a taskNum dimension cell array of matrices, each  matrix contains
%           the predicted class labels for the testing samples in a task
%--F1:      a taskNum dimension vector, each element is the F1 measure for a task
%--meanF1:  mean F1 for all the tasks, i.e.,meanF1=mean(F1);
%--U:       a taskNum-by-viewNum cell array of matrices, each matrix is a column
%           vector contains the weitht vector u_t^v for the view in a task
%--Z:       a taskNum-by-viewNum cell array of matrices, each matrix is a column
%           vector contains the weitht vector z_t^v for the view in a task
%--Theta:   a viewNum cell array of matrices, each matrix is Theta^v for a
%           specific view v


    %%%%    Authors:    Xin Jin
    %%%%    Institute of Computing Technology, Chinese Academy of Sciences (CAS)
    %%%%    EMAIL:      jinx@ics.ict.ac.cn
    %%%%    DATE:       APRIL 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eta=beta/alpha;
tmp=size(fea);
taskNum=tmp(1);% --taskNum: number of tasks for the problem
% --viewNum: number of all the views in the problem
viewNum=tmp(2);



% construct the view indicator matrix, if a view v exists in task t, then
% viewLabel(t,v)=1, otherwise, 0.
featureNum=zeros(1,viewNum);% record the number of features in each view 
viewLabel=zeros(taskNum,viewNum);% the view indicator matrix
sampleNum=zeros(1,taskNum);% record the number of testing samples in each task
for i=1:taskNum
    for j=1:viewNum
        tmp=cell2mat(fea(i,j));
        tmpsize=size(tmp);
        if tmpsize(1)>0
            viewLabel(i,j)=1;
            featureNum(j)=tmpsize(2); 
            sampleNum(i)=tmpsize(1);
            fea(i,j)=mat2cell(sparse(tmp),tmpsize(1),tmpsize(2));
        end
    end
end

tmp=cell2mat(trainLabel(1));
tmp=size(tmp);
trainNum=max(tmp);
tmp=cell2mat(unlabelLabel(1));
tmp=size(tmp);
unlabelNum=max(tmp);



%----the training process -----------------------------
U=cell(taskNum,viewNum);
Z=cell(taskNum,viewNum);
Theta=cell(viewNum,1);
M=cell(viewNum,1);
for i=1:viewNum
    tmp=h/featureNum(i);
    tmp1=ones(1,featureNum(i))*tmp;
    tmp=diag(tmp1);
    M(i)=mat2cell(tmp,featureNum(i),featureNum(i));    
end

%--alpha,beta,gamma 
for itenum=1:ite
    % construct the matrix L_t in Eq.(17).Because it is symetric, only the lower triangular matrix are computed
    % construct matrix R in Eq.(17), compute u_t^v
    for i=1:taskNum
        L=zeros(sum(featureNum));
        R=zeros(sum(featureNum),1);
        for v=1:viewNum
            if viewLabel(i,v)
                %compute A_t^v
                tmpx=cell2mat(trainFea(i,v));
                tmpa=tmpx'*tmpx*2/trainNum;
                tmpx=cell2mat(unlabelFea(i,v));
                tmpa=tmpa+tmpx'*tmpx*gamma*2*(sum(viewLabel(i,:))-1)/unlabelNum;
                if sum(viewLabel(:,v))>1 % if a view exists in more than one tasks, then learn the shared low dimensional space
                    mv=cell2mat(M(v));
                    tmpa=tmpa+inv(eta*eye(featureNum(v))+mv)*2*alpha*eta*(1+eta);
                    clear mv;
                else
                    tmpa=tmpa+ eye(featureNum(v))*beta*2;
                end
                clear tmpx;
                curi=sum(featureNum(1:v-1));
                L(curi+1:curi+featureNum(v),curi+1:curi+featureNum(v))=tmpa;
                clear tmpa;
                
                %compute B_tv
                for j=1:v-1
                    if viewLabel(i,j)
                        tmpx=cell2mat(unlabelFea(i,v));
                        tmpx2=cell2mat(unlabelFea(i,j));
                        tmpb=tmpx'*tmpx2*(-gamma)*2/unlabelNum;
                        curi=sum(featureNum(1:v-1));
                        curj=sum(featureNum(1:j-1));
                        L(curi+1:curi+featureNum(v),curj+1:curj+featureNum(j))=tmpb;
                        L(curj+1:curj+featureNum(j),curi+1:curi+featureNum(v))=tmpb';
                    end
                end
                clear tmpx;
                clear tmpx2;
                clear tmpb;
                
                % compute matrix R_t
                tmpx=cell2mat(trainFea(i,v));
                tmpy=cell2mat(trainLabel(i));
                tmpc=tmpx'*tmpy*2/trainNum;
                R(sum(featureNum(1:v-1))+1:sum(featureNum(1:v)),1)=tmpc;  
                clear tmpx;
                clear tmpy;
                clear tmpc;
                
            end
        end
        % delect the rows and columns that do not exist in matrix L_t, R_t
        tmp=viewLabel(i,:);
        tmp=tmp==0;
        tmpi=find(tmp);
        toDelete=[];
        for ii=tmpi
            tmptmp=sum(featureNum(1:ii-1))+1:sum(featureNum(1:ii));
            toDelete=[toDelete tmptmp];
        end
        L(toDelete,:)=[];
        L(:,toDelete)=[];
        R(toDelete,:)=[];
        tmpw=L\R; % Replace inv(A)*b with A\b;Replace b*inv(A) with b/A
        
        tmp=viewLabel(i,:);
        tmpi=find(tmp);
        tmps=max(size(tmpi));
        tmptmp=0;
        for ii=1:tmps
            myw=tmpw(tmptmp+1:tmptmp+featureNum(tmpi(ii)));
            U(i,tmpi(ii))=num2cell(myw,[1,2]);
            tmptmp=tmptmp+featureNum(tmpi(ii));
        end      
        
   
        
    end
    clear L;
    clear R;
    clear tmpw;
    
    %compute the matrix M_v
    for v=1:viewNum
        if sum(viewLabel(:,v))<=1
            continue;
        end
        tv=sum(viewLabel(:,v));
        tmpu=zeros(featureNum(v),tv);
        j=1;
        for i=1:taskNum
            if viewLabel(i,v)
                tmpu(:,j)=cell2mat(U(i,v));
                j=j+1;
            end
        end
        [tmpp1,tmps,tmpp2]=svd(tmpu);

        if h>=tv % the dimension of the shared low dimensional feature space is larger than the number of tasks 
            tmpm=zeros(size(tmpp1));
            tmpm(:,1:h)=tmpp1(:,1:h);
            tmpm=tmpm*tmpp1';
        else
            Sigma=sum(tmps);
            Sigma=Sigma';
            tmpx=(h/tv)*ones(size(Sigma));
            Aeq=ones(1,tv);
            %options=optimset('Algorithm','active-set');
            %options=optimset('Algorithm','interior-point');
             %options=optimset('Algorithm','sqp');
             options = optimoptions('fmincon','Algorithm','sqp','FunValCheck','off','DerivativeCheck','off','GradObj','on');
             %options=optimset('FunValCheck','off');
             %options = optimoptions(SolverName,oldoptions)
             %options = optimoptions('fmincon','FunValCheck','off');
            tmpx= fmincon(@myproblem,tmpx,[],[],Aeq,h,zeros(size(Sigma)),ones(size(Sigma)),[],options);
            tmpm=zeros(size(tmpp1));
            for i=1:tv
                tmpm(:,i)=tmpp1(:,i)*tmpx(i);
            end
            tmpm=tmpm*tmpp1';
        end
        M(v)=mat2cell(tmpm,featureNum(v),featureNum(v));       
        
    end
    clear tmpp1;
    clear tmps;
    clear tmpp2;
    clear tmpm;
    
end

%  compute Theta and Z
for v=1:viewNum
    tmpm=cell2mat(M(v));
    [vv,dd]=eig(tmpm);
    dd=sum(dd);
    [bb,idx]=sort(dd,'descend');
    idx=idx(1:h);
    tmptha=vv(:,idx);
    tmptha=tmptha';
    
    Theta(v)=mat2cell(tmptha,h,featureNum(v));
    for i=1:taskNum
        if viewLabel(i,v)
            tmpu=cell2mat(U(i,v));
            tmpz=tmptha*tmpu;
            Z(i,v)=num2cell(tmpz,[1,2]);
        end        
    end
end
clear  vv;
clear tmpm;
clear bb;
clear tmptha;
clear tmpu;
clear tmpz;




% predict the labels for the testing samples stored in matrix fea
result=cell(taskNum,1);
F1=zeros(taskNum,1);
for i=1:taskNum
    tmpNum=sampleNum(i);
    tmplabel=zeros(tmpNum,1);
    [tmpi,tmpj,tmps]=find(viewLabel(i,:));
    for j=tmpj
        tmpfea=cell2mat(fea(i,j));
        tmpw=cell2mat(U(i,j));
        tmplabel=tmplabel+tmpfea*tmpw;
    end
    
        tmplabel=tmplabel>=0;
    tmptmp=cell2mat(label(i));
    tmptmp=tmptmp>=0;
    tp=sum(and(tmplabel,tmptmp));
    precision=tp/(sum(tmplabel)+1e-6);
    recall=tp/(sum(tmptmp)+1e-6);
    
    F1(i)=2*precision*recall/(precision+recall+1e-6);
end
    meanF1=mean(F1);

%--------------------------------------------fmincon   eig svd

% the transformed optimization problem 
function [obj,tmpGradient]=myproblem(a) % a is a column vector, same size as Sigma.
% length=max(size(a));
%a=a+1e-7;
Sigma=Sigma.^2;
a=a+eta;
tmp=Sigma./a;
obj=sum(tmp);
tmpGradient=-Sigma.*(a.^(-2));
end

end

