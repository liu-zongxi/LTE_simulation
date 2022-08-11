function [dataIn, dataOut, txSig, rxSig, dataRx, yRec, csr_ref]...
    = commlteMIMO_SM2_Mode3_step(nS, snrdB, prmLTEDLSCH, prmLTEPDSCH, prmMdl)
%% TX
%  Generate payload
dataIn1 = genPayload(nS,  prmLTEDLSCH.TBLenVec);
dataIn2 = genPayload(nS,  prmLTEDLSCH.TBLenVec);
dataIn=[dataIn1;dataIn2];
% Transport block CRC generation
tbCrcOut1 =CRCgenerator(dataIn1);
tbCrcOut2 =CRCgenerator(dataIn2);
% Channel coding includes - CB segmentation, turbo coding, rate matching,
% bit selection, CB concatenation - per codeword
[data1, Kplus1, C1] = lteTbChannelCoding(tbCrcOut1, nS, prmLTEDLSCH, prmLTEPDSCH);
[data2, Kplus2, C2] = lteTbChannelCoding(tbCrcOut2, nS, prmLTEDLSCH, prmLTEPDSCH);
%Scramble codeword
scramOut1 = lteScramble(data1, nS, 0, prmLTEPDSCH.maxG);
scramOut2 = lteScramble(data2, nS, 0, prmLTEPDSCH.maxG);
% Modulate
modOut1 = Modulator(scramOut1, prmLTEPDSCH.modType);
modOut2 = Modulator(scramOut2, prmLTEPDSCH.modType);
% Map modulated symbols  to layers
numTx=prmLTEPDSCH.numTx;
LayerMapOut = LayerMapper(modOut1, modOut2, prmLTEPDSCH);
% Precoding
PrecodeOut = SpatialMuxPrecoderOpenLoop(LayerMapOut, prmLTEPDSCH);
% Generate Cell-Specific Reference (CSR) signals
csr = CSRgenerator(nS, numTx);
csr_ref=complex(zeros(2*prmLTEPDSCH.Nrb, 4, numTx));
for m=1:numTx
    csr_pre=csr(1:2*prmLTEPDSCH.Nrb,:,:,m);
    csr_ref(:,:,m)=reshape(csr_pre,2*prmLTEPDSCH.Nrb,4);
end
% Resource grid filling
txGrid = REmapper_mTx(PrecodeOut, csr_ref, nS, prmLTEPDSCH);
% OFDM transmitter
txSig = OFDMTx(txGrid, prmLTEPDSCH);
%% Channel
% MIMO Fading channel
[rxFade, chPathG] = MIMOFadingChan(txSig, prmLTEPDSCH, prmMdl);
% Add AWG noise
sigPow = 10*log10(var(rxFade));
nVar = 10.^(0.1.*(sigPow-snrdB));
rxSig =  AWGNChannel(rxFade, nVar);
%% RX
% OFDM Rx
rxGrid = OFDMRx(rxSig, prmLTEPDSCH);
% updated for numLayers -> numTx
[dataRx, csrRx, idx_data] = REdemapper_mTx(rxGrid, nS, prmLTEPDSCH);
% MIMO channel estimation
if prmMdl.chEstOn
    chEst = ChanEstimate_mTx(prmLTEPDSCH, csrRx,  csr_ref, prmMdl.chEstOn);
    hD     = ExtChResponse(chEst, idx_data, prmLTEPDSCH);
else
    idealChEst = IdChEst(prmLTEPDSCH, prmMdl, chPathG);
    hD =  ExtChResponse(idealChEst, idx_data, prmLTEPDSCH);
end
% Frequency-domain equalizer
if (numTx==1)
    % Based on Maximum-Combining Ratio (MCR)
    yRec = Equalizer_simo(dataRx, hD, nVar, prmLTEPDSCH.Eqmode);
else
    % Based on Spatial Multiplexing
    yRec = MIMOReceiver_OpenLoop(dataRx, hD, prmLTEPDSCH, nVar);
end
% Demap received codeword(s)
[cwOut1, cwOut2] = LayerDemapper(yRec, prmLTEPDSCH);    
if prmLTEPDSCH.Eqmode < 3
    % Demodulate
    demodOut1 = DemodulatorSoft(cwOut1, prmLTEPDSCH.modType, max(nVar));
    demodOut2 = DemodulatorSoft(cwOut2, prmLTEPDSCH.modType, max(nVar));
else
    demodOut1 = cwOut1;
    demodOut2 = cwOut2;
end
% Descramble received codeword
rxCW1 =  lteDescramble(demodOut1, nS, 0, prmLTEPDSCH.maxG);
rxCW2 =  lteDescramble(demodOut2, nS, 0, prmLTEPDSCH.maxG);
% Channel decoding includes - CB segmentation, turbo decoding, rate dematching
[decTbData1, ~,~] = lteTbChannelDecoding(nS, rxCW1, Kplus1, C1,  prmLTEDLSCH, prmLTEPDSCH);
[decTbData2, ~,~] = lteTbChannelDecoding(nS, rxCW2, Kplus2, C2,  prmLTEDLSCH, prmLTEPDSCH);
% Transport block CRC detection
[dataOut1, ~] = CRCdetector(decTbData1);
[dataOut2, ~] = CRCdetector(decTbData2);
dataOut=[dataOut1;dataOut2];
end