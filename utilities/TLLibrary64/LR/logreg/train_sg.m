function [w,run] = train_sg(x,w)
% Stochastic gradient
% x is premultiplied by y

step = 1;
scale = 1.02;
[d,n] = size(x);

flops(0);
e = logProb(x,w);
for iter = 1:1000
  old_e = e;
  old_w = w;
  i = ceil(rand*n);
  g = x(:,i)/(1+exp(w'*x(:,i)));
  if 0
    w = w + scale*step*g;
    e = logProb(x,w);
    if(e < old_e)
      % try smaller step
      step = step/scale;
      w = old_w + step*g;
      e = logProb(x,w);
    else
      % larger step
      step = step*scale;
    end
  elseif 0
    u = g;
    % s1 = 1-sigma
    s1 = 1./(1+exp(w'*x));
    g = x*s1';

    % line search along u
    ug = u'*g;
    ux = u'*x;
    a = s1.*(1-s1);
    uhu = (ux.^2)*a';
    w = w + (ug/uhu)*u;
  else
    w = w + step/sqrt(iter)*g;
  end

  
  fl = flops;
  run.step(iter) = step;
  run.w(:,iter) = w;
  run.flops(iter) = fl;
  run.e(iter) = logProb(x,w);
  flops(fl);
  
  if max(abs(w - old_w)) < 1e-8
    %break
  end
end
figure(2)
plot(run.e)
if iter == 50
  %warning('not enough iters')
end
