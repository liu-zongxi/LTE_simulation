function out = lteCbRateMatching(in, Kplus, varargin)
% Rate matching per coded block, with and without the bit selection.
%   As per TS 36.212 v10.0.0, Section 5.1.4.1.

% Copyright 2011-2012 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2012/12/15 20:25:34 $

%#codegen

% Parameters
colTcSb = 32;
D = Kplus+4;
rowTcSb = ceil(D/colTcSb);
Kpi = colTcSb * rowTcSb; 
Nd = Kpi - D;

% Bit streams
d0 = in(1:3:end); % systematic
d1 = in(2:3:end); % parity 1st
d2 = in(3:3:end); % parity 2nd

% Sub-block interleaving - per stream
v0 = subBlkInterl(d0, colTcSb, rowTcSb, Nd);
v1 = subBlkInterl(d1, colTcSb, rowTcSb, Nd);
v2 = subBlkInterl2(d2, colTcSb, rowTcSb, Nd);

% Bit collection
Kw = 3*Kpi;
wk = zeros(Kw, 1);

%   Concat 0, interleave 1, 2 sub-blk streams
wk(1:Kpi) = v0;
temp = [v1 v2].';
wk(Kpi+1:end) = temp(:);

if (nargin==2)
    % No bit selection - output the whole buffer
    % Bit pruning and transmission (minus the null bits)
    out = zeros(length(in), 1);
    k = 1; j = 1;
    while (k <= length(out))
        w = wk(j);
        if ~isnan(w)
            out(k) = w;
            k = k+1;
        end
        j = j+1;
    end    
else
    % With bit selection
    C = varargin{1};
    E = varargin{2};
    % 涉及到初始值和HARQ，目前不清楚
    % Bit Selection Parameters
    Nsoft = 3667200;  % Category 5, off Table 4.1-1, TS 36.306, v10.0.0
    Kmimo = 2;        % for Tx mode 4
    Mdlharq = 8;      % FDD, off Table 7-1, TS 36.213
    Nir = floor(Nsoft/(Kmimo*min(Mdlharq, 8)));

    rvidx = 0;        % assume a value, no HARQ support yet
    Ncb = min(floor(Nir/C), Kw);
    k0 = rowTcSb*(2*ceil(Ncb/(8*rowTcSb))*rvidx + 2);

    % Bit pruning and transmission (minus the null bits)
    out = zeros(E, 1);
    k = 1; j = 0;
    while (k <= E)
        w = wk(mod(k0+j, Ncb)+1);
        if ~isnan(w)
            out(k) = w;
            k = k+1;
        end
        j = j+1;
    end

end

end
%-------------------------------------------------------------------------
function v = subBlkInterl(d, colTcSb, rowTcSb, Nd)
% Sub-block interleaving - for d0 and d1 streams only

colPermPat = [0, 16, 8, 24, 4, 20, 12, 28, 2, 18, 10, 26, 6, 22, 14, 30,...
              1, 17, 9, 25, 5, 21, 13, 29, 3, 19, 11, 27, 7, 23, 15, 31];

% For 1 and 2nd streams only
y = [NaN*ones(Nd, 1); d];       % null (NaN) filling
inpMat = reshape(y, colTcSb, rowTcSb).';
permInpMat = inpMat(:, colPermPat+1);
v = permInpMat(:);

end
%-------------------------------------------------------------------------
function v = subBlkInterl2(d, colTcSb, rowTcSb, Nd)
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
