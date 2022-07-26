function y=TurboDecoderTB(u, intrlvrIndices, prmLTE)
%#codegen
maxIter=prmLTE.maxIter;
%#codegen
persistent Turbo
if isempty(Turbo)
    Turbo = comm.TurboDecoder('TrellisStructure', poly2trellis(4, [13 15], 13),...
         'InterleaverIndicesSource','Input port', ...
        'NumIterations', maxIter);
end
y=step(Turbo, u,  intrlvrIndices);