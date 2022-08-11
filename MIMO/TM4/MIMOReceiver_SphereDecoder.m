function [y, bittable] = MIMOReceiver_SphereDecoder(in, chEst, prmLTE, nVar, Wn)
%#codegen
% MIMO Receiver:
%   Based on received channel estimates, process the data elements
%   to equalize the MIMO channel. Uses the Sphere detector.
% Soft-Sphere Decoder
symMap=prmLTE.SymbolMap;
numBits=prmLTE.Qm;
constell=prmLTE.Constellation;
bittable = de2bi(symMap, numBits, 'left-msb');
iWn=Wn.';
nVar1=(-1/mean(nVar));
persistent SphereDec
if isempty(SphereDec)
    % Soft-Sphere Decoder    
    SphereDec = comm.SphereDecoder('Constellation', constell,...
        'BitTable', bittable, 'DecisionType', 'Soft');
end
% SSD receiver
temp = complex(zeros(size(chEst)));
% Account for precoding
for n = 1:size(chEst,1)
    temp(n, :, :) = iWn * squeeze(chEst(n, :, :));
end
hD = temp;
y = nVar1 * step(SphereDec, in, hD);