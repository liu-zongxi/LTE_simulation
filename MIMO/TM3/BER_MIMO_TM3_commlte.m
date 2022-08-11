% Script for MIMO LTE (mode 3)
%
% Single codeword transmission only
%
clear all
clear functions
%% Set simulation parametrs & initialize parameter structures
copyfile('commlteMIMO_params_TM3_2CodeWords_QAM16.m','commlteMIMO_params.m');
commlteMIMO_params;
maxNumErrs=1e5; 
maxNumBits=1e7;
[prmLTEPDSCH, prmLTEDLSCH, prmMdl] = commlteMIMO_initialize(txMode, ...
chanBW, contReg, modType, Eqmode,numTx, numRx,cRate,maxIter, fullDecode, chanMdl, corrLvl, ...
    chEstOn, numCodeWords, snrdB, maxNumErrs, maxNumBits);
clear txMode chanBW contReg modType Eqmode numTx numRx cRate maxIter fullDecode chanMdl corrLvl chEstOn numCodeWords snrdB maxNumErrs maxNumBits
%%
disp('Simulating the LTE Mode 3: Multiple Tx & Rx antrennas with open loop Spatial Multiplexing');
zReport_data_rate(prmLTEDLSCH, prmLTEPDSCH);
%%
MaxIter=6;
snr_vector=getSnrVector(prmLTEPDSCH.modType, MaxIter);
ber_vector=zeros(size(snr_vector));
maxNumBits=prmMdl.maxNumBits;
tic;
for n=1:MaxIter
    fprintf(1,'Iteration %2d out of %2d:  Processing %10d bits. SNR = %3d\n', ...
        n, MaxIter, prmMdl.maxNumBits, snr_vector(n));
    hPBer = comm.ErrorRate;
    snrdB = snr_vector(n);
maxNumErrs=1e5; 
maxNumBits=1e7;
    %% Simulation loop
    nS = 0; % Slot number, one of [0:2:18]
    Measures = zeros(3,1); %initialize BER output
    while (( Measures(2)< maxNumErrs) && (Measures(3) < maxNumBits))
        [dataIn, dataOut, txSig, rxSig, dataRx, yRec, csr] = ...
            commlteMIMO_SM2_Mode3_step(nS, snrdB, prmLTEDLSCH, prmLTEPDSCH, prmMdl);
        % Calculate  bit errors
        Measures = step(hPBer, dataIn, dataOut);
        % Visualize constellations and spectrum
        if visualsOn
            zVisualize( prmLTEPDSCH, txSig, rxSig, yRec, dataRx, csr, nS);
        end;
        fprintf(1,'Bits processed %8d ; Errors found %5d BER = %g \r', Measures(3), Measures(2), Measures(1));
        % Update subframe number
        nS = nS + 2; if nS > 19, nS = mod(nS, 20); end;
    end
    ber=Measures(1);
    ber_vector(n)=ber;
    disp(ber_vector);
end;
toc;
semilogy(snr_vector, ber_vector);
title('BER performance of transmission mode 4 as a function of SNR');
legend('QPSK, 1/3 turbo coding, 10 MHz BW');
xlabel('SNR (dB)');ylabel('BER');grid;