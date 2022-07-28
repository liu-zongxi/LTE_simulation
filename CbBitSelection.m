%------------------------找到分块后每块的长度-----------------------%
%-----------------------author:lzx-------------------------%
%-----------------------date:2022年7月2日20点50分-----------------%
function E = CbBitSelection(C, G, Nl, Qm)
%#codegen
% Bit selection parameters
% G = total number of output bits
% Nl   Number of layers a TB is mapped to (Rel10)
% Qm    modulation bits
Gprime = G/(Nl*Qm);
gamma = mod(Gprime, C);
E=zeros(C,1);
% Rate matching with bit selection
% 余数以下的小一点，大于的大一点
% 详见博客，这样一定恰好分完
% 比如分成24组，余数是13，那么前13多分一个，后面的少分一个，就刚好分完了
for cbIdx=1:C
        if ((cbIdx-1) <= (C-1-gamma))
            E(cbIdx) = Nl*Qm*floor(Gprime/C);
        else
             E(cbIdx)   = Nl*Qm*ceil(Gprime/C);
        end       
end
    