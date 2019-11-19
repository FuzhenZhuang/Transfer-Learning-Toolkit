function [w,run] = train_is(x,y,w,lambda)
% Iterative scaling

% Written by Thomas P Minka

if any(x(:) < 0)
  error('Iterative scaling must have x > 0')
  %x = x - min(x(:));
end

if nargin < 4
  lambda = 0;
end
[d,n] = size(x);
flops(0);
step = 1/max(sum(x,1));
i1 = (y > 0)';
% sum of all data
xs = row_sum(x);
% sum of data in class 1
x1 = x*i1;
% sum of data in class 2
x2 = x*(1-i1);
% ratio
r12 = x1./x2;
flops(flops + n + flops_row_sum(x));
if nargout > 1
  run.w = [];
  run.flops = [];
  run.e = [];
end
for iter = 1:10000
  old_w = w;
  s1 = 1./(1+exp(-(w'*x)))';
  xs1 = x*s1;
  %delta1 = x1./xs1;
  %w = w + step*log(delta1);
  %delta2 = (xs-xs1)./x2;
  %w = w + step*log(delta2);
  delta = xs./xs1 - 1;
  r12 = (x1 - lambda*w)./(x2 - lambda*w);
  w = w + step*log(r12.*delta);
  if iter == 1
    fl = flops_mul(w',x)+n*(flops_exp+2) + ...
	flops_mul(x,s1)+2*d + ...
	d*(1+flops_exp+2);
  end
  flops(flops + fl);

  if nargout > 1 & rem(iter,100) == 1
    run.w(:,end+1) = w;
    run.flops(end+1) = flops;
    run.e(end+1) = logProb(scale_cols(x,y),w) -0.5*lambda*w'*w;
  end
  if rem(iter,1000) == 0
    fprintf('IS iter %d\n', iter)
  end

  if max(abs(w - old_w)) < 1e-5
    break
  end
end
figure(2)
plot(run.e)
if iter == 10000
  warning('not enough iters')
end
