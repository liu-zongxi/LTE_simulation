function p  = prmsPDSCH(txMode, chanBW, contReg, modType, numTx, numRx, numCodeWords)
% 全新的prmsPDSCH，增加了MIMO的内容
%% PDSCH parameters
% 根据模式选择带宽
switch chanBW
    case 1      % 1.4 MHz
        BW = 1.4e6; N = 128; cpLen0 = 10; cpLenR = 9;
        Nrb = 6; chanSRate = 1.92e6;
    case 2      % 3 MHz
        BW = 3e6; N = 256; cpLen0 = 20; cpLenR = 18;
        Nrb = 15; chanSRate = 3.84e6;
    case 3      % 5 MHz
        BW = 5e6; N = 512; cpLen0 = 40; cpLenR = 36;
        Nrb = 25; chanSRate = 7.68e6;
    case 4      % 10 MHz
        BW = 10e6; N = 1024; cpLen0 = 80; cpLenR = 72;
        Nrb = 50; chanSRate = 15.36e6;
    case 5      % 15 MHz
        BW = 15e6; N = 1536; cpLen0 = 120; cpLenR = 108;
        Nrb = 75; chanSRate = 23.04e6;
    case 6      % 20 MHz
        BW = 20e6; N = 2048; cpLen0 = 160; cpLenR = 144;
        Nrb = 100; chanSRate = 30.72e6;
end
% OFDM参数设置
p.BW = BW;                  % Channel bandwidth
p.N = N;                    % NFFT
p.cpLen0 = cpLen0;          % Cyclic prefix length for 1st symbol
p.cpLenR = cpLenR;          % Cyclic prefix length for remaining
p.Nrb = Nrb;                % Number of resource blocks
p.chanSRate = chanSRate;    % Channel sampling rate
p.contReg = contReg;
% MIMO 参数
switch txMode
    case 1 % SISO transmission
        % 天线数
        p.numTx = numTx;
        p.numRx = numRx;
        numCSRRE_RB = 2*2*2; % CSR, RE per OFDMsym/slot/subframe per RB
        % 层数还是1
        p.numLayers = 1;
        p.numCodeWords = 1;
    % 模式2 发射分集
    case 2 % Transmit diversity
        p.numTx = numTx;
        p.numRx = numRx;
        switch numTx
            case 1
                numCSRRE_RB = 2*2*2; % CSR, RE per OFDMsym/slot/subframe per RB
            case 2    % 2xnumRx
                % RE - resource element, RB - resource block
                numCSRRE_RB = 4*2*2; % CSR, RE per OFDMsym/slot/subframe per RB
            case 4      % 4xnumRx
                % 34的特殊情况
                numCSRRE_RB = 4*3*2; % CSR, RE per OFDMsym/slot/subframe per RB
        end
        p.numLayers = 1;
        p.numCodeWords = 1; % for transmit diversity
    % 模式3 开环空分复用
    case 3 % CDD Spatial multiplexing
        p.numTx = numTx;
        p.numRx = numRx;
        switch numTx
            case 1
                numCSRRE_RB = 2*2*2; % CSR, RE per OFDMsym/slot/subframe per RB
            case 2      % 2x2
                % RE - resource element, RB - resource block
                numCSRRE_RB = 4*2*2; % CSR, RE per OFDMsym/slot/subframe per RB
            case 4      % 4x4
                numCSRRE_RB = 4*3*2; % CSR, RE per OFDMsym/slot/subframe per RB
        end
        p.numLayers = min([p.numTx, p.numRx]);
        p.numCodeWords = 1; % for spatial multiplexing
    % 模式4 空分复用
    case 4 % Spatial multiplexing
        p.numTx = numTx;
        p.numRx = numRx;
        switch numTx
            case 1
                numCSRRE_RB = 2*2*2; % CSR, RE per OFDMsym/slot/subframe per RB
            case 2      % 2x2
                % RE - resource element, RB - resource block
                numCSRRE_RB = 4*2*2; % CSR, RE per OFDMsym/slot/subframe per RB
            case 4      % 4x4
                numCSRRE_RB = 4*3*2; % CSR, RE per OFDMsym/slot/subframe per RB
        end
        p.numLayers = min([p.numTx, p.numRx]);
        p.numCodeWords = numCodeWords; % for spatial multiplexing
end
% For Normal cyclic prefix, FDD mode
p.deltaF = 15e3;    % subcarrier spacing
p.Nrb_sc = 12;      % no. of subcarriers per resource block
p.Ndl_symb = 7;     % no. of OFDM symbols in a slot
%% Modeling a subframe worth of data (=> 2 slots)
numResources = (p.Nrb*p.Nrb_sc)*(p.Ndl_symb*2);
numCSRRE = numCSRRE_RB * p.Nrb;               % CSR, RE per OFDMsym/slot/subframe per RB
% Actual PDSCH bits calculation - accounting for PDCCH, PBCH, PSS, SSS
% 由于CSR根据发射天线不同而不同导致的各种不同
switch p.numTx
    % numRE in control region - minus the CSR
    case 1
        numContRE = (10 + 12*(p.contReg-1))*p.Nrb;
        numBCHRE = 60+72+72+72; % removing the CSR present in 1st symbol
    case 2
        numContRE = (8 + 12*(p.contReg-1))*p.Nrb;
        numBCHRE = 48+72+72+72; % removing the CSR present in 1st symbol
    case 4
        numContRE = (8 + (p.contReg>1)*(8+ 12*(p.contReg-2)))*Nrb;
        numBCHRE = 48+48+72+72; % removing the CSR present in 1,2 symbol
end
numSSSRE=72;
numPSSRE=72;
numDataRE=zeros(3,1);
% Account for BCH, PSS, SSS and PDCCH for subframe 0
numDataRE(1)=numResources-numCSRRE-numContRE-numSSSRE - numPSSRE-numBCHRE;
% Account for PSS, SSS and PDCCH for subframe 5
numDataRE(2)=numResources-numCSRRE-numContRE-numSSSRE - numPSSRE;
% Account for PDCCH only in all other subframes
numDataRE(3)=numResources-numCSRRE-numContRE;
% Maximum data resources - with no extra overheads (only CSR + data)
p.numResources=numResources;
p.numCSRResources =  numCSRRE;
p.numDataResources = p.numResources - p.numCSRResources;
p.numContRE = numContRE;
p.numBCHRE = numBCHRE;
p.numSSSRE=numSSSRE;
p.numPSSRE=numPSSRE;
p.numDataRE=numDataRE;
% Modulation types , bits per symbol, number of layers per codeword
Qm = 2 * modType;
p.Qm = Qm;
p.numLayPerCW = p.numLayers/p.numCodeWords;
% Maximum data bits - with no extra overheads (only CSR + data)
p.numDataBits = p.numDataResources*Qm*p.numLayPerCW;
numPDSCHBits =numDataRE*Qm*p.numLayPerCW;
p.numPDSCHBits = numPDSCHBits;
p.maxG = max(numPDSCHBits);