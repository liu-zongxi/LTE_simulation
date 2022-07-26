%------------------------Turbo解码-----------------------%
%-----------------------author:lzx-------------------------%
%-----------------------date:2022年6月27日10点55分-----------------%
function y=TurboDecoder(u, intrlvrIndices,  maxIter)
%#codegen
persistent Turbo
% if isempty(Turbo)
Turbo = comm.TurboDecoder('TrellisStructure', poly2trellis(4, [13 15], 13),...
     'InterleaverIndicesSource','Input port', ...
    'NumIterations', maxIter);
% end
y=step(Turbo, u,  intrlvrIndices);