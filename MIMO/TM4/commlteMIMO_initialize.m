function [prmLTEPDSCH, prmLTEDLSCH, prmMdl] = commlteMIMO_initialize(txMode, ...
chanBW, contReg, modType, Eqmode,numTx, numRx,cRate,maxIter, fullDecode, chanMdl, corrLvl, ...
    chEstOn, numCodeWords, enPMIfback, cbIdx, snrdB, maxNumErrs, maxNumBits)
% Create the parameter structures
% PDSCH parameters
CheckAntennaConfig(numTx, numRx);
prmLTEPDSCH = prmsPDSCH(txMode, chanBW, contReg, modType,numTx, numRx, numCodeWords);
prmLTEPDSCH.Eqmode=Eqmode;
prmLTEPDSCH.modType=modType;
[SymbolMap, Constellation]=ModulatorDetail(modType);
prmLTEPDSCH.SymbolMap=SymbolMap;
prmLTEPDSCH.Constellation=Constellation;
% DLSCH parameters
prmLTEDLSCH = prmsDLSCH(cRate,maxIter, fullDecode, prmLTEPDSCH);
% Channel parameters
chanSRate   = prmLTEPDSCH.chanSRate;
 prmMdl = prmsMdl(txMode, chanSRate,  chanMdl, numTx, numRx, ...
    corrLvl, chEstOn, enPMIfback, cbIdx, snrdB, maxNumErrs, maxNumBits);