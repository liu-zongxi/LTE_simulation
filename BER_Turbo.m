%% Constants
clear;clc;
% 调制参数
ModulationMode=1;               % QPSK
Mode_M_Mapping = [4 16 64];
M=Mode_M_Mapping(ModulationMode);
k=log2(M);
% Gold码参数
nS = 0;                         % 子帧索引起始
% Turbo码参数
nIters = 1:1:5;                      % Turbo解码迭代次数
FRM=2432;                       % Frame的长度
Indices = lteIntrlvrIndices(FRM);% 生成交织器
% SNR设置
R= FRM/(3* FRM + 4*3);          % 码率是3K+4
EbN0s = 1:0.5:5;                 
SNRs = EbN0s + 10*log10(k) + 10*log10(R);
nSNR = length(SNRs);
noiseVars = 10.^(-SNRs/10);
% 参数初始化
maxNumErrs = 1e6;
maxNumBits = 1e6;
BERs = zeros(nSNR , length(nIters));
gss = ["-kx" "-^" "-ro" "-b>" "-g<" "-m+"];   % 画图图像，注意使用双引号
%% Processsing loop modeling transmitter, channel model and receiver
for inIter = 1:length(nIters)
    nIter = nIters(inIter);
    gs = gss(inIter);
    for iSNR = 1:nSNR
        numErrs = 0; numBits = 0;
        nS = 0;
        snr = SNRs(iSNR);
        noiseVar = noiseVars(iSNR);
        while ((numErrs < maxNumErrs) && (numBits < maxNumBits))
            % Transmitter
            u  =  randi([0 1], FRM,1);                                                            % Randomly generated input bits
            t0 = TurboEncoder(u, Indices);                                                   % Turbo Encoder 
            t1 = Scrambler(t0, nS);                                                                % Scrambler
            t2 = Modulator(t1, ModulationMode);                                       % Modulator
            % Channel
            c0 = AWGNChannel(t2, snr);                                                      % AWGN channel
            % Receiver
            r0 = DemodulatorSoft(c0, ModulationMode, noiseVar);            % Demodulator
            r1 = DescramblerSoft(r0, nS);                                                     % Descrambler
            % 取负号是因为软译码和软解调LLR定义不同
            y  = TurboDecoder(-r1, Indices, nIter);                                     % Turbo Deocder
            % Measurements
            numErrs     = numErrs + sum(y~=u);                                          % Update number of bit errors
            numBits     = numBits + FRM;                                                     % Update number of bits processed
            % Manage slot number with each subframe processed
            nS = nS + 2; nS = mod(nS, 20);
        end
        ber = numErrs/numBits;                                          % Compute Bit Error Rate (BER)
        BERs(iSNR, inIter) = ber;
    end
    semilogy(EbN0s, BERs(:, inIter), gs);
    hold on;
end
%% Clean up & collect results
% for i = 1:length(nIters)
%     semilogy(EbN0s, BERs(:, i));
%     hold on;
% end