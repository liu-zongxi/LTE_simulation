function y = MIMOReceiver_MMSE_OpenLoop(in, chEst, nVar, v)
%#codegen
% MIMO Receiver:
%   Based on received channel estimates, process the data elements
%   to equalize the MIMO channel. Uses the MMSE detector.
% noisFac = numLayers*diag(nVar);
noisFac = diag(nVar);
numData = size(in, 1);
y = complex(zeros(size(in)));
%% MMSE receiver
for n = 1:numData
    [W, D, U] = PrecoderMatrixOpenLoop(n, v);
    % iWn = (W *D*U)';             % Orthonormal matrix,W并不一定是酉矩阵吗这是不对的
    iWn = inv(W *D*U);
    h = chEst(n, :, :);               % numTx x numRx
    % 哪有这样的，层不一定等于天线数！
    h = reshape(h(:), v, v).';    % numRx x numTx
    Q = (h'*h + noisFac)\h';
    x = Q * in(n, :).';
    tmp = iWn * x;
    y(n, :) = tmp.';
end