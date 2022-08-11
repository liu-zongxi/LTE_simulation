function p2 = prmsDLSCH(cRate,maxIter, fullDecode, p)
% 13 15 是转换为二进制后反馈多项式的表达式，约束长度为4，反馈迭代次数为13
p2.trellis = poly2trellis(4, [13 15], 13);
if (cRate >= 1) || (cRate <= 0)
    error('Wrong coding rate');
end
p2.cRate = cRate;
modType = 0.5*p.Qm;
% 这里长度就是3，因为有三种不同长度的子帧05和普通的
TBLenVec = zeros(1, length(p.numPDSCHBits)); 
C = zeros(1, length(TBLenVec));  Kplus = zeros(1, length(C));
for i = 1:length(TBLenVec)
    TBLenVec(i) = getTBsizeRMC(modType, p2.cRate, p.Nrb, ...
                             p.numLayPerCW, p.numPDSCHBits(i));
    [C(i), ~, Kplus(i)] = lteCblkSegParams(TBLenVec(i));
end
p2.TBLenVec = TBLenVec;
p2.maxTBLen = max(p2.TBLenVec);
p2.maxC = max(C);
p2.minC = min(C);
p2.maxKplus = max(Kplus);
p2.maxIter = maxIter;
p2.fullDecode = fullDecode;