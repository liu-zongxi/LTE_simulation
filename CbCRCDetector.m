function  y = CbCRCDetector(u)
%#codegen
persistent hTBCRC
if isempty(hTBCRC)
    hTBCRC = comm.CRCDetector('Polynomial',  [1 1 zeros(1, 16) 1 1 0 0 0 1 1]);
end
% Transport block CRC generation
y = step(hTBCRC, u);