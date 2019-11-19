function v = orthA(v,a)
% orthogonalize a set of vectors wrt metric a

av = [];
z = [];
for i = 2:cols(v)
  av = [av a*v(:,i-1)];
  z = [z v(:,i-1)'*av(:,i-1)];
  prev = v(:,1:(i-1));
  beta = (v(:,i)'*av)./z;
  v(:,i) = v(:,i) - prev*beta';
end
