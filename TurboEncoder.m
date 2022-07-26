%------------------------Gold扰码-----------------------%
%-----------------------author:lzx-------------------------%
%-----------------------date:2022年6月26日15点50分-----------------%
function y=TurboEncoder(u, intrlvrIndices)
%#codegen
% 输入
% u:输入的比特
% intrlvrIndices:生成的交织器序列
persistent Turbo
if isempty(Turbo)
    Turbo = comm.TurboEncoder('TrellisStructure', poly2trellis(4, [13 15], 13), ...
        'InterleaverIndicesSource','Input port');
end
y=step(Turbo, u, intrlvrIndices);