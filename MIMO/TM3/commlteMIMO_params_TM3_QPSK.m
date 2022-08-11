% PDSCH
txMode             = 4;   % Transmisson mode one of {1, 2, 4}     
numTx              = 2;    % Number of transmit antennas
numRx              = 2;    % Number of receive antennas
chanBW            = 4;         % [1,2,3,4,5,6] maps to [1.4, 3, 5, 10, 15, 20]MHz
contReg            = 1;         % {1,2,3} for >=10MHz, {2,3,4} for <10Mhz
modType           = 1;         % [1,2,3] maps to ['QPSK','16QAM','64QAM']
numCodeWords  = 1;   % Number of codewords in PDSCH
% DLSCH
cRate                = 1/3;  % Rate matching target coding rate 
maxIter              = 6;     % Maximum number of turbo decoding terations  
fullDecode         = 0;     % Whether "full" or "early stopping" turbo decoding is performed
% Channel 
% chanMdl             =  'flat-high-mobility';  
chanMdl             =    'frequency-selective-high-mobility';  
% one of {'flat-low-mobility', 'flat-high-mobility','frequency-selective-low-mobility',
% 'frequency-selective-high-mobility', 'EPA 0Hz', 'EPA 5Hz', 'EVA 5Hz', 'EVA 70Hz'}
corrLvl                 = 'Low'; 
enPMIfback    = 0;     % Enable/Disable Precoder Matrix Indicator (PMI) feedback
cbIdx               = 1;      % Initialize PMI index
% Simulation parametrs
Eqmode           = 2;      % Type of equalizer used [1,2,3] for ['ZF', 'MMSE','Sphere Decoder']
chEstOn           = 1;          % use channel estimation or ideal channel
snrdB                = 16;    % Signal to Noise Ratio in dB
maxNumErrs     = 1e5; % Maximum number of errors found before simulation stops
maxNumBits     = 5e7;  % Maximum number of bits processed before simulation stops
visualsOn          = 0;      % Whether to visualize channel response and constellations