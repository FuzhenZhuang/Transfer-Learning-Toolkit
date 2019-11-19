function [w,run] = train_lmbfgs(x,w,lambda)
% Limited-memory BFGS method
% Performs just like CG

% Written by Thomas P Minka

if nargin < 3
  lambda = 0;
end
flops(0);
[d,n] = size(x);
old_g = zeros(size(w));
for iter = 1:1000
  old_w = w;
  % s1 = 1-sigma
  s1 = 1./(1+exp(w'*x));
  g = x*s1' - lambda*w;
  flops(flops + flops_mul(w',x) + n*(flops_exp+2) + flops_mul(x,s1') + 2*d);
  if iter > 1
    dw = w - prev_w;
    dg = g - old_g;
    dwdg = dw'*dg;
    b = 1 + (dg'*dg)/dwdg;
    ag = dw'*g/dwdg;
    aw = dg'*g/dwdg - b*ag;
    u = -g + aw*dw + ag*dg;
    flops(flops + d + d + flops_mul(dw',dg) + flops_mul(dg',dg)+2 + ...
	flops_mul(dw',g)+1 + flops_mul(dg',g)+3 + 4);
  else
    u = -g;
  end
  prev_w = w;

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
  run.e(iter) = logProb(x,w) -0.5*lambda*w'*w;

  if max(abs(w - old_w)) < 1e-5
    break
  end
end
figure(2)
plot(run.e)
if iter == 1000
  warning('not enough iters')
end
