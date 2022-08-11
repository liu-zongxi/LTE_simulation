function out = TDEncode(in, numTx)
%   Both SFBC and SFBC with FSTD
persistent hTDEnc;
if isempty(hTDEnc)
    % Use same object for either scheme
    hTDEnc = comm.OSTBCEncoder('NumTransmitAntennas', 2);
end
switch numTx
    case 1
        out=in;
    case 2 % SFBC
        % 为了公用Alamouti的代码，把第二个符号取负共轭
        in((2:2:end).') = -conj(in((2:2:end).'));
        % STBC Alamouti
        y= step(hTDEnc, in);       
        % Scale
        out = y/sqrt(2);
    case 4
        inLen=size(in,1);
        y = complex(zeros(inLen, 4));
        % 同样的操作，STBC到SFBC的转换
        in((2:2:end).') = -conj(in((2:2:end).'));
        % 取出一二两根天线，然后又是使用matlab的特性把他们两交织在一起
        % 这个在之前插值中已经使用过此技巧了
        % idx12的序列是1 2 5 6 9 10...
        % 这最终会被映射到13天线
        idx12 = ([1:4:inLen; 2:4:inLen]); idx12 = idx12(:);
        % 34天线
        % 映射到24天线
        idx34 = ([3:4:inLen; 4:4:inLen]); idx34 = idx34(:);
        % 进行STBC
        y(idx12, [1 3]) = step(hTDEnc, in(idx12));
        y(idx34, [2 4]) = step(hTDEnc, in(idx34));
        out = y/sqrt(2);
end