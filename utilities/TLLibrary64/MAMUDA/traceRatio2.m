function Q= traceRatio2(Sb,Sh,A,ite)
% compute the traceRatio problem,using Algorithm 2 in jinx paper.
% -Sb: input matrix, it is a square matrix
% -Sh: input matrix, it is a square matrix
% -A: input square matrix, the dimension of A is less than Sb and Sh;
% -ite: the max iteration number
% -Q: the output matrix,contains reducedDimension columns


tmp=size(Sb);
rowNum=tmp(1); % row number of matrix Q
tmp=size(A);
colNum=tmp(1); % column number of matrix Q
Q=eye(rowNum);
Q=Q(:,1:colNum);


for i=1:ite %迭代求解Q
    oldQ=Q;


    lambda=trace(Q'*Sb*Q*A)/trace(Q'*Sh*Q*A); % line 3 in Algorithm 2
    tmp=Sb-lambda*Sh;  % line 4
    [tmpv,tmpd]=eig(tmp);
    tmpv=real(tmpv);
    tmpd=real(tmpd);
    tmp=sum(tmpd);
    [tmp, tmpi]=sort(tmp,2, 'descend');% 按行降序排列
    tmpv=tmpv(:,tmpi);
    Q=tmpv(:,1:colNum);
    [tmpv,tmpd]=eig(A);
    tmpv=real(tmpv);
    Q=Q*tmpv';
    
    % Reshape the projection matrix for the sake of orthogonal transformation invariance
    % line 6 and after
    
    %|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
     % 两种方法，第一种：原始方法
      tmp=Q*Q'*Sh*Q*Q';
    %|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||    
         % 两种方法，第二种： 将Sh乘以一个比较大的数，防止太小导致误差太大，并保证是对称的。
     
%      myscale=size(Q,1);
%      myQ=Q.*myscale;
%      tmp=myQ*(myQ')*Sh*myQ*(myQ');
%      tmp=(tmp+tmp')./2;
%      tmp=tmp./(myscale^4);
    %|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    

    [tmpv,tmpd]=eig(tmp);
    
    tmpv=real(tmpv);
    tmpd=real(tmpd);   
    
%     if sum(sum(abs(tmp-tmpv*tmpd*tmpv')))/rowNum/rowNum>0.00001
%         disp('svd error');
%     end
    tmp=sum(tmpd);    
    [tmp, tmpi]=sort(tmp,2, 'descend');% 按行降序排列
    tmpv=tmpv(:,tmpi);
    Q=tmpv(:,1:colNum);
  
    
%     if sum(sum(abs(oldQ-Q)))<rowNum*colNum*0.001
%         break;
%     end
end

end
