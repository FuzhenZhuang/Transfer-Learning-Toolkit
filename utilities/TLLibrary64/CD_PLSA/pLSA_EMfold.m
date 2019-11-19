% Pz_q = pLSA_EMfold(X,Pw_z,Pz_q,nIterations,beta);
%
% computes P(z|q) given 
%
% X		Term x Documents (test) matrix
% Pw_z		P(w|z) conditional word probabilities
% Pz_q		P(z|q) or [] to init
% nIterations	# iterations to fold in the query 'X'
% beta		if tempered EM was used, provide the correct beta
%
% Peter Gehler (pgehler@tuebingen.mpg.de) 

function Pz_q = pLSA_EMfold(X,Pw_z,Pz_q,nIterations,beta);

if nargin < 5
  beta = 1;
end

% initialize Pz_q if not given
if ~numel(Pz_q)
  K = size(Pw_z,2);
  Pz_q = rand(K,size(X,2));
  Pz_q = Pz_q ./ repmat(sum(Pz_q),K,1);
end


% fold in keeping Pw_z fixed
for i=1:nIterations
  [dummy,Pz_q] = pLSA_EMstep(X,Pw_z,Pz_q,beta);
end


return;
