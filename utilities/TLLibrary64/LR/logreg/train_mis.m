function [w,run] = train_mis(x,w,lambda)
% Modified iterative scaling
% x is premultiplied by y

% Written by Thomas P Minka

if nargin < 3
  lambda = 0;
end
if lambda > 0
  error('must have lambda = 0')
end
[d,n] = size(x);
flops(0);
step = 1/max(sum(abs(x),1));

i1 = (x > 0);
x1 = abs(x).*i1;
x2 = abs(x).*(1-i1);
flops(flops + 3*d*n);
if nargout > 1
  run.w = [];
  run.flops = [];
  run.e = [];
end
for iter = 1:10000
  old_w = w;
  % s1 = 1-sigma
  s1 = 1./(1+exp(w'*x));
  delta = (x1*s1')./(x2*s1');
  w = w + step*0.5*log(delta);
  if iter == 1
    % same for every iteration
    % use spmul because x1,x2 have structural zeros
    fl = flops_mul(w',x)+n*(flops_exp+2) + ...
	flops_spmul(x1,s1')+flops_spmul(x2,s1')+d + ...
	d*(flops_exp+2);
  end
  flops(flops + fl);
  
  if nargout > 1 & rem(iter,100) == 1
    run.w(:,end+1) = w;
    run.flops(end+1) = flops;
    run.e(end+1) = logProb(x,w) -0.5*lambda*w'*w;
  end
  if rem(iter,1000) == 0
    fprintf('MIS iter %d\n', iter)
  end
  
  if max(abs(w - old_w)) < 1e-6
    break
  end
end
if iter == 10000
  warning('not enough iters')
end
if nargout > 1
  figure(2)
  plot(run.e)
end
