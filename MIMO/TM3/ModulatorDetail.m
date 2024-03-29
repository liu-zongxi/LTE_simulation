function [SymMap, Constellation]=ModulatorDetail(Mode)
% 这个函数的作用是看一下当前使用的调制模式，而不是直接用于调制了
%% Initialization
persistent QPSK QAM16 QAM64
if isempty(QPSK)
    QPSK          = comm.PSKModulator(4, 'BitInput', true, ...
        'PhaseOffset', pi/4, 'SymbolMapping', 'Custom', ...
        'CustomSymbolMapping', [0 2 3 1]); 
    QAM16      = comm.RectangularQAMModulator(16, 'BitInput',true,...
        'NormalizationMethod','Average power',...
        'SymbolMapping', 'Custom', ...
        'CustomSymbolMapping', [11 10 14 15 9 8 12 13 1 0 4 5 3 2 6 7]);
    QAM64      = comm.RectangularQAMModulator(64, 'BitInput',true,...
        'NormalizationMethod','Average power',...
        'SymbolMapping', 'Custom', ...
        'CustomSymbolMapping', [47 46 42 43 59 58 62 63 45 44 40 41 ...
        57 56 60 61 37 36 32 33 49 48 52 53 39 38 34 35 51 50 54 55 7 ...
        6 2 3 19 18 22 23 5 4 0 1 17 16 20 21 13 12 8 9 25 24 28 29 15 ...
        14 10 11 27 26 30 31]);
end
%% Processing
switch Mode
    case 1
        Constellation=constellation(QPSK);
        SymMap = QPSK.CustomSymbolMapping;
    case 2
        Constellation=constellation(QAM16);
        SymMap = QAM16.CustomSymbolMapping;
    case 3
        Constellation=constellation(QAM64);
        SymMap = QAM64.CustomSymbolMapping;
    otherwise
        error('Invalid Modulation Mode. Use {1,2, or 3}');
end