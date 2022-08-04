% PDSCH
numTx          = 1;    % Number of transmit antennas
numRx          = 4;    % Number of receive antennas
chanBW       = 4;    % Index to chanel bandwidth used [1,....6]
contReg       = 1;    % No. of OFDM symbols dedictaed to control information [1,...,3]
modType      =  2;   % Modulation type [1, 2, 3] for ['QPSK,'16QAM','64QAM']
% DLSCH
cRate            = 1/3; % Rate matching target coding rate 
maxIter         = 6;     % Maximum number of turbo decoding terations  
fullDecode    = 0;    % Whether "full" or "early stopping" turbo decoding is performed
% Channel model
chanMdl        =  'frequency-selective-high-mobility'; 
corrLvl           = 'Low'; 
% Simulation parametrs
Eqmode        = 2;      % Type of equalizer used [1,2] for ['ZF', 'MMSE']
chEstOn        = 1;     % Whether channel estimation is done or ideal channel model used
maxNumErrs = 1e7; % Maximum number of errors found before simulation stops
maxNumBits = 1e7;  % Maximum number of bits processed before simulation stops
visualsOn     = 0;      % Whether to visualize channel response and constellations
snrdB            = 16;   % Value of SNR used in this experiment