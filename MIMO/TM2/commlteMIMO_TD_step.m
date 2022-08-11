function [dataIn, dataOut, txSig, rxSig, dataRx, yRec, csr_ref]...
    = commlteMIMO_TD_step(nS, snrdB, prmLTEDLSCH, prmLTEPDSCH, prmMdl)
%% TX
%  Generate payload
% 生成数据
dataIn = genPayload(nS,  prmLTEDLSCH.TBLenVec);
% 添加CRC
% Transport block CRC generation
tbCrcOut1 =CRCgenerator(dataIn);
% Channel coding includes - CB segmentation, turbo coding, rate matching,
% bit selection, CB concatenation - per codeword
[data, Kplus1, C1] = lteTbChannelCoding(tbCrcOut1, nS, prmLTEDLSCH, prmLTEPDSCH);
%Scramble codeword
scramOut = lteScramble(data, nS, 0, prmLTEPDSCH.maxG);
% Modulate
modOut = Modulator(scramOut, prmLTEPDSCH.modType);
% TD with SFBC
numTx=prmLTEPDSCH.numTx;
alamouti = TDEncode(modOut(:,1),numTx);
% Generate Cell-Specific Reference (CSR) signals
% CSR的处理
csr = CSRgenerator(nS, numTx);
csr_ref=complex(zeros(2*prmLTEPDSCH.Nrb, 4, numTx));
for m=1:numTx
    csr_pre=csr(1:2*prmLTEPDSCH.Nrb,:,:,m);
    csr_ref(:,:,m)=reshape(csr_pre,2*prmLTEPDSCH.Nrb,4);
end
% Resource grid filling
txGrid = REmapper_mTx(alamouti, csr_ref, nS, prmLTEPDSCH);
% OFDM transmitter
txSig = OFDMTx(txGrid, prmLTEPDSCH);
%% Channel
% MIMO Fading channel
[rxFade, chPathG] = MIMOFadingChan(txSig, prmLTEPDSCH, prmMdl);
% Add AWG noise
nVar = 10.^(0.1.*(-snrdB));
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
    % Based on Transmit Diversity  with SFBC combiner
    yRec = TDCombine(dataRx, hD, prmLTEPDSCH.numTx, prmLTEPDSCH.numRx);
end
% Demodulate
demodOut = DemodulatorSoft(yRec, prmLTEPDSCH.modType, nVar);
% Descramble received codeword
rxCW =  lteDescramble(demodOut, nS, 0, prmLTEPDSCH.maxG);
% Channel decoding includes - CB segmentation, turbo decoding, rate dematching
[decTbData1, ~,~] = lteTbChannelDecoding(nS, rxCW, Kplus1, C1,  prmLTEDLSCH, prmLTEPDSCH);
% Transport block CRC detection
[dataOut, ~] = CRCdetector(decTbData1);
end