%--------------------------信道对BER的影响--------------------%
%-----------------------author:lzx-------------------------%
%-----------------------date:2022年7月26日10点50分-----------------%
%% Constants
clear;clc;
prmLTE.maxIter = 6;
prmLTE.Rate = 1/3;
prmLTE.Mode = 3;
prmLTE.maxIter=6;
prmLTE.chanSRate=3.654e6;
chanSRate=prmLTE.chanSRate;

FRM=2432-24;                                          
Kplus=FRM+24;
ModulationMode=prmLTE.Mode;               % QPSK
Mode_M_Mapping = [4 16 64];
M=Mode_M_Mapping(ModulationMode);
k=log2(M);
maxIter=prmLTE.maxIter;
CodingRate=prmLTE.Rate;
EbNos = 9;
SNR = EbNos + 10*log10(k) + 10*log10(CodingRate);
noiseVar = 10.^(-SNR/10);
nSNR = length(SNR);
% 码率
maxNumErrs = 1e6;
maxNumBits = 1e6;
%% 主程序
for ichannel = 1:4
    numErrs = 0; numBits = 0; nS=0;
    if ichannel == 1
        % 低移动率平坦衰落信道
        % 没有时延，没有多径增益，没有多普勒频移
        prmLTE.PathDelays=0*(1/chanSRate);
        prmLTE.PathGains= 0;
        prmLTE.DopplerShift= 0;
        clear functions
    elseif ichannel == 2
        % 高移动率平坦衰落信道
        % 没有时延，没有多径增益，有多普勒频移
        prmLTE.PathDelays=0*(1/chanSRate);
        prmLTE.PathGains= 0;
        prmLTE.DopplerShift= 70;
        clear functions
    elseif ichannel == 3
        % 低移动率频域选择性衰落信道
        % 有多径时延，有多径增益，无多普勒频移
        prmLTE.PathDelays= [0 10 20 30 100]*(1/chanSRate);
        prmLTE.PathGains= [0 -3 -6 -8 -172];
        prmLTE.DopplerShift= 0;
        clear functions
    elseif ichannel == 4
        % 高移动率频域选择性衰落信道
        % 有多径时延，有多径增益，有多普勒频移
        prmLTE.PathDelays= [0 10 20 30 100]*(1/chanSRate);
        prmLTE.PathGains= [0 -3 -6 -8 -172];
        prmLTE.DopplerShift= 70;
        clear functions
    end
    while ((numErrs < maxNumErrs) && (numBits < maxNumBits))
        % 发射机
        u  =  randi([0 1], FRM,1);
        data= CbCRCGenerator(u);
        [t1, Kplus, C] = TbChannelCoding(data, prmLTE);
        t2 = Scrambler(t1, nS);                                                                % Scrambler
        t3 = Modulator(t2, ModulationMode);
        % 信道
        rxFade =  ChanModelFading(t3, prmLTE);
        % rxFade = t3;
        c0  = AWGNChannel2(rxFade, noiseVar);
        zVisualize_ex01(prmLTE, t3, c0); 
        % 接收机
        r0 = DemodulatorSoft(c0, ModulationMode, noiseVar);            % Demodulator
        r1 = DescramblerSoft(r0, nS);
        r2= TbChannelDecoding(r1, Kplus, C, prmLTE);                        % Transport Channel decoding
        y   =  CbCRCDetector(r2);
        % Measurements
        sum(y~=u)
        numErrs     = numErrs + sum(y~=u);                                           % Update number of bit errors
        numBits     = numBits + FRM;                                                     % Update number of bits processed
        % Manage slot number with each subframe processed
        nS = nS + 2; nS = mod(nS, 20);
    end
end