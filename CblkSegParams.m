%------------------------码块分割-----------------------%
%-----------------------author:lzx-------------------------%
%-----------------------date:2022年7月2日20点35分-----------------%
function  [C, Kplus] = CblkSegParams(tbLen)
%#codegen
%% Code block segmentation
% C: 被分为了多少个码块
% KPlus: 被分割完的会有两个长度，一个是K-一个是K+，详情看我博客
blkSize = tbLen + 24;
maxCBlkLen = 6144;
% 无需分块
if (blkSize <= maxCBlkLen)
    C = 1;          % number of code blocks
    b = blkSize;    % total bits
% 计算C
else
    L = 24;
    C = ceil(blkSize/(maxCBlkLen-L));
    b = blkSize + C*L; 
end

% Values of K from table 5.1.3-3
validK = [40:8:512 528:16:1024 1056:32:2048 2112:64:6144].';
% 找到Kplus
% First segment size
temp = find(validK >= b/C);
Kplus = validK(temp(1), 1);     % minimum K