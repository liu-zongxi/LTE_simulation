function [decTbData, crcCbFlags, iters] = lteTbChannelDecoding(nS, in, ...
                                        Kplus, C, prmLTEDLSCH, prmLTEPDSCH)
% Transport block channel decoding.
%
%   Key:
%       CB: Code Block
%       TB: Transport Block
%
% Reference:
% "3GPP Technical Specification Group Radio Access Network; Evolved
% Universal Terrestrial Radio Access (E-UTRA); Multiplexing and channel
% coding (Release 10)", 3GPP TS 36.212 v10.0.0 (2010-12).

%   Copyright 2012 The MathWorks, Inc.

%#codegen

persistent hCBTDec hCBTDecCRC;
if isempty(hCBTDec)
    % Turbo Decoder - CB level
    hCBTDec = comm.TurboDecoder('TrellisStructure', prmLTEDLSCH.trellis,...
        'InterleaverIndicesSource',  'Input port', ...
        'NumIterations', prmLTEDLSCH.maxIter);
end
if isempty(hCBTDecCRC)
    % Turbo Decoder - CB level with CRC check included
    hCBTDecCRC = commLTETurboDecoder('InterleaverIndicesSource', ...
        'Input port', 'MaximumIterations', prmLTEDLSCH.maxIter);
end
% 确保一下安全
assert(C <= prmLTEDLSCH.maxC, 'C>maxC'); assert(C > 0, 'C<=0');
assert(Kplus <= 6144, 'Kplus>6144'); assert(Kplus >= 40, 'Kplus<40');
intrlvrIndices = lteIntrlvrIndices(Kplus);
% Make fixed size and not var-size as scalar varS is not supported yet
crcCbFlags = zeros(prmLTEDLSCH.maxC, 1);            % default as no errors
iters      = zeros(prmLTEDLSCH.maxC, 1);

maxG = prmLTEPDSCH.maxG;        % max PDSCH bits 
G = maxG; % default
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

% Bit insertion parameters
Nl = prmLTEPDSCH.numLayPerCW; % Number of layers a TB is mapped to (Rel10)
Qm = prmLTEPDSCH.Qm;          % modulation bits
maxGprime = maxG/(Nl*Qm);
Gprime = G/(Nl*Qm);
gamma = mod(Gprime, C);

% Channel decoding the TB
if (C==1)   % single CB, no CB CRC used

    % Rate dematching, with bit insertion
    %   Flip input polarity to match decoder output bit mapping
    deRMCbData = lteCbRateDematching(-in, Kplus, C, G);
    
    % Turbo decode the single CB
    tDecCbData = step(hCBTDec, deRMCbData, intrlvrIndices);
    
    % Unify code paths
    decTbData  = logical(tDecCbData);
    crcCbFlags(1) = 0; % no errors
    iters(1)      = prmLTEDLSCH.maxIter;
    
else % multiple CBs in TB

    decTbData  = false((Kplus-24)*C,1); % Account for CB CRC bits
    E = Nl*Qm*ceil(maxGprime/prmLTEDLSCH.minC); % maximum-sized buffer
    coder.varsize('rxCbData', E, 1);
    coder.varsize('dtIdx', E, 1);
    dtIdx = (1:E).';
    startIdx = 0;
    
    for cbIdx = 1:C

        % Override with values per CB
        if ((cbIdx-1) <= (C-gamma-1)) 
           E_CB = Nl*Qm*floor(Gprime/C);
        else
           E_CB = Nl*Qm*ceil(Gprime/C);
        end
        % Code-block segmentation
        rxCbData = in(dtIdx(1:E_CB) + startIdx);
        startIdx = startIdx + E_CB;
        
        % Rate dematching, with bit insertion
        %   Flip input polarity to match decoder output bit mapping
        deRMCbData = lteCbRateDematching(-rxCbData, Kplus, C, E_CB);
        
        % Turbo decode each CB with CRC detection
        %   - uses early decoder termination at the CB level
        [crcDetCbData, crcCbFlags(cbIdx), iters(cbIdx)] = ...
                    step(hCBTDecCRC, deRMCbData, intrlvrIndices);
        
        % Code-block concatention
        decTbData((1:(Kplus-24))' + (cbIdx-1)*(Kplus-24)) = logical(crcDetCbData);
    end
    
end

% [EOF]
