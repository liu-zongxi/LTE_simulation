%------------------------发送TB时的预操作-----------------------%
%-----------------------author:lzx-------------------------%
%-----------------------date:2022年7月2日23点26分-----------------%
function [out, Kplus, C] = TbChannelCoding(in, prmLTE)
% Transport block channel coding
%#codegen
%% Initializations
inLen = size(in, 1);
% 输入要去掉CRC
[C, Kplus] =  CblkSegParams(inLen-24);
intrlvrIndices = lteIntrlvrIndices(Kplus);
CodingRate=prmLTE.Rate;
Qm=2*prmLTE.Mode;
NumLayers=1;
G=ceil((Kplus+4)/CodingRate);
% E理应和Kplus一样，但实际上还要考虑码率匹配的问题
E_CB=CbBitSelection(C, G, NumLayers, Qm);
% Initialize output
out = false(G, 1);
%%  Processing: Channel coding the TB
if (C==1) % single CB, no CB CRC used
    % Turbo encode
    tEncCbData = TurboEncoder( in, intrlvrIndices);
    % Rate matching, with bit selection
    rmCbData =  RateMatcherTB(tEncCbData, Kplus,  G);
    % unify code paths
    out = logical(rmCbData);
else % multiple CBs in TB
    startIdx = 0;
    for cbIdx = 1:C
        % Code-block segmentation
        cbData = in((1:(Kplus-24)) + (cbIdx-1)*(Kplus-24));
        % Append checksum to each CB
        % 码块分割后每一块都要添加CRC
        crcCbData = CbCRCGenerator( cbData);
        % Turbo encode each CB
        tEncCbData = TurboEncoder(crcCbData, intrlvrIndices);
        % Rate matching with bit selection
        E=E_CB(cbIdx);
        % 分块后真正的码率
        rmCbData = RateMatcherTB(tEncCbData, Kplus,  E);
        % Code-block concatenation
        out((1:E) + startIdx) = logical(rmCbData);
        startIdx = startIdx + E;
    end
end