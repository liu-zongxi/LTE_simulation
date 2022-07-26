%% Constants
clear;clc;
prmLTE.maxIter = 6;
prmLTE.Rate = 1/3;
prmLTE.Mode = 1;
% 调制参数
ModulationMode=prmLTE.Mode;               % QPSK
Mode_M_Mapping = [4 16 64];
M=Mode_M_Mapping(ModulationMode);
k=log2(M);
% Gold码参数
nS = 0;                         % 子帧索引起始
% Turbo码参数
nIters = 6;                      % Turbo解码迭代次数
FRM=2432-24;                    % Size of bit frame
Kplus=FRM+24;
Indices = lteIntrlvrIndices(Kplus);
maxIter = prmLTE.maxIter;
CodingRate = prmLTE.Rate;
% SNR设置
EbN0s = 0:0.2:2;                 
SNRs = EbN0s + 10*log10(k) + 10*log10(CodingRate);
nSNR = length(SNRs);
noiseVars = 10.^(-SNRs/10);
% 参数初始化
% 码率
maxNumErrs = 1e6;
maxNumBits = 1e6;
gss = ["-kx" "-^" "-ro" "-b>" "-g<" "-m+"];   % 画图图像，注意使用双引号
% Hist=dsp.Histogram('LowerLimit', 1, 'UpperLimit', maxIter, 'NumBins', maxIter, 'RunningHistogram', true);
array_iter = zeros(416, 1);
%% Processsing loop modeling transmitter, channel model and receiver
for iSNR = 1:nSNR
    numErrs = 0; numBits = 0;
    nS = 0;
    snr = SNRs(iSNR);
    noiseVar = noiseVars(iSNR);
    num_while = 0;
    while ((numErrs < maxNumErrs) && (numBits < maxNumBits))
        num_while = num_while + 1;
        % Transmitter
        u  =  randi([0 1], FRM,1);                                                           % Randomly generated input bits
        data= CbCRCGenerator(u);                                                        % Transport block CRC code
        [t1, Kplus, C] = TbChannelCoding(data,prmLTE);                     % Transport Channel encoding
        t2 = Scrambler(t1, nS);                                                                % Scrambler
        t3 = Modulator(t2, ModulationMode);                                       % Modulator
        % Channel
        c0 = AWGNChannel(t3, snr);                                                      % AWGN channel
        % Receiver
        r0 = DemodulatorSoft(c0, ModulationMode, noiseVar);            % Demodulator
        r1 = DescramblerSoft(r0, nS);                                                     % Descrambler
         r2= TbChannelDecoding(r1, Kplus, C, prmLTE);                        % Transport Channel decoding
        y   =  CbCRCDetector(r2);                                                           % Code block CRC dtector
        % Measurements
        numErrs     = numErrs + sum(y~=u);                                           % Update number of bit errors
        numBits     = numBits + FRM;                                                     % Update number of bits processed
        % Manage slot number with each subframe processed
        nS = nS + 2; nS = mod(nS, 20);
    end
    ber = numErrs/numBits;                                          % Compute Bit Error Rate (BER)
    BERs(iSNR) = ber
end
semilogy(EbN0s, BERs(:), gs);
%% Clean up & collect results
% ber = numErrs/numBits;                                          % Compute Bit Error Rate (BER)