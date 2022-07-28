%------------------------发送TB时的预操作-----------------------%
%-----------------------author:lzx-------------------------%
%-----------------------date:2022年7月2日23点26分-----------------%
function [decTbData, crcCbFlags, iters] = TbChannelDecoding( in, Kplus, C, prmLTE)
% Transport block channel decoding.
%#codegen
% 生成交织器
intrlvrIndices = lteIntrlvrIndices(Kplus);
crcCbFlags=zeros(C,1);
iters=zeros(C,1);
% Make fixed size 
CodingRate=prmLTE.Rate;
Qm=2*prmLTE.Mode;
NumLayers=1;
% 算出总比特和分块后的每个块长度
G=ceil((Kplus+4)*C/CodingRate);
E_CB=CbBitSelection(C, G, NumLayers, Qm);
% Channel decoding the TB
% 不用分块时，直接码率匹配后解码即可
if (C==1)   % single CB, no CB CRC used
    % Rate dematching, with bit insertion
    deRMCbData = RateDematcher(-in, Kplus);
    % Turbo decode the single CB
    tDecCbData =TurboDecoderTB(deRMCbData, intrlvrIndices, prmLTE);
    % Unify code paths
    decTbData  = logical(tDecCbData);
else % multiple CBs in TB
    decTbData  = false((Kplus-24)*C,1); % Account for CB CRC bits
    startIdx = 0;
    for cbIdx = 1:C   
        % Code-block segmentation
        E=E_CB(cbIdx); 
        rxCbData = in(dtIdx(1:E) + startIdx);
        startIdx = startIdx + E;
        % Rate dematching, with bit insertion
        %   Flip input polarity to match decoder output bit mapping
        deRMCbData =RateDematcher(-rxCbData, Kplus);
        % Turbo decode each CB with CRC detection
        %   - uses early decoder termination at the CB level
        [crcDetCbData, ~, iters]  = TurboDecoderTB(deRMCbData,intrlvrIndices, prmLTE);       
        % Code-block concatention
        decTbData((1:(Kplus-24)) + (cbIdx-1)*(Kplus-24)) = logical(crcDetCbData);
    end
end