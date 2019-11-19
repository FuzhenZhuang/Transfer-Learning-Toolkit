function y = scale_cols(x, s)
% SCALE_COLS       Scale each column of a matrix.
% SCALE_COLS(x,s) returns matrix y, same size as x, such that
% y(:,i) = x(:,i)*s(i)
% It is more efficient than x*diag(s).

%y = x.*repmat(s(:)', rows(x), 1);

for i = 1:size(x,2)
    y(:,i) = x(:,i)*s(1,i);
end

%y = x.*(ones(rows(x),1)*s(:)');
