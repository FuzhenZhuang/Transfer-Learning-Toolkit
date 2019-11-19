function [w,run] = train_cg(x,w,lambda)
% TRAIN_CG    Train a logistic regression model by conjugate gradient.
%
% W = TRAIN_CG(X,W) returns maximum-likelihood weights given data and a
% starting guess.
% Data is columns of X, each column already scaled by the output (+1 or -1).
% W is the starting guess for the parameters (a column).

% Written by Thomas P Minka

if nargin < 3
  lambda = 0;
end
[d,n] = size(x);
flops(0);
old_g = zeros(size(w));
for iter = 1:1000
  old_w = w;
  % s1 = 1-sigma
  s1 = 1./(1+exp(w'*x));
  g = x*s1' - lambda*w;
  flops(flops + flops_mul(w',x) + n*(flops_exp+2) + flops_mul(x,s1') + 2*d);
  if iter == 1
    u = g;
  else
    u = cg_dir(u, g, old_g);
  end
  
  % line search along u
  ug = u'*g;
  ux = u'*x;
  a = s1.*(1-s1);
  uhu = (ux.^2)*a' + lambda*(u'*u);
  w = w + (ug/uhu)*u;
  old_g = g;
  flops(flops + flops_mul(u',g) + flops_mul(u',x) + 2*n + ...
      n+flops_mul(1,n,1) + 2*d+1);
  if lambda > 0
    flops(flops + 1+flops_mul(u',u));
  end

  run.w(:,iter) = w;
  run.flops(iter) = flops;
  run.e(iter) = logProb(x,w) - 0.5*lambda*w'*w;

  if max(abs(w - old_w)) < 1e-5
    break
  end
end
%figure(2)
%plot(run.e)
if iter == 1000
  warning('not enough iters')
end
