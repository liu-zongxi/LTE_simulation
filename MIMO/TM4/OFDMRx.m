function y = OFDMRx(in, prmLTE)
%#codegen
persistent hFFT;
if isempty(hFFT)
    hFFT = dsp.FFT;
end
% For a subframe of data
% Nk
numDataTones = prmLTE.Nrb*prmLTE.Nrb_sc;
% 符号数
numSymb = prmLTE.Ndl_symb*2; 
[~, numLayers] = size(in);
% N assumes 15KHz subcarrier spacing, else N = 4096
% NFFT
N = prmLTE.N;
cpLen0 = prmLTE.cpLen0;
cpLenR = prmLTE.cpLenR;
% 一个时隙的长度
slotLen = (N*7 + cpLen0 + cpLenR*6);
tmp = complex(zeros(N, numSymb, numLayers));
% Remove CP - unequal lengths over a slot
% 去除CP
for j = 1:2 % over two slots
    % First OFDM symbol
    % 扩展CP单独去除
    tmp(:, (j-1)*7+1, :) = in((j-1)*slotLen+cpLen0 + (1:N), :);

    % Next 6 OFDM symbols
    % 普通CP去除
    for k = 1:6
        tmp(:, (j-1)*7+k+1, :) = in((j-1)*slotLen+cpLen0+k*N+k*cpLenR + (1:N), :);
    end    
end
% FFT processing
x = step(hFFT, tmp);
% 保持能量不变
x =  x./(N/sqrt(numDataTones));
% For a subframe of data
y = complex(zeros(numDataTones, numSymb, numLayers));
% Reorder, remove DC, Unpack data
% FFTshift
x = [x(N/2+1:N, :, :); x(1:N/2, :, :)];
% 去除掉虚拟子载波等没用的东西
y(1:(numDataTones/2), :, :) = x(N/2-numDataTones/2+1:N/2, :, :);
y(numDataTones/2+1:numDataTones, :, :) = x(N/2+2:N/2+1+numDataTones/2, :, :);