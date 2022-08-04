function hD=ExtChResponse(chEst, idx_data, prmLTE)
%#codegen
numRx = prmLTE.numRx;
hD=complex(zeros(numel(idx_data),numRx));
for n=1:numRx
    tmp=chEst(:,:,n);
    hD(:,n)=tmp(idx_data);
end