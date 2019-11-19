function p = logProb(x,w)
% x is premultiplied by y

s = w'*x;
p = -log(1 + exp(-s));
i = find(s > 36);
if ~isempty(i)
  % large s limit
  p(i) = -exp(-s(i));
end
p = sum(p);
