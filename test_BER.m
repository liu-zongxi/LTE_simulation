for EbNo = 1:10
    %% Constants
    maxNumErrs = 100;
    maxNumBits = 1e6;
    nIter = 7;
    FRM=2432;                                           % Size of bit frame
    Indices = lteIntrlvrIndices(FRM);
    M=4;k=log2(M);
    R= FRM/(3* FRM + 4*3);
    snr = EbNo + 10*log10(k) + 10*log10(R);
    noiseVar = 10.^(-snr/10);
    ModulationMode=1;                              % QPSK
    %% Processsing loop modeling transmitter, channel model and receiver
    numErrs = 0; numBits = 0; nS=0;
    while ((numErrs < maxNumErrs) && (numBits < maxNumBits))
        % Transmitter
        u  =  randi([0 1], FRM,1);                                                            % Randomly generated input bits
        t0 = TurboEncoder(u, Indices);                                                   % Turbo Encoder 
        t1 = Scrambler(t0, nS);                                                                % Scrambler
        t2 = Modulator(t1, ModulationMode);                                       % Modulator
        % Channel
        c0 = AWGNChannel(t2, snr);                                                      % AWGN channel
        % Receiver
        r0 = DemodulatorSoft(c0, ModulationMode, noiseVar);            % Demodulator
        r1 = DescramblerSoft(r0, nS);                                                     % Descrambler
        y  = TurboDecoder(-r1, Indices,   nIter);                                     % Turbo Deocder
        % Measurements
        numErrs     = numErrs + sum(y~=u);                                           % Update number of bit errors
        numBits     = numBits + FRM;                                                     % Update number of bits processed
        % Manage slot number with each subframe processed
        nS = nS + 2; nS = mod(nS, 20);
    end
    %% Clean up & collect results
    ber = numErrs/numBits                                          % Compute Bit Error Rate (BER)
end