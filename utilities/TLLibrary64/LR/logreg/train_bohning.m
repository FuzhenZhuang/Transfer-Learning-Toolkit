function [w,run] = train_bohning(x,w,lambda)
% Bohning's method

% Written by Thomas P Minka

if 0
  % test pinv
  % pinv(n,m) is O(n*m^2) (asymmetric)
  t = [];
  ds = 100:100:1000;
  for i = 1:length(ds)
    tic; pinv(randn(ds(i),10)); t(i) = toc;
  end
  loglog(ds,t)
end

if nargin < 3
  lambda = 0;
end
flops(0);
[d,n] = size(x);
h = (x*x')/4 + lambda*eye(d);
r = chol(h);
flops(flops + flops_mul(x,x')+d*d+d + flops_chol(d));
for iter = 1:1000
  old_w = w;
  % s1 = 1-sigma
  s1 = 1./(1+exp(w'*x));
  g = x*s1' - lambda*w;
  flops(flops + flops_mul(w',x) + n*(flops_exp+2) + flops_mul(x,s1') + 2*d);
  % u = H\g
  u = solve_triu(r,solve_tril(r',g));
  flops(flops + 2*flops_solve_tri(d,d,1));
  if 0
    w = w + u;
    flops(flops + d);
  else
    % line search along u
    ug = u'*g;
    ux = u'*x;
    a = s1.*(1-s1);
    uhu = (ux.^2)*a' + lambda*(u'*u);
    w = w + (ug/uhu)*u;
    flops(flops + flops_mul(u',g) + flops_mul(u',x) + 2*n + ...
	n+flops_mul(1,n,1) + 2*d+1);
    if lambda > 0
      flops(flops + 1+flops_mul(u',u));
    end
  end
  
  run.w(:,iter) = w;
  run.flops(iter) = flops;
  run.e(iter) = logProb(x,w) - 0.5*lambda*w'*w;
  
  if max(abs(w - old_w)) < 1e-5
    break
  end
end
figure(2)
plot(run.e)
if iter == 1000
  warning('not enough iters')
end
