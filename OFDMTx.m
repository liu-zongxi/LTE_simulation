%------------------------OFDM-----------------------%
%-----------------------author:lzx-------------------------%
%-----------------------date:2022年7月28日17点13分-----------------%
function y = OFDMTx(in, prmLTE)
%#codegen
persistent hIFFT;
if isempty(hIFFT)
    hIFFT = dsp.IFFT;
end
[len, numSymb, numLayers] = size(in);
% N assumes 15KHz subcarrier spacing
N = prmLTE.N; % NFFT
cpLen0 = prmLTE.cpLen0;
cpLenR = prmLTE.cpLenR;
% 一个时隙的长度
slotLen = (N*7 + cpLen0 + cpLenR*6);
subframeLen = slotLen*2;  
tmp = complex(zeros(N, numSymb, numLayers));
% Pack data, add DC, and reorder
% fftshift
tmp(N/2-len/2+1:N/2, :, :) = in(1:len/2, :, :);
% 注意是+2，中间加一个DC
tmp(N/2+2:N/2+1+len/2, :, :) = in(len/2+1:len, :, :);
tmp = [tmp(N/2+1:N, :, :); tmp(1:N/2, :, :)];
% IFFT processing
x = step(hIFFT, tmp);
% 保持能量一致
x = x.*(N/sqrt(len));
% Add cyclic prefix per OFDM symbol per antenna port 
% and serialize over the subframe (equal to 2 slots)
% For a subframe of data
y = complex(zeros(subframeLen, numLayers));
for j = 1:2 % Over the two slots
    % First OFDM symbol
    % 添加CP，每个时隙第一个是扩展CP
    y((j-1)*slotLen+(1:cpLen0), :) = x((N-cpLen0+1):N, (j-1)*7+1, :);
    y((j-1)*slotLen+cpLen0+(1:N), :) = x(1:N, (j-1)*7+1, :);

    % Next 6 OFDM symbols
    % 添加其他的CP
    for k = 1:6
        y((j-1)*slotLen+cpLen0+k*N+(k-1)*cpLenR+(1:cpLenR), :) = x(N-cpLenR+1:N, (j-1)*7+k+1, :);
        y((j-1)*slotLen+cpLen0+k*N+k*cpLenR+(1:N), :) = x(1:N, (j-1)*7+k+1, :);
    end
end