function hD=ExtChResponse(chEst, idx_data, prmLTE)
% 这个函数的作用是当你得到全部的hD后，要把CSR等东西都去掉，只留下data的信道
%#codegen
numTx = prmLTE.numTx;
numRx = prmLTE.numRx;
% 取出，再放进去
if (numTx==1)
    hD=complex(zeros(numel(idx_data),numRx));
    for n=1:numRx
        tmp=chEst(:,:,n);
        hD(:,n)=tmp(idx_data);
    end
else
    hD=complex(zeros(numel(idx_data),numTx,numRx));
    for n=1:numRx
        for m=1:numTx
            tmp=chEst(:,:,m,n);
            hD(:,m,n)=tmp(idx_data);
        end
    end
end