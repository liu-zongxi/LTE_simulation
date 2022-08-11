%------------------------CSR生成函数-----------------------%
%-----------------------author:lzx-------------------------%
%-----------------------date:2022年7月28日11点39分-----------------%
function y = CSRgenerator(nS, numTx)
%  LTE Cell-Specific Reference signal generation.
%   Section 6.10.1 of 3GPP TS 36.211 v10.0.0.
%   Generate the whole set per OFDM symbol, for 2 OFDM symbols per slot,
%   for 2 slots per subframe, per antenna port (numTx). 
%   This fcn accounts for the per antenna port sequence generation, while
%   the actual mapping to resource elements is done in the Resource mapper.
%#codegen
persistent hSeqGen;
% persistent hInt2Bit;
% Assumed parameters
NcellID = 0;        % 小区的PCI共504个
Ncp = 1;            % CP类型for normal CP, or 0 for Extended CP
NmaxDL_RB = 100;    % 最大RB个数largest downlink bandwidth configuration, in resource blocks
% 注意这里的四维数组，第一个是频域的，第二个是符号，第三个是时隙，第四个是时隙
y = complex(zeros(NmaxDL_RB*2, 2, 2, numTx));
% 小区参考信号只会出现在每个时隙的第0 号和第4 号OFDM 符号上
l = [0; 4];     % OFDM symbol idx in a slot for common first antenna port
% Buffer for sequence per OFDM symbol
% 复数输出
seq = zeros(size(y,1)*2, 1); % *2 for complex outputs
if isempty(hSeqGen)
    % 这里移动了1600，详见LTE教程
    hSeqGen = comm.GoldSequence('FirstPolynomial',[1 zeros(1, 27) 1 0 0 1],...
                                'FirstInitialConditions', [zeros(1, 30) 1], ...
                                'SecondPolynomial', [1 zeros(1, 27) 1 1 1 1],...
                                'SecondInitialConditionsSource', 'Input port',... 
                                'Shift', 1600,...
                                'SamplesPerFrame', length(seq));
    % hInt2Bit = comm.IntegerToBit('BitsPerInteger', 31);
end
% Generate the common first antenna port sequences
for i = 1:2 % slot wise
    for lIdx = 1:2 % symbol wise
        c_init = (2^10)*(7*((nS+i-1)+1)+l(lIdx)+1)*(2*NcellID+1) + 2*NcellID + Ncp;
        % Convert to binary vector
        iniStates = int2bit(c_init, 31);
        % iniStates = step(hInt2Bit, c_init);
        % Scrambling sequence - as per Section 7.2, 36.211
        seq = step(hSeqGen, iniStates);
        % Store the common first antenna port sequences
        % 这其实是QPSK调制
        y(:, lIdx, i, 1) = (1/sqrt(2))*complex(1-2.*seq(1:2:end), 1-2.*seq(2:2:end));
    end
end
% Copy the duplicate set for second antenna port, if exists
% 双天线的位置是一样的，见LTE教程
if (numTx>1)
    y(:, :, :, 2) = y(:, :, :, 1);
end
% Also generate the sequence for l=1 index for numTx = 4
% 四天线第二个符号也是参考信号了
if (numTx>2)
    for i = 1:2 % slot wise
        % l = 1
        c_init = (2^10)*(7*((nS+i-1)+1)+1+1)*(2*NcellID+1) + 2*NcellID + Ncp;
        % Convert to binary vector
        % iniStates = step(hInt2Bit, c_init);
        iniStates = int2bit(c_init, 31);
        % Scrambling sequence - as per Section 7.2, 36.211
        seq = step(hSeqGen, iniStates); 
        % Store the third antenna port sequences
        y(:, 1, i, 3) = (1/sqrt(2))*complex(1-2.*seq(1:2:end), 1-2.*seq(2:2:end));
    end
    % Copy the duplicate set for fourth antenna port
    y(:, 1, :, 4) = y(:, 1, :, 3);
end