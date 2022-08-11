function out = lteCbRateDematching(in, Kplus, varargin)
% Undoes the Rate matching per coded block.
%   As per TS 36.212 v10.0.0, Section 5.1.4.1.

% Copyright 2011-2012 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2012/12/15 20:25:32 $

%#codegen

% Parameters
colTcSb = 32;
D = Kplus+4;
rowTcSb = ceil(D/colTcSb);
Kpi = colTcSb * rowTcSb;
Nd = Kpi - D;

if (nargin==2)
    % no bit selection - assume full buffer passed in
    % Bit streams
    d0 = in(1:D);       % systematic
    d1 = in(D+1:2:end); % parity 1st
    d2 = in(D+2:2:end); % parity 2nd
else
    % Account for bit selection and puncturing
    C = varargin{1};
    E = varargin{2};
    Nsoft = 3667200;  % Category 5, off Table 4.1-1, TS 36.306, v10.0.0
    Kmimo = 2;        % for Tx mode 4
    Mdlharq = 8;      % FDD, off Table 7-1, TS 36.213
    Nir = floor(Nsoft/(Kmimo*min(Mdlharq, 8)));
    
    Kw = 3*Kpi;
    wk = zeros(Kw, 1);
    rvidx = 0;                  % assume a value, no HARQ support yet
    Ncb = min(floor(Nir/C), Kw);
    k0 = rowTcSb*(2*ceil(Ncb/(8*rowTcSb))*rvidx + 2); % Offset

    % Recreate buffer at RX
    %   Sub-block interleaving - per stream - for NAN location in buffer
    v0 = subBlkInterl(zeros(D,1), colTcSb, rowTcSb, Nd);
    v1 = subBlkInterl(zeros(D,1), colTcSb, rowTcSb, Nd);
    v2 = subBlkInterl2(zeros(D,1), colTcSb, rowTcSb, Nd);

    %   Concat 0, interleave 1, 2 sub-blk streams
    wk(1:Kpi) = v0;
    temp = [v1 v2].';
    wk(Kpi+1:end) = temp(:); % has the NANs at the right locations

    %   Fill incoming data at the right location accounting for offset (k0)
    %   and NaNs in wk (using a circular buffer). 
    %   Trailing punctures are already zero'ed in the buffer.
    k = 1; j = 0;
    while (k <= E)  % "in" is of length E
        w = wk(mod(k0+j, Ncb)+1);
        if ~isnan(w)
            wk(mod(k0+j, Ncb)+1) = in(k);
            k = k+1;
        end
        j = j+1;
    end

    %   Then, read wk out completely minus the NaN as tempIn.
    tempIn = zeros(3*D, 1);
    k = 1; j = 1;
    while (k <= length(tempIn))
        w = wk(j);
        if ~isnan(w)
            tempIn(k) = w;
            k = k+1;
        end
        j = j+1;
    end

    % Bit streams - read off tempIn full buffer instead of input, in.
    d0 = tempIn(1:D);       % systematic
    d1 = tempIn(D+1:2:end); % parity 1st
    d2 = tempIn(D+2:2:end); % parity 2nd
    
end

% Sub-block deinterleaving - per stream
v0 = subBlkDeinterl(d0, colTcSb, rowTcSb, Nd);
v1 = subBlkDeinterl(d1, colTcSb, rowTcSb, Nd);
v2 = subBlkDeinterl2(d2, colTcSb, rowTcSb, Nd);

% Interleave 1, 2, 3 sub-blk streams - for turbo decoding
temp = [v0 v1 v2].';
out = temp(:);
    
end
%-------------------------------------------------------------------------
function out = subBlkDeinterl(in, colTcSb, rowTcSb, Nd)
% Sub-block deinterleaving - for d0 and d1 streams only

% Column permutation pattern
colPermPat = [0, 16, 8, 24, 4, 20, 12, 28, 2, 18, 10, 26, 6, 22, 14, ...
              30, 1, 17, 9, 25, 5, 21, 13, 29, 3, 19, 11, 27, 7, 23, 15, 31];

% Find the NAN locations in the input (at the TX) 
%   => recreate the interleaving
%   add the NaN's to input, do the deinterleaving, remove the NaN
ones    = zeros(rowTcSb, colTcSb);
ones(1, 1:Nd) = NaN;
onesPerm = ones(: , colPermPat+1);
intrOut = onesPerm(:);

% intrOut(find(~isnan(intrOut))) = in;
k = 1; j = 1;
while (j <= length(intrOut))
    if ~isnan(intrOut(j))
        intrOut(j) = in(k);
        k = k+1;
    end
    j = j+1;
end

% For 1 and 2nd streams only - deinterleave
inpMat = reshape(intrOut, rowTcSb, colTcSb); 
permInpMat = inpMat(:, colPermPat+1);
temp = permInpMat.';
temp = temp(:);

%   Exclude the null bits
out = temp(Nd+1:end);

end
%-------------------------------------------------------------------------
function out = subBlkDeinterl2(in, colTcSb, rowTcSb, Nd)
% Sub-block interleaving - for d2 stream only

colPermPat = [0, 16, 8, 24, 4, 20, 12, 28, 2, 18, 10, 26, 6, 22, 14, ...
              30, 1, 17, 9, 25, 5, 21, 13, 29, 3, 19, 11, 27, 7, 23, 15, 31];
pi = zeros(colTcSb*rowTcSb, 1);
for i = 1 : length(pi)
    pi(i) = colPermPat(floor((i-1)/rowTcSb)+1) + colTcSb*(mod(i-1, rowTcSb)) + 1;
end

% Find the NAN locations in the input (at the TX) 
%   => recreate the interleaving
%   add the NaN's to input, do the deinterleaving, remove the NaN
ones  = zeros(rowTcSb, colTcSb);
ones(1, 1:Nd) = NaN;
onesT = ones.';
onesCol = onesT(:);
intrOut = onesCol(pi);

% intrOut(find(~isnan(intrOut))) = in;
k = 1; j = 1;
while (j <= length(intrOut))
    if ~isnan(intrOut(j))
        intrOut(j) = in(k);
        k = k+1;
    end
    j = j+1;
end

% Deinterleave - for 3rd stream only 
outT = zeros(rowTcSb*colTcSb,1);
outT(pi) = intrOut;
out = outT(Nd+1:end);

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
