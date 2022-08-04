function [prmLTEPDSCH, prmLTEDLSCH, prmMdl] = commlteSIMO_initialize(chanBW, contReg, modType, ...
    Eqmode,numTx, numRx,cRate,maxIter, fullDecode, chanMdl, corrLvl, ...
    chEstOn, maxNumErrs, maxNumBits)
% Create the parameter structures
% PDSCH and DLSCH
prmLTEPDSCH = prmsPDSCH(chanBW, contReg, modType,numTx, numRx);
prmLTEPDSCH.Eqmode=Eqmode;
prmLTEPDSCH.modType=modType;
prmLTEDLSCH = prmsDLSCH(cRate,maxIter, fullDecode, prmLTEPDSCH);
% Channel parameters
prmMdl.chanMdl = chanMdl;
prmMdl.corrLevel = corrLvl;
prmMdl.chEstOn = chEstOn;
switch modType
    case 1
        snrdBs=[0:4:8, 9:12];
    case 2
        snrdBs=[0:4:12, 13:16];
    otherwise
        snrdBs=[0:4:24];
end
prmMdl.snrdBs=snrdBs;
prmMdl.maxNumBits=maxNumBits;
prmMdl.maxNumErrs=maxNumErrs;