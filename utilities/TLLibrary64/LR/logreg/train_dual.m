function [w,run] = train_dual(x,w,lambda,priority,mod)

% Written by Thomas P Minka

flops(0);
% kernel matrix
c = x'*x;
dc = diag(c);
v = 1/lambda;
% for flop counting, multiplication by lambda is free

[d,n] = size(x);
% this assumes w = 0
alpha = repmat(1e-4,n,1);
% Keerthi-type initialization
alpha = repmat(1/n,n,1);
if nargin < 4
  priority = 1;
end
if nargin < 5
  mod = 0;
end

count = 1;
for iter = 1:2000
  old_alpha = alpha;
  % annealing for expt2
  %v = v + 1e2
  if ~priority 
    if mod
      for i = 1:n
	theta = log(alpha(i)./(1-alpha(i)));
	g = v*(c(i,:)*alpha) + theta;
	a = alpha(i)*(1-alpha(i));
	h = v*dc(i) + 1/a;
	%h = h*a*a;
	%h = h*a + g*(1-2*alpha(i));
	if 1
	  a = alpha(i);
	  c2 = ((1+log(a))*a*h-g)/((1+log(a))*a/(1-a) + 1+log(1-a));
	  c1 = a*(h - c2/(1-a));
	  as = linspace(eps,1-eps,100);
	  f = [];
	  f2 = [];
	  f0 = 0.5*v*(alpha'*c*alpha) + ...
	      sum(alpha.*log(alpha)) + sum((1-alpha).*log(1-alpha));
	  for k = 1:length(as)
	    alpha(i) = as(k);
	    f(k) = 0.5*v*(alpha'*c*alpha) + ...
		sum(alpha.*log(alpha)) + sum((1-alpha).*log(1-alpha));
	    f2(k) = c1*as(k)*log(as(k))+c2*(1-as(k))*log(1-as(k));
	    f2(k) = f2(k) - (c1*a*log(a)+c2*(1-a)*log(1-a)) + f0;
	  end
	  if 0
	    plot(as,f,as,f2)
	    drawnow
	    ax = axis;
	    line([a a],[ax(3) ax(4)],'Color','r')
	    axis_pct
	    pause
	  end
	end
	theta = theta - g/h;
	alpha(i) = 1/(1+exp(-theta));
      end
      flops(flops + n*(6+2+flops_exp));
    else
      for i = 1:n
	g = v*(c(i,:)*alpha) + log(alpha(i)./(1-alpha(i)));
	h = v*dc(i) + 1/alpha(i)/(1-alpha(i));
	alpha(i) = alpha(i) - g./h;
	if alpha(i) < eps
	  alpha(i) = eps;
	elseif alpha(i) > 1-eps
	  alpha(i) = 1-eps;
	end
      end
    end
    flops(flops + n*(flops_mul(1,n,1)+3+flops_exp + 4 + 2));
  else
    % incremental algorithm
    if iter == 1
      g = v*(c*alpha) + log(alpha./(1-alpha));
      flops(flops + flops_mul(c,alpha)+n*(flops_exp+3));
    end
    for j = 1:n
      [dummy,i] = max(abs(g));
      %disp(['i=' num2str(i) ' g=' num2str(g(i))])
      %i = j;
      o_alpha = alpha(i);
      h = v*dc(i) + 1/alpha(i)/(1-alpha(i));
      if mod
	theta = log(alpha(i)./(1-alpha(i)));
	a = alpha(i)*(1-alpha(i));
	gt = g(i)*a;
	h = h*a*a + gt*(1-2*alpha(i));
	theta = theta - g/h;
	alpha(i) = 1/(1+exp(-theta));
      else
	alpha(i) = alpha(i) - g(i)./h;
      end
      if alpha(i) < eps
	alpha(i) = eps;
      elseif alpha(i) > 1-eps
	alpha(i) = 1-eps;
      end
      % update all g(i)
      da = alpha(i) - o_alpha;  % no cost
      dg = da*c(:,i)*v;
      dg(i) = dg(i) + log(alpha(i)/(1-alpha(i))) - ...
	  log(o_alpha/(1-o_alpha));
      % no cost for second log
      g = g + dg;
    end
    flops(flops + n*(2*n-1 + 4 + 2 + 2) + n*(n + flops_exp+4 + n));
  end

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
  
  if max(abs(alpha - old_alpha)) < 1e-8
    break
  end
end
if iter == 2000
  warning('not enough iters')
end
if nargout > 1
  figure(2)
  % e should go up, e2 go down
  plot(1:length(run.e), run.e, 1:length(e2), e2)
end
