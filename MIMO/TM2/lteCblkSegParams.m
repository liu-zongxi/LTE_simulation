function  [C, Cplus, Kplus, Cminus, Kminus, F] = lteCblkSegParams(tbLen)
% Provides the code block segmentation parameters for a given transport
% block length.
%   As per TS 36.212 v10.0.0, Section 5.1.2.

% Copyright 2011-2012 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2012/12/15 20:25:37 $

%#codegen
%% Code block segmentation
% 这个函数更为标准，和我博客的说法更为统一了
% 首先找到C，即分为多少块
% 其次是b，即总长度是多少
blkSize = tbLen + 24;
maxCBlkLen = 6144;

if (blkSize <= maxCBlkLen)
    C = 1;          % number of code blocks
    b = blkSize;    % total bits
else
    L = 24;
    C = ceil(blkSize/(maxCBlkLen-L));
    b = blkSize + C*L; 
end
% 找到C之后根据C找到最小的K+
% Values of K from table 5.1.3-3
validK = [40:8:512 528:16:1024 1056:32:2048 2112:64:6144].';

% First segment size
temp = find(validK >= b/C);
Kplus = validK(temp(1), 1);     % minimum K
% K+找到后找K-
% 然后找到长度为K-的个数C-
if (C==1)
    Cplus = 1; Cminus = 0; Kminus = 0;
else
    Kminus = validK(temp(1)-1); % Kminus < Kplus
    deltaK = Kplus-Kminus;
    Cminus = floor( (C*Kplus-b)/deltaK);
    Cplus = C - Cminus;
end
% 需要填充的数目
% Number of filler bits
F = Cplus*Kplus + Cminus*Kminus - b;
    
% [EOF]