function [dataIn, dataOut, txSig, rxSig, dataRx, yRec, csr_ref]...
    = commlteSISO_step(nS, snrdB, prmLTEDLSCH, prmLTEPDSCH, prmMdl)
%% TX
%  Generate payload
% 生成数据，0号子帧和10号时隙的长度和别的是不同的
% 因为BCH和SSS的缘故，注意nS表示的是时隙而不是子帧
dataIn = genPayload_HZ(nS,  prmLTEDLSCH.TBLenVec);
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
% Generate Cell-Specific Reference (CSR) signals
csr = CSRgenerator(nS, prmLTEPDSCH.numTx);
% Resource grid filling
% 一个RB中有８个参考信号
E=8*prmLTEPDSCH.Nrb;
csr_ref=reshape(csr(1:E),2*prmLTEPDSCH.Nrb,4);
txGrid = REmapper_1Tx(modOut, csr_ref, nS, prmLTEPDSCH);
% OFDM transmitter
txSig = OFDMTx(txGrid, prmLTEPDSCH);
%% Channel
% SISO Fading channel
[rxFade, chPathG] = MIMOFadingChan(txSig, prmLTEPDSCH, prmMdl);
% 注意这里预估出的H是只有dataidx的，他是理想的根据chPathG即信道增益获得的
idealhD = lteIdChEst(prmLTEPDSCH,  prmMdl, chPathG, nS);
% Add AWG noise
nVar = 10.^(0.1.*(-snrdB));
rxSig =  AWGNChannel2(rxFade, nVar);
%% RX
% OFDM Rx
rxGrid = OFDMRx(rxSig, prmLTEPDSCH);
% updated for numLayers -> numTx
[dataRx, csrRx, idx_data] = REdemapper_1Tx(rxGrid, nS, prmLTEPDSCH);
% MIMO channel estimation
if prmMdl.chEstOn
    chEst = ChanEstimate_1Tx(prmLTEPDSCH, csrRx,  csr_ref, 'interpolate');
    hD=chEst(idx_data);
else
    hD = idealhD;
end
% Frequency-domain equalizer
yRec = Equalizer(dataRx, hD, nVar, prmLTEPDSCH.Eqmode);
% Demodulate
demodOut = DemodulatorSoft(yRec, prmLTEPDSCH.modType, nVar);
% Descramble both received codewords
rxCW =  lteDescramble(demodOut, nS, 0, prmLTEPDSCH.maxG);
% Channel decoding includes - CB segmentation, turbo decoding, rate dematching
[decTbData1, ~,~] = lteTbChannelDecoding(nS, rxCW, Kplus1, C1,  prmLTEDLSCH, prmLTEPDSCH);
% Transport block CRC detection
[dataOut, ~] = CRCdetector(decTbData1);
end