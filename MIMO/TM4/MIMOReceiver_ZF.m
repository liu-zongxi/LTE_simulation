function y = MIMOReceiver_ZF(in, chEst, Wn)
%#codegen
% MIMO Receiver:
%   Based on received channel estimates, process the data elements
%   to equalize the MIMO channel. Uses the ZF detector.
% Get params
numData = size(in, 1);
y = complex(zeros(size(in)));
iWn = inv(Wn);
%% ZF receiver
for n = 1:numData
    h = squeeze(chEst(n, :, :)); % numTx x numRx
    h = h.';                     % numRx x numTx
    Q = inv(h);
    x = Q * in(n, :).';%#ok
    tmp = iWn * x; %#ok
    y(n, :) = tmp.';
end