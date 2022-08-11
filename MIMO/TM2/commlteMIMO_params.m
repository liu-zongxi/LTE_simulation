% PDSCH
txMode         = 2;   % Transmisson mode one of {1, 2, 4}     
numTx          = 2;    % Number of transmit antennas
numRx          = 2;    % Number of receive antennas
chanBW       = 4;    % Index to chanel bandwidth used [1,....6]
contReg       = 2;    % No. of OFDM symbols dedictaed to control information [1,...,3]
modType      =  2;   % Modulation type [1, 2, 3] for ['QPSK,'16QAM','64QAM']
% DLSCH
cRate            = 1/3; % Rate matching target coding rate 
maxIter         = 6;     % Maximum number of turbo decoding terations  
fullDecode    = 0;    % Whether "full" or "early stopping" turbo decoding is performed
% Channel model
chanMdl        = 'flat-high-mobility'; 
% one of {'flat-low-mobility', 'flat-high-mobility','frequency-selective-low-mobility',
% 'frequency-selective-high-mobility', 'EPA 0Hz', 'EPA 5Hz', 'EVA 5Hz', 'EVA 70Hz'}
corrLvl           = 'Low'; 
% Simulation parametrs
Eqmode        = 2;      % Type of equalizer used [1,2] for ['ZF', 'MMSE']
chEstOn        = 1;     % One of [0,1,2,3] for 'Ideal estimator','Interpolation',Slot average','Subframe average'
snrdB            = 16;   % Signal to Noise ratio
maxNumErrs = 1e6; % Maximum number of errors found before simulation stops
maxNumBits = 1e6;  % Maximum number of bits processed before simulation stops
visualsOn     = 1;      % Whether to visualize channel response and constellations