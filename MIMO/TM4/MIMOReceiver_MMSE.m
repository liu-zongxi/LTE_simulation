function y = MIMOReceiver_MMSE(in, chEst, nVar, Wn)
%#codegen
% MIMO Receiver:
%   Based on received channel estimates, process the data elements
%   to equalize the MIMO channel. Uses the MMSE detector.
% Get params
numLayers = size(Wn,1);
noisFac = numLayers*diag(nVar);
% noisFac = diag(nVar);
numData = size(in, 1);
y = complex(zeros(size(in)));
iWn = inv(Wn);
%% MMSE receiver
for n = 1:numData
    h = chEst(n, :, :);                         % numTx x numRx
    h = reshape(h(:), numLayers, numLayers).';  % numRx x numTx
    Q = (h'*h + noisFac)\h';
    x = Q * in(n, :).';
    tmp = iWn * x; %#ok
    y(n, :) = tmp.';
end