function [w,run] = train_newton2(x,w,lambda)
% TRAIN_NEWTON2    Train a logistic regression model by coordinate-wise Newton.
%
% W = TRAIN_NEWTON2(X,W) returns maximum-likelihood weights given data and a
% starting guess.
% Data is columns of X, each column already scaled by the output.
% W is the starting guess for the parameters (a column).

% Written by Thomas P Minka

[d,n] = size(x);
x2 = x.*x;
wx = w'*x;
flops(d*n + flops_mul(w',x));
for iter = 1:1000
  old_w = w;
  for k = 1:length(w)
    % s1 = 1-sigma
    s1 = 1./(1+exp(wx));
    a = s1.*(1-s1);
    g = x(k,:)*s1' - lambda*w(k);
    h = x2(k,:)*a' + lambda;
    delta = g/h;
    w(k) = w(k) + delta;
    wx = wx + delta.*x(k,:);
  end
  if iter == 1
    fl = d*(n*(flops_exp+2+2)+flops_mul(x(k,:),s1')+2 + ...
	flops_mul(x2(k,:),a')+1 + 1 + 1 + 2*n));
  end
  flops(flops + fl);
  
  run.w(:,iter) = w;
  run.flops(iter) = flops;
  run.e(iter) = logProb(x,w) -0.5*lambda*w'*w;
  
  if max(abs(w - old_w)) < 1e-6
    break
  end
end
figure(2)
plot(run.e)
if iter == 1000
  warning('not enough iters')
end
