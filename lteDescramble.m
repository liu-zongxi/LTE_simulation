function y = lteDescramble(u, nS, q, maxG)
%LTEDESCRAMBLE Downlink descrambling of the PDSCH.
%   Based on Section 6.3.1 of 3GPP TS 36.211 v10.0.0.

%   Copyright 2012 The MathWorks, Inc.

%#codegen
persistent hSeqGen;
% persistent hInt2Bit;

nSamp = size(u, 1);
if isempty(hSeqGen)
    hSeqGen = comm.GoldSequence('FirstPolynomial',[1 zeros(1, 27) 1 0 0 1],...
                                'FirstInitialConditions', [zeros(1, 30) 1], ...
                                'SecondPolynomial', [1 zeros(1, 27) 1 1 1 1],...
                                'SecondInitialConditionsSource', 'Input port',... 
                                'Shift', 1600,...
                                'VariableSizeOutput', true,...
                                'MaximumOutputSize', [maxG 1]);
    % hInt2Bit = comm.IntegerToBit('BitsPerInteger', 31);
end

% Assumed parameters
RNTI = 1; NcellID = 0;

% Initial conditions
c_init = RNTI*(2^14) + q*(2^13) + floor(nS/2)*(2^9) + NcellID;

% Convert to binary vector
% iniStates = step(hInt2Bit, c_init);
iniStates = int2bit(c_init, 31);
% Generate scrambling sequence
seq = step(hSeqGen, iniStates, nSamp);
seq = 1-2.*seq;     % convert to bipolar format based on negative mapping

% Descramble
y = u(:,1).*seq(:,1);

% [EOF]
