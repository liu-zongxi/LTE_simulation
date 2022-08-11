function y = CRCgenerator(data)
%#codegen
% Transport block CRC generation
persistent hTBCRCGen
if isempty(hTBCRCGen)
    hTBCRCGen = comm.CRCGenerator('Polynomial', [1 1 0 0 0 0 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 1 0 1 1]);
end
y = step(hTBCRCGen, data);