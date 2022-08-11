% Script for MIMO LTE (mode 3)
%
% Single  codeword transmission
%
clear all
clear functions
%% Set simulation parametrs & initialize parameter structures
copyfile('commlteMIMO_params_TM3_2CodeWords_QAM16.m','commlteMIMO_params.m');
commlteMIMO_params;
[prmLTEPDSCH, prmLTEDLSCH, prmMdl] = commlteMIMO_initialize(txMode, ...
chanBW, contReg, modType, Eqmode,numTx, numRx,cRate,maxIter, fullDecode, chanMdl, corrLvl, ...
    chEstOn, numCodeWords, snrdB, maxNumErrs, maxNumBits);
clear txMode chanBW contReg modType Eqmode numTx numRx cRate maxIter fullDecode chanMdl corrLvl chEstOn numCodeWords snrdB maxNumErrs maxNumBits
%%
disp('Simulating the LTE Mode 3: Multiple Tx & Rx antrennas with open loop Spatial Multiplexing');
zReport_data_rate(prmLTEDLSCH, prmLTEPDSCH); 
hPBer = comm.ErrorRate;
snrdB=prmMdl.snrdB;
maxNumErrs=prmMdl.maxNumErrs;
maxNumBits=prmMdl.maxNumBits;
%% Simulation loop
tic;
nS = 0; % Slot number, one of [0:2:18]
Measures = zeros(3,1); %initialize BER output
while (( Measures(2)< maxNumErrs) && (Measures(3) < maxNumBits))
   [dataIn, dataOut, txSig, rxSig, dataRx, yRec, csr] = ...
       commlteMIMO_SM2_Mode3_step(nS, snrdB, prmLTEDLSCH, prmLTEPDSCH, prmMdl);
    % Calculate  bit errors
    Measures = step(hPBer, dataIn, dataOut);
     % Visualize constellations and spectrum
    if (visualsOn && prmLTEPDSCH.Eqmode~=3)
        zVisualize( prmLTEPDSCH, txSig, rxSig, yRec, dataRx, csr, nS); 
    end
    % Update subframe number
    nS = nS + 2; if nS > 19, nS = mod(nS, 20); end
end
disp(Measures);
toc;