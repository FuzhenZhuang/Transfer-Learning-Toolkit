function [w,run] = train_newton(x,w,lambda)
% TRAIN_NEWTON    Train a logistic regression model by Newton's method.
%
% W = TRAIN_NEWTON(X,W) returns maximum-likelihood weights given data and a
% starting guess.
% Data is columns of X, each column already scaled by the output.
% W is the starting guess for the parameters (a column).
% If it fails, try initializing with smaller magnitude W.
% W = TRAIN_NEWTON(X,W,LAMBDA) returns MAP weights with smoothing parameter
% LAMBDA.

% Written by Thomas P Minka

if 0
  % test slash
  % (d,d)\(d,1) is O(d^3)
  t = [];
  t2 = [];
  fl = [];
  fl2 = [];
  ns = 100:100:500;
  for i = 1:length(ns)
    n = ns(i);
    a = randn(n);
    b = randn(n,1);
    flops(0); tic; a\b; t(i) = toc; fl(i) = flops;
    flops(0); tic; lu_solve(a,b); t2(i) = toc; fl2(i) = flops;
  end
  loglog(ns, t, ns, t2);
end
if nargin < 3
  lambda = 0;
end
[d,n] = size(x);
flops(0);
for iter = 1:1000
  old_w = w;
  % s1 = 1-sigma
  % s1 is 1 by n
  s1 = 1./(1+exp(w'*x));
  a = s1.*(1-s1);
  if 0
    z = w'*x + (1-s)./a;
    w = lscov(x',z',diag(1./a));
  else
    g = x*s1' - lambda*w;
    tempM = sparse(d,d);
    for ii = 1:d
        tempM(ii,ii) = lambda;
    end
    
%    h = sparse(d,d);
%    tempx = scale_cols(x,a);
%    for ii = 1:d
%        for iii = 1:d
%            h(ii,iii) = 0;
%            for iiii = 1:size(x,2)
%            end
%        end
%    end
        
    h = scale_cols(x,a)*x' + tempM;
    %    h = scale_cols(x,a)*x' + lambda*eye(d);
    % w = w + h\g;
    h1 = InverseM(h);
    clear h;
    w = w + h1*g;
    clear h1;
    clear tempM;
  end
  
  if nargout > 1
    flops(flops + flops_mul(w',x) + n*(flops_exp+2) + n*2);
    flops(flops + flops_mul(x,s1')+2*d + d*n+flops_mul(x,x')+d*d + ...
	+ d+flops_solve(d,d,1));
    run.w(:,iter) = w;
    run.flops(iter) = flops;
    run.e(iter) = logProb(x,w) -0.5*lambda*w'*w;
  end
  
  if max(abs(w - old_w)) < 1e-8
    break
  end
end
if nargout > 1
  figure(2)
  plot(run.e)
end
if iter == 50
  warning('not enough iters')
end
