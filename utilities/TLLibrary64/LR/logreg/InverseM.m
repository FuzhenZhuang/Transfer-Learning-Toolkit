%solve the inverse of matrix M,and MOut is the outcome Matrix.
function [MOut] = InverseM(M)
[nRow,nCol] = size(M);
is = zeros(nRow,1);
js = zeros(nRow,1);
fDet = 1.0;
f = 1;
for k = 1:nRow
    fMax = 0;
    for i = k:nRow
        for j = k:nRow
            f1 = abs(M(i,j));
            if f1 > fMax
                fMax = f1;
                is(k,1) = i;
                js(k,1) = j;
            end
        end
    end
    if abs(fMax) < 0.0001
        disp('Error happen 0.0001');
    end
    if is(k,1) ~= k
        f = -f;
        for i = 1:nRow
            [M(k,i),M(is(k,1),i)] = swap(M(k,i),M(is(k,1),i));
        end
    end
    if js(k,1) ~= k
        f = -f;
        for i = 1:nRow
            [M(i,k),M(i,js(k,1))] = swap(M(i,k),M(i,js(k,1)));
        end
    end
    fDet = fDet*M(k,k);
    M(k,k) = 1/M(k,k);
    for j = 1:nRow
        if j ~= k
            M(k,j) = M(k,j)*M(k,k);
        end
    end
    for i = 1:nRow
        if i ~= k
            for j = 1:nRow
                if j ~= k
                    M(i,j) = M(i,j) - M(i,k)*M(k,j);
                end
            end
        end
    end
    for i = 1:nRow
        if i ~= k
            M(i,k) = M(i,k)*(-M(k,k)); 
        end
    end    
end
for k = nRow:-1:1
    if js(k,1) ~= k
        for i = 1:nRow
            [M(k,i),M(js(k,1),i)] = swap(M(k,i),M(js(k,1),i));
        end
    end
    if is(k,1) ~= k
        for i = 1:nRow
            [M(i,k),M(i,is(k,1))] = swap(M(i,k),M(i,is(k,1)));
        end
    end
end
MOut = M;
clear M;
