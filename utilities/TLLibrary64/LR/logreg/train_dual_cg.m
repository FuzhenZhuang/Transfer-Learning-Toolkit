function [w,run] = train_kernel_cg(x,w,v)

% Written by Thomas P Minka

flops(0);
% kernel matrix
c = x'*x;
dc = diag(c);
% for flop counting, multiplication by v is free

[d,n] = size(x);
% this assumes w = 0
alpha = repmat(1e-4,n,1);
% Keerthi-type initialization
alpha = repmat(1/n,n,1);

count = 1;
old_g = zeros(size(w));
for iter = 1:1000
  old_alpha = alpha;
  % annealing for expt2
  %v = v + 1e2
  g = v*(c*alpha) + log(alpha./(1-alpha));
  % project gradient onto constraints
  cons = [find(alpha <= eps & g > 0) find(alpha >= 1-eps & g < 0)]
  %cons = [find(alpha <= eps & g < 0) find(alpha >= 1-eps & g > 0)]
  %cons =  find(alpha <= eps | alpha >= 1-eps);
  g(cons) = 0;
  flops(flops + flops_mul(c,alpha) + n*(flops_exp+3));
  if iter == 1
    u = g;
  else
    u = cg_dir(u, g, old_g);
  end
  %u = g;
  % project direction onto constraints
  %cons = [find(alpha <= eps & u < 0) find(alpha >= 1-eps & u > 0)];
  u(cons) = 0;
  
  % line search along u
  ug = u'*g;
  uhu = v*(u'*c*u) + sum(u.^2 ./alpha./(1-alpha));
  % step_max is maximum step that keeps alpha in bounds
  ip = find(u > 0);
  in = find(u < 0);
  step_max = min([alpha(ip)./u(ip); (alpha(in) - 1)./u(in)]);
  step_min = max([alpha(in)./u(in); (alpha(ip) - 1)./u(ip)]);
  step = ug/uhu;
  if abs(step) < 1e-15
    keyboard
  end
  if step > step_max
    step
    step = step_max
  elseif step < step_min
    step = step_min
  end
  if isnan(step)
    error('step is nan')
  end
  alpha = alpha - step*u;
  old_g = g;

  i = find(alpha < eps);
  alpha(i) = eps;
  i = find(alpha > 1-eps);
  alpha(i) = 1-eps;

  flops(flops + flops_mul(u',g) + flops_mul(u',c)+flops_mul(1,n,1)+5*n + ...
      2*n+2 + 2*n);
  
  % computations here don't count
  w = v*x*alpha;
  run.w(:,count) = w;
  run.flops(count) = flops;
  run.e(count) = logProb(x,w) -0.5/v*w'*w;
  e2(count) = 0.5/v*w'*w + sum(alpha.*log(alpha)) + sum((1-alpha).*log(1-alpha));
  count = count + 1;
  if rem(count,200) == 0
    fprintf('Kernel count %d\n', count)
  end
  
  %max(abs(alpha - old_alpha))
  if max(abs(alpha - old_alpha)) < 1e-8
    break
  end
end
figure(2)
% e should go up, e2 go down
plot(1:length(run.e), run.e, 1:length(e2), e2)
if iter == 2000
  warning('not enough iters')
end
  
