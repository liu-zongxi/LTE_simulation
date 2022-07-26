function [y, flag, iters]=TurboDecoder_crc(u, intrlvrIndices)
%#codegen
maxIter=6;
persistent TurboCrc
if isempty(TurboCrc)
    TurboCrc = commLTETurboDecoder('InterleaverIndicesSource',  'Input port', ...
        'MaximumIterations', maxIter);
end
[y, flag, iters] = step(TurboCrc, u,  intrlvrIndices);