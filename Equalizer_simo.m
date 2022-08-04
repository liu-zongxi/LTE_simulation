function [y, num, denum]  = Equalizer_simo(in, hD, nVar, EqMode)
%#codegen
% 这里同时完成了MCR
% MCR就是每个天线各自均衡H*，然后相加
switch EqMode
    case 1   % Zero forcing
       num = conj(hD);
       denum=conj(hD).*hD;            
    case 2   % MMSE
        num = conj(hD);
        denum=conj(hD).*hD+nVar;  
    otherwise
        error('Two equalization mode available: Zero forcing or MMSE');
end
y = sum(in .*num,2)./sum(denum,2);