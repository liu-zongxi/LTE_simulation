function hD = lteIdChEst(prmLTEPDSCH, prmMdl, chPathG, nS)
%LTEIDCHEST Ideal channel estimation for LTE subframes.
%
%   Given the system parameters and the MIMO channel path Gains, provide
%   the ideal channel estimates for the RE corresponding to the data.

%   Copyright 2012 The MathWorks, Inc.

% Pseudo-logic
% Option 1: Implemented below
%   Limitation - will work for path delays to be multiple of channel sample
%   time and largest pathDelay < nfft
%       add interpolation for unrestricted use
%
%   Given the 1920 x numPaths x Tx x Rx pathaGains, convert these
%   into single tap gains by way of OFDM CP
%   i.e. 1920 x Tx x Rx - in size
%   Per link processing
%       1920 x numPaths -> take mean over each OFDM symbol-> get 14 x numPaths,
%           acct for CP, take FFT, reorder and scale
%   Then similar to OFDM Rx and ExtData, get the Data RE based tap Gains
%   And use these going forward
%       size(chPathG)   1920 7 2 2
%       rxFade     1920x2           
%       rxSig      1920x2           
%       rxGrid     72x14x2         
%       chEst      912x2x2           
%       dataRx     648x2            
%       hD         648x2x2 
%
% Option 2: future consideration
%   Get channel gains, fft & average
%   For a 2x2 scheme first - try all channel EPA, EVA, ETU options
%   Work off pilots and interpolate between them - provide options

persistent hFFT; 
if isempty(hFFT) 
   hFFT = dsp.FFT; 
end 

% get parameters
numDataTones = prmLTEPDSCH.Nrb*12; % Nrb_sc = 12
N            = prmLTEPDSCH.N;       % NFFT
cpLen0       = prmLTEPDSCH.cpLen0;
cpLenR       = prmLTEPDSCH.cpLenR;

slotLen = (N*7 + cpLen0 + cpLenR*6);
% 生成多径信道时延
if strncmp(prmMdl.chanMdl, 'Fre', 3)
    pathDelays = 0;
elseif strncmp(prmMdl.chanMdl, 'EPA', 3)
    pathDelays = [0 30 70 90 110 190 410]*1e-9;
elseif strncmp(prmMdl.chanMdl, 'EVA', 3)
    pathDelays = [0 30 150 310 370 710 1090 1730 2510]*1e-9;
elseif strncmp(prmMdl.chanMdl, 'ETU', 3)
    pathDelays = [0 50 120 200 230 500 1600 2300 5000]*1e-9;
elseif strncmp(prmMdl.chanMdl, 'f', 1)
    pathDelays = [0 10 20 30 100]*(1/prmLTEPDSCH.chanSRate);
elseif strncmp(prmMdl.chanMdl, 'User', 4)
    pathDelays = prmMdl.pathDelays *(1/prmLTEPDSCH.chanSRate);
end
% Delays, in terms of number of channel samples, +1 for indexing
% 获得多径在NFFT的位置
sampIdx = round(pathDelays/(1/prmLTEPDSCH.chanSRate)) + 1;

[~, numPaths, numTx, numRx] = size(chPathG);

H = complex(zeros(numDataTones, 14, numTx, numRx));
for i= 1:numTx
    for j = 1:numRx
        % link_PathG是一个TR之间的多径信道的增益和个数，第一维的长度应该是slotLen
        link_PathG = chPathG(:, :, i, j);
        % Split this per OFDM symbol
        % g的第一维是每个符号，第二维是多径的每一个
        g = complex(zeros(2*7, numPaths));
        for jj = 1:2 % over two slots
            % First OFDM symbol
            % g是如何计算的呢？在一个OFDM的NFFT内平均一下
            % 第二维都是多径的个数这就对上了
            % 最终得到的g是每一个符号的增益，个数是多径个数
            g((jj-1)*7+1, :) = mean(link_PathG((jj-1)*slotLen + (1:(N+cpLen0)), :), 1);
            
            % Next 6 OFDM symbols
            for k = 1:6
                g((jj-1)*7+k+1, :) = mean(link_PathG((jj-1)*slotLen+cpLen0+k*N+(k-1)*cpLenR + (1:(N+cpLenR)), :), 1);
            end
        end
        % h的脉冲响应，他是如何计算呢？
        hImp = complex(zeros(2*7, N));
        % 本来都是0，把有多径的位置的增益加上，后面用于卷积，这和一开始OFDM的多径h是类似的
        % channel = (randn(1,Ntap)+1j*randn(1,Ntap)).*sqrt(Power/2);
        % h = zeros(1,Lch);
        % h(Delay+1) = channel; % 冲激函数采样
        hImp(:, sampIdx) = g; % assign pathGains at sample locations
        % FFT processing
        % 本来是横着的，改为竖着
        h = step(hFFT, hImp.'); 
        
        % Reorder, remove DC, Unpack channel gains
        % fftshift，h也不能免
        h = [h(N/2+1:N, :); h(1:N/2, :)];
        % 只取出有用的部分，得到H了这就
        H(:, :, i, j) = [h(N/2-numDataTones/2+1:N/2, :); h(N/2+2:N/2+1+numDataTones/2, :)];
    end
end
% H - 72x14x2x2

% Now, align these with the data RE per antenna link and reuse them
% squeeze删除长度为1的维度，这里就是一个接收天线一个接收天线处理
% 这个函数的作用就是找出哪些是CSR可以算出来的，哪些是H要插值出来的
% 因为H才有用，只需要计算数据信号
% 肯定是一个接收机一个接收机来处理，所以遍历发射天线
[H_rx1, csrRx1] = lteExtData( squeeze(H(:,:,:,1)), nS, prmLTEPDSCH, 'chan');
hD =  complex(zeros(size(H_rx1,1), numTx, numRx));
hD(:,:,1) = H_rx1;
csrRx =  complex(zeros(size(csrRx1,1), numTx, numRx));
csrRx(:,:,1) = csrRx1;
for i = 2:numRx
    [hD(:,:,i), csrRx(:,:,i)] = lteExtData( squeeze(H(:,:,:,i)), nS, prmLTEPDSCH, 'chan');
end

% [EOF]
