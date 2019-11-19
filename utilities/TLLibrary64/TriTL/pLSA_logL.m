% logL = pLSA_logL(X,Pw_z,Pz_d,Pd,Pw_d)  
%  computes the log-likelihood of the data given the parameters
function logL = pLSA_logL(X,Pw_z,Pz_d,Pd,Pw_d)

if nargin < 5
  Pw_d = mex_Pw_d(X,Pw_z,Pz_d);
end

logL = mex_logL(X,Pw_d,Pd);

%equiv with 
%Nwords = size(Pw_z,1);
%Pw_dPd = Pw_d .* repmat(Pd,Nwords,1);
%logL = sum(sum(X .* log(Pw_dPd)));

return;
