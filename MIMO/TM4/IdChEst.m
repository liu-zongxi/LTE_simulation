function H = IdChEst(prmLTEPDSCH, prmMdl, chPathG)
% 理想信道估计
% Ideal channel estimation for LTE subframes
%
%   Given the system parameters and the MIMO channel path Gains, provide
%   the ideal channel estimates for the RE corresponding to the data.
%   Limitation - will work for path delays that are multiple of channel sample
%   time and largest pathDelay < size of FFT
%   Implementation based on FFT of channel impulse response
persistent hFFT; 
if isempty(hFFT) 
   hFFT = dsp.FFT; 
end 
% get parameters
% 基本参数
numDataTones = prmLTEPDSCH.Nrb*12; % Nrb_sc = 12
N                        = prmLTEPDSCH.N;
cpLen0               = prmLTEPDSCH.cpLen0;
cpLenR               = prmLTEPDSCH.cpLenR;
Ndl_symb           = prmLTE.Ndl_symb;        % 7    for normal mode
slotLen               = (N*Ndl_symb + cpLen0 + cpLenR*6);
% Get path delays
pathDelays = prmMdl.PathDelays;
% Delays, in terms of number of channel samples, +1 for indexing
sampIdx = round(pathDelays/(1/prmLTEPDSCH.chanSRate)) + 1;
% 获得信道的参数
[~, numPaths, numTx, numRx] = size(chPathG);
% Initialize output 
% 信道的大小
H = complex(zeros(numDataTones, 2*Ndl_symb, numTx, numRx));
for i= 1:numTx
    for j = 1:numRx
        % 获得当前两天线之间的增益
        link_PathG = chPathG(:, :, i, j);
        % Split this per OFDM symbol
        g = complex(zeros(2*Ndl_symb, numPaths));
        % 先解决1和7的OFDM
        for n = 1:2 % over two slots
            % First OFDM symbol
            Index=(n-1)*slotLen + (1:(N+cpLen0));
            % 得到一个符号时间内的平均增益
            g((n-1)*Ndl_symb+1, :) = mean(link_PathG(Index, :), 1);           
            % Next 6 OFDM symbols
            % 其他的OFDM符号
            for k = 1:6
                Index=(n-1)*slotLen+cpLen0+k*N+(k-1)*cpLenR + (1:(N+cpLenR));
                g((n-1)*Ndl_symb+k+1, :) = mean(link_PathG(Index, :), 1);
            end
        end
        % h的时域
        hImp = complex(zeros(2*Ndl_symb, N));
        % assign pathGains at impulse response sample locations
        % 获得时域h
        hImp(:, sampIdx) = g; 
        % FFT of impulse response
        h = step(hFFT, hImp.'); 
        % Reorder, remove DC, Unpack channel gains
        % fftshift
        h = [h(N/2+1:N, :); h(1:N/2, :)];
        % 取出需要的频率
        H(:, :, i, j) = [h(N/2-numDataTones/2+1:N/2, :); h(N/2+2:N/2+1+numDataTones/2, :)];
    end
end