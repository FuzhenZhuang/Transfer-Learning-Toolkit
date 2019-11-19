function [w,run] = train_cg2(x,w)
% Conjugate gradient method
% Data is columns of x, each column already scaled by the output y (+1 or -1).
% w is the starting guess for the parameters (a column).

% Written by Thomas P Minka

flops(0);
old_g = zeros(size(w));
old_u = [];
for iter = 1:1000
  old_w = w;
  % s1 = 1-sigma
  s1 = 1./(1+exp(w'*x));
  g = x*s1';
  a = s1.*(1-s1);
  if iter == 1
    u = g;
  else
    h = x*diag(a)*x';
    u = orthA([old_u g],h);
    u = u(:,cols(u));
  end
  
  % line search along u
  ug = u'*g;
  ux = u'*x;
  uhu = (ux.^2)*a';
  w = w + (ug/uhu)*u;
  old_g = g;

  % update memory
  old_u = [old_u u];
  if(cols(old_u) > 1) 
    old_u(:,1) = [];
  end
  
  fl = flops;
  run.w(:,iter) = w;
  run.flops(iter) = fl;
  run.e(iter) = logProb(x,w);
  flops(fl);

  if max(abs(w - old_w)) < 1e-5
    break
  end
end
figure(2)
plot(run.e)
if iter == 1000
  warning('not enough iters')
end
