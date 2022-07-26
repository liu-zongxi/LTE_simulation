%------------------------Gold扰码解扰-----------------------%
%------------------------author:lzx-------------------------%
%-----------------------date:2022年6月21日14点30分-----------------%
function y = DescramblerSoft(u, nS)
%   Downlink descrambling 
% 这里的软解扰是针对之前的软解调说的，而不是针对加扰，输入是LLR则输出也是LLR
persistent hSeqGen hInt2Bit;
if isempty(hSeqGen)
    maxG=43200;
    hSeqGen = comm.GoldSequence('FirstPolynomial',[1 zeros(1, 27) 1 0 0 1],...
                                'FirstInitialConditions', [zeros(1, 30) 1], ...
                                'SecondPolynomial', [1 zeros(1, 27) 1 1 1 1],...
                                'SecondInitialConditionsSource', 'Input port',... 
                                'Shift', 1600,...
                                'VariableSizeOutput', true,...
                                'MaximumOutputSize', [maxG 1]);
    % hInt2Bit = comm.IntegerToBit('BitsPerInteger', 31);
end
% Parameters to compute initial condition
RNTI = 1; 
NcellID = 0;
q=0;
% Initial conditions
c_init = RNTI*(2^14) + q*(2^13) + floor(nS/2)*(2^9) + NcellID;
% Convert to binary vector
% iniStates = step(hInt2Bit, c_init);
iniStates = int2bit(c_init, 31);
% Generate scrambling sequence
nSamp = size(u, 1);
seq = step(hSeqGen, iniStates, nSamp);
seq2=zeros(size(u));
seq2(:)=seq(1:numel(u),1);
% If descrambler inputs are log-likelihood ratios (LLRs) then 
% Convert sequence to a bipolar format
% 变换一下符号，0变1，1变-1
seq2 = 1-2.*seq2;    
% Descramble
% 即结果是，如果本身加扰是0，则不发生变化
% 如果加扰是1，则会被反向，即0变1，1变0
% 在LLR中，本身就是大于0表示1，小于0表示0
% 可以看到这样和异或的结果是相同的
% 即他仍然保留了软解调的大小差异
y = u.*seq2;