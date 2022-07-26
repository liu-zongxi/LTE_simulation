function  y = CbCRCGenerator(u)
%#codegen
persistent hTBCRCGen
if isempty(hTBCRCGen)
    hTBCRCGen = comm.CRCGenerator('Polynomial',[1 1 zeros(1, 16) 1 1 0 0 0 1 1]);
end
% Transport block CRC generation
y = step(hTBCRCGen, u);