function [y, err] = CRCdetector(data)
%#codegen
% Transport block CRC generation
persistent hTBCRCDet 
if isempty(hTBCRCDet )
    hTBCRCDet = comm.CRCDetector('Polynomial',  [1 1 0 0 0 0 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 1 0 1 1]);
end
[y, err] = step(hTBCRCDet, data);