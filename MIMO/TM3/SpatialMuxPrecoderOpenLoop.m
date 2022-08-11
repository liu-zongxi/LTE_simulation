function out = SpatialMuxPrecoderOpenLoop(in, prmLTEPDSCH)
% Precoder for PDSCH spatial multiplexing
%#codegen
% Assumes the incoming codewords are of the same length
v = prmLTEPDSCH.numLayers;              % Number of layers
% Initialize the output
out = complex(zeros(size(in)));
inLen = size(in, 1);
% Apply the relevant precoding matrix to the symbol over all layers
for n = 1:inLen
    % Compute the precoding matrix
    % 获得 W D U
    [W, D, U] = PrecoderMatrixOpenLoop(n, v);
    T=W *D*U;
    % 预编码
    temp = T* (in(n, :).');
    out(n, :) = temp.';
end