function [out, Wn] = SpatialMuxPrecoder(in, prmLTEPDSCH, cbIdx)
% Precoder for PDSCH spatial multiplexing
%#codegen
% Assumes the incoming codewords are of the same length
v = prmLTEPDSCH.numLayers;              % Number of layers
numTx = prmLTEPDSCH.numTx;              % Number of Tx antennas
% Compute the precoding matrix 
Wn = PrecoderMatrix(cbIdx, numTx, v);
% Initialize the output
out = complex(zeros(size(in)));
inLen = size(in, 1);
% Apply the relevant precoding matrix to the symbol over all layers
for n = 1:inLen
    temp = Wn * (in(n, :).'); 
    out(n, :) = temp.';
end