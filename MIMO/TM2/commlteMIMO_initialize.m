function [prmLTEPDSCH, prmLTEDLSCH, prmMdl] = commlteMIMO_initialize(txMode, ...
chanBW, contReg, modType, Eqmode,numTx, numRx,cRate,maxIter, fullDecode, chanMdl, corrLvl, ...
    chEstOn, snrdB, maxNumErrs, maxNumBits)
% Create the parameter structures
% PDSCH parameters
% 首先确定MIMO的大小
CheckAntennaConfig(numTx, numRx);
% PDSCH的参数确定
% 这其中主要是OFDM和Mapping还有MIMO的参数
prmLTEPDSCH = prmsPDSCH(txMode, chanBW, contReg, modType,numTx, numRx);
prmLTEPDSCH.Eqmode=Eqmode;
prmLTEPDSCH.modType=modType;
% 显示调制参数
[SymbolMap, Constellation]=ModulatorDetail(modType);
prmLTEPDSCH.SymbolMap=SymbolMap;
prmLTEPDSCH.Constellation=Constellation;
% DLSCH parameters
% DLSCH设置，主要是调制 码率等编码信息
prmLTEDLSCH = prmsDLSCH(cRate,maxIter, fullDecode, prmLTEPDSCH);
% Channel parameters
% 信道种类设置
chanSRate   = prmLTEPDSCH.chanSRate;
 prmMdl = prmsMdl(chanSRate,  chanMdl, numTx, numRx, ...
    corrLvl, chEstOn, snrdB, maxNumErrs, maxNumBits);
