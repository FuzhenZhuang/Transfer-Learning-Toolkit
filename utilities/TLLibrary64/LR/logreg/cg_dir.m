function dir = cg_dir(old_dir, grad, old_grad)
% Compute the new conjugate direction.

g = grad;
grad = grad(:);
old_grad = old_grad(:);

% Hestenes-Stiefel
delta = grad - old_grad;
beta = (grad'*delta) / (old_dir'*delta);
% Polak-Ribiere
%beta = -grad'*(grad - old_grad) / (old_grad'*old_grad);
% Fletcher-Reeves
%beta = -(grad'*grad) / (old_grad'*old_grad);

dir = g - beta*old_dir;

d = length(g);
flops(flops + d + 2*flops_mul(grad',delta)+1 + d+d);
