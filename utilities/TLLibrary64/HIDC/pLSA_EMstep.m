% [Pw_z,Pz_d] = pLSA_EMstep(X,Pw_z,Pz_d,beta,Pw_d);
%
% computes one step of EM and updates P(w|z) and P(z|d) where
%
% X		Term x document matrix
% Pw_z		conditional word probabilities
% Pz_d 		topic activation of documents
% beta		(optional) temperature needed for TEM
% Pw_d		(optional) needed to compute the normalization 
%
% Peter Gehler (pgehler@tuebingen.mpg.de) 
function [Pw_z,Pz_d] = pLSA_EMstep(X,Pw_z,Pz_d,beta,Pw_d);

[Ntopics,Ndocs] = size(Pz_d);
Nwords = size(Pw_z,1);

if nargin < 4 
  beta = 1;
end

if nargin < 5
  Pw_d = mex_Pw_d(X,Pw_z,Pz_d,beta);

  %equiv with:
  %Pw_d = zeros(Nwords,Ndocs);
  %for i=1:Ntopics
  % Pw_d = Pw_d + Pw_z(:,i) * Pz_d(i,:);
  %end
end

[Pw_z,Pz_d] = mex_EMstep(X,Pw_d,Pw_z,Pz_d,beta);

% equiv with iterative 
%for i=1:Ntopics
  %[XPz_dw,sumXPz_dw] = mex_EMstep_old(X,Pw_d,Pw_z(:,i),Pz_d(i,:),beta);
  %equiv with 
%  Pz_dw = Pw_z(:,i) * Pz_d(i,:) ./ Pw_d;
%  XPz_dw = X .* Pz_dw;
%  Pw_z(:,i) = row_sum(XPz_dw) ./ sumXPz_dw;
%  Pz_d(i,:) = col_sum(XPz_dw) ./ sum(X);
%end

return;
