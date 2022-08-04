% Script for SIMO LTE (mode 1)
%
% Single codeword transmission only,
%
clear all
clear functions
disp('Simulating the LTE Mode 1: Single Tx antenna and multiple Rx antrennas');
%% Set simulation parametrs & initialize parameter structures
commlteSIMO_params;
[prmLTEPDSCH, prmLTEDLSCH, prmMdl] = commlteSIMO_initialize( chanBW, contReg,  modType, ...
    Eqmode, numTx, numRx, cRate,maxIter, fullDecode, chanMdl, corrLvl, ...
    chEstOn, maxNumErrs, maxNumBits);
clear chanBW contReg numTx numRx modType Eqmode cRate maxIter fullDecode chanMdl corrLvl chEstOn maxNumErrs maxNumBits;
%%
hPBer = comm.ErrorRate;
% snrdB=prmMdl.snrdBs(end);
maxNumErrs=prmMdl.maxNumErrs;
maxNumBits=prmMdl.maxNumBits;
%% Simulation loop
nS = 0; % Slot number, one of [0:2:18]
Measures = zeros(3,1); %initialize BER output
while (( Measures(2)< maxNumErrs) && (Measures(3) < maxNumBits))
   [dataIn, dataOut, txSig, rxSig, dataRx, yRec, csr] = ...
       commlteSIMO_step(nS, snrdB, prmLTEDLSCH, prmLTEPDSCH, prmMdl);
    % Calculate  bit errors
    Measures = step(hPBer, dataIn, dataOut);
     % Visualize constellations and spectrum
    if visualsOn, zVisualize( prmLTEPDSCH, txSig, rxSig, yRec, dataRx, csr, nS);end
    % Update subframe number
    nS = nS + 2; if nS > 19, nS = mod(nS, 20); end
end
disp(Measures);