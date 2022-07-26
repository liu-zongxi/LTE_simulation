%------------------------解码率匹配-----------------------%
%-----------------------author:lzx-------------------------%
%-----------------------date:2022年7月1日17点53分-----------------%
function out = RateDematcher(in, Kplus)
% Undoes the Rate matching per coded block.
%#codegen
% 之前被打孔掉的比特用0填充即可，为什么？
% Parameters
colTcSb = 32;
D = Kplus+4;
rowTcSb = ceil(D/colTcSb);
Kpi = colTcSb * rowTcSb;
Nd = Kpi - D;

tmp=zeros(3*D,1);
tmp(1:numel(in))=in;

% no bit selection - assume full buffer passed in
i0=(1:D)';
Index= indexGenerator(i0,colTcSb, rowTcSb, Nd);
Index2= indexGenerator2(i0,colTcSb, rowTcSb, Nd);
Indexpre=[Index,Index2+D].';
Index12=Indexpre(:);

% Bit streams
tmp0=tmp(1:D);
tmp12=tmp(D+1:end);
v0 = subBlkDeInterl(tmp0, Index);
d12=subBlkDeInterl(tmp12, Index12);
v1=d12(1:D);
v2=d12(D+(1:D));

% Interleave 1, 2, 3 sub-blk streams - for turbo decoding
temp = [v0 v1 v2].';
out = temp(:);
end

function v = indexGenerator(d, colTcSb, rowTcSb, Nd)
% Sub-block interleaving - for d0 and d1 streams only

colPermPat = [0, 16, 8, 24, 4, 20, 12, 28, 2, 18, 10, 26, 6, 22, 14, 30,...
              1, 17, 9, 25, 5, 21, 13, 29, 3, 19, 11, 27, 7, 23, 15, 31];

% For 1 and 2nd streams only
y = [NaN*ones(Nd, 1); d];       % null (NaN) filling
inpMat = reshape(y, colTcSb, rowTcSb).';
permInpMat = inpMat(:, colPermPat+1);
v = permInpMat(:);

end

function v = indexGenerator2(d, colTcSb, rowTcSb, Nd)
% Sub-block interleaving - for d2 stream only

colPermPat = [0, 16, 8, 24, 4, 20, 12, 28, 2, 18, 10, 26, 6, 22, 14, 30,...
              1, 17, 9, 25, 5, 21, 13, 29, 3, 19, 11, 27, 7, 23, 15, 31];
pi = zeros(colTcSb*rowTcSb, 1);
for i = 1 : length(pi)
    pi(i) = colPermPat(floor((i-1)/rowTcSb)+1) + colTcSb*(mod(i-1, rowTcSb)) + 1;
end

% For 3rd stream only
y = [NaN*ones(Nd, 1); d];       % null (NaN) filling
inpMat = reshape(y, colTcSb, rowTcSb).';
ytemp = inpMat.';
y = ytemp(:);
v = y(pi);

end

function out=subBlkDeInterl(in,Index)
out=zeros(size(in));
IndexG=find(~isnan(Index)==1);
IndexOut=Index(IndexG);
out(IndexOut)=in;
end
