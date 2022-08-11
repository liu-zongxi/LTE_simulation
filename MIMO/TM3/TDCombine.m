function y = TDCombine(in, chEst, numTx, numRx)
% LTE transmit diversity combining
%   SFBC and SFBC with FSTD.
persistent hTDDec;
% 为什么只设置2*2的呢，因为即使是4天线也是两个2天线组成的
% 接收具体是如何实现的呢
% function s = Alamouti_Combiner1(u,H)
% %#codegen
% % STBC_DEC STBC Combiner
% % Outputs the recovered symbol vector
% LEN=size(u,1);
% Nr=size(u,2);
% BlkSize=2;
% % 2个为一组
% NoBlks=LEN/BlkSize;
% % Initialize outputs
% h=complex(zeros(1,2));
% s=complex(zeros(LEN,1));
% % Alamouti code for 2 Tx
% indexU=(1:BlkSize);
% for m=1:NoBlks
% t_hat=complex(zeros(BlkSize,1));
% h_norm=0.0;
% % 一个天线一个天线来接受
% for n=1:Nr
% % 一次使用两个时间的即h1和h2
% h(:)=H(2*m-1,:,n);
% % 代表着能量
% h_norm=h_norm+real(h*h');
% r=u(indexU,n);
% r(2)=conj(r(2));
% % 分子
% shat=[conj(h(1)), h(2); conj(h(2)), -h(1)]*r;
% t_hat=t_hat+shat;
% end
% s(indexU)=t_hat/h_norm; % Maximum-likelihood combining
% indexU=indexU+BlkSize;
% end
% end
if isempty(hTDDec)
    % OSTBC combiner - always numTx = 2
    hTDDec = comm.OSTBCCombiner('NumTransmitAntennas', 2, ...
        'NumReceiveAntennas', numRx);
end
inLen = size(in, 1);
Index=(2:2:inLen)';
switch numTx
    case 1
        y=in;
    case 2   % For 2TX - SFBC
        % 恢复本来大小
        in = sqrt(2) * in; % Scale
        y = step(hTDDec, in,chEst);
        % ST to SF transformation.
        % Apply blockwise correction for 2nd symbol combining
        % 恢复成SFBC
        y(Index) = -conj(y(Index));
    case 4   % For 4Tx - SFBC with FSTD
        in = sqrt(2) * in; % Scale
        H = complex(zeros(inLen, 2, numRx));
        idx12 = ([1:4:inLen; 2:4:inLen]); idx12 = idx12(:);
        idx34 = ([3:4:inLen; 4:4:inLen]); idx34 = idx34(:);
        % 找到对应的信道
        H(idx12, :, :) = chEst(idx12, [1 3], :);
        H(idx34, :, :) = chEst(idx34, [2 4], :);
        y = step(hTDDec, in, H);
        % ST to SF transformation.
        % Apply blockwise correction for 2nd symbol combining
        % 恢复成SFBC
        y(Index) = -conj(y(Index));
end

