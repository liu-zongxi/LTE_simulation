function hD=gridResponse_averageSubframe(hp, Ndl_symb, Edges)
% Average over the two same Freq subcarriers, and then interpolate between
% them - get all estimates and then repeat over all columns (symbols).
% The interpolation assmues NCellID = 0.
% Time average two pilots over the slots, then interpolate (F)
% between the 4 averaged values, repeat for all symbols in sframe
Separation=3;
N=numel(Edges);
Edge=[0 2];
% Compute channel response over all resource elements of OFDM symbols
switch N
    % 特殊情况
    case 2
        % 这里是直接把整个子帧交织起来了，非常巧妙，利用了matlab的特性
        h1_a_mat = hp.';
        h1_a = h1_a_mat(:);
        % Interpolate between subcarriers
        % 频域插值
        y = InterpolateCsr(h1_a,  Separation, Edge);
        % Repeat between OFDM symbols
        % 复制
        hD=y(:,ones(1,Ndl_symb*2));
    % 正常情况
    case 4
        % 一样的道理，先平均再交织起来，也是在整个子帧上
        h1_a1 = mean([hp(:, 1), hp(:, 3)],2);
        h1_a2 = mean([hp(:, 2), hp(:, 4)],2);
        h1_a_mat = [h1_a1 h1_a2].';
        h1_a = h1_a_mat(:);
        % Interpolate between subcarriers
        y = InterpolateCsr(h1_a,  Separation, Edge);
        % Repeat between OFDM symbols
        % 复制
        hD=y(:,ones(1,Ndl_symb*2));
    otherwise
        error('Wrong Edges parameter for function gridResponse.');
end