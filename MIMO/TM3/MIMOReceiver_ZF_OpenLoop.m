function y = MIMOReceiver_ZF_OpenLoop(in, chEst, v)
%#codegen
% MIMO Receiver:
%   Based on received channel estimates, process the data elements
%   to equalize the MIMO channel. Uses the ZF detector.
% Get params
numData = size(in, 1);
y = complex(zeros(size(in)));
%% ZF receiver
for n = 1:numData
    [W, D, U] = PrecoderMatrixOpenLoop(n, v);
    % 预编码取逆
    % iWn = (W *D*U)';
    iWn = inv(W *D*U);
    % 取出当前时间对应的信道
    h = squeeze(chEst(n, :, :)); % numTx x numRx
    h = h.';                     % numRx x numTx
    % 取逆
    x = h \ (in(n, :).');
    tmp = iWn * x;
    y(n, :) = tmp.';
end