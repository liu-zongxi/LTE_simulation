function y= RateMatcherTB(in, Kplus, N)
% Rate matching per coded block, with and without the bit selection.
D = Kplus+4;
if numel(in)~=3*D, error('Kplus (2nd argument) times 3 must be size of input 1.');end 

% Parameters
colTcSb = 32;
rowTcSb = ceil(D/colTcSb);
Kpi = colTcSb * rowTcSb;
Nd = Kpi - D;

% Bit streams
d0 = in(1:3:end); % systematic
d1 = in(2:3:end); % parity 1st
d2 = in(3:3:end); % parity 2nd

i0=(1:D)';
Index=indexGenerator(i0,colTcSb, rowTcSb, Nd);
Index2=indexGenerator2(i0,colTcSb, rowTcSb, Nd);

% Sub-block interleaving - per stream
v0 = subBlkInterl(d0,Index);
v1 = subBlkInterl(d1,Index);
v2 = subBlkInterl(d2,Index2);
vpre=[v1,v2].';
v12=vpre(:);

%   Concat 0, interleave 1, 2 sub-blk streams
% Bit collection
wk = zeros(numel(in), 1);
wk(1:D) = v0(~isnan( v0 ));
wk(D+1:end) = v12(~isnan( v12 ));

% Apply rate matching
y=wk(1:N);

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

function out=subBlkInterl(d0,Index)
out=zeros(size(Index));
IndexG=~isnan(Index);
IndexB=isnan(Index);
MyIndex=Index(IndexG);
out(IndexG)=d0(MyIndex);
Nd=sum(IndexB);
out(IndexB)=nan(Nd,1);
end
