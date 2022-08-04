function [out, Kplus, C] = lteTbChannelCoding(in, nS, prmLTEDLSCH, prmLTEPDSCH)
% Transport block channel coding
%
%   Key:
%       CB: Code Block
%       TB: Transport Block
%
% Reference: [1] "3GPP Technical Specification Group Radio Access Network;
% Evolved Universal Terrestrial Radio Access (E-UTRA); Multiplexing and
% channel coding (Release 10)", 3GPP TS 36.212 v10.0.0 (2010-12).

%   Copyright 2012 The MathWorks, Inc.

%#codegen

persistent hCBCRCGen hCBTEnc1 hCBTEncAll;
if isempty(hCBCRCGen)
    % CRC generator - CB level
    hCBCRCGen = comm.CRCGenerator('Polynomial', [1 1 zeros(1, 16) 1 1 0 0 0 1 1]);
end
if isempty(hCBTEnc1)
    % Turbo Encoder - CB level, C==1
    hCBTEnc1 = comm.TurboEncoder('TrellisStructure', prmLTEDLSCH.trellis, ...
        'InterleaverIndicesSource',  'Input port');
end
if isempty(hCBTEncAll)
    % Turbo Encoder - CB level, C>1
    hCBTEncAll = comm.TurboEncoder('TrellisStructure', prmLTEDLSCH.trellis, ...
        'InterleaverIndicesSource',  'Input port');
end

inLen = size(in, 1);
% 码块分割和交织，获得C和K+
[C, ~, Kplus] =  lteCblkSegParams(inLen-24);
intrlvrIndices = lteIntrlvrIndices(Kplus);
% 总比特数，会有三种情况，对应子帧0，5和普通
G = prmLTEPDSCH.maxG; % default
switch nS
    case {0}
        G = prmLTEPDSCH.numPDSCHBits(1);
    case {2, 4, 6, 8, 12, 14, 16, 18}
        G = prmLTEPDSCH.numPDSCHBits(3);
    case {10}
        G = prmLTEPDSCH.numPDSCHBits(2);
    otherwise
        % Do nothing
end

% Bit selection parameters
Nl = prmLTEPDSCH.numLayPerCW; % Number of layers a TB is mapped to (Rel10)
Qm = prmLTEPDSCH.Qm;          % modulation bits
Gprime = G/(Nl*Qm);
gamma = mod(Gprime, C);

% Initialize output
out = false(G, 1);
% Channel coding the TB
if (C==1) % single CB, no CB CRC used
    % Turbo encode
    tEncCbData = step(hCBTEnc1, in, intrlvrIndices);
    
    % Rate matching, with bit selection
    rmCbData = lteCbRateMatching(tEncCbData, Kplus, C, G);

    % unify code paths
    out = logical(rmCbData);
else % multiple CBs in TB
    startIdx = 0;
    for cbIdx = 1:C
        % Code-block segmentation
        cbData = in((1:(Kplus-24))' + (cbIdx-1)*(Kplus-24));
        
        % Append checksum to each CB
        crcCbData = step(hCBCRCGen, cbData);
        
        % Turbo encode each CB
        tEncCbData = step(hCBTEncAll, crcCbData, intrlvrIndices);
        
        % Rate matching with bit selection
        if ((cbIdx-1) <= (C-gamma-1))
            E = Nl*Qm*floor(Gprime/C);
        else
            E = Nl*Qm*ceil(Gprime/C);
        end        
        rmCbData = lteCbRateMatching(tEncCbData, Kplus, C, E);
        
        % Code-block concatenation
        out((1:E)' + startIdx) = logical(rmCbData);
        startIdx = startIdx + E;
    end
end

% [EOF]
