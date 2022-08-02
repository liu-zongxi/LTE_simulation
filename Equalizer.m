function [out, Eq]  = Equalizer(in, hD, nVar, EqMode)
% 根据我浅薄的知识这也是不对的
%#codegen
switch EqMode
    case 1
       Eq = ( conj(hD))./((conj(hD).*hD));            % Zero forcing
    case 2
        Eq = ( conj(hD))./((conj(hD).*hD)+nVar);  % MMSE
    otherwise
        error('Two equalization mode vaible: Zero forcing or MMSE');
end
out=in.*Eq;