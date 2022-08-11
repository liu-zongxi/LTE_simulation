function zVisSpectrum(prmLTE, txSig, rxSig, yRec, csr, nS)
% Spectral Analyzers
switch prmLTE.numTx
    case 1
        zVisSpectrum_1(prmLTE, txSig, rxSig, yRec, csr, nS);
    case 2
        zVisSpectrum_2(prmLTE, txSig, rxSig, yRec, csr, nS);
    case 4
        zVisSpectrum_4(prmLTE, txSig, rxSig, yRec, csr, nS);
end
end
%% Case of numTx = 1
function zVisSpectrum_1(prmLTE, txSig, rxSig, yRec, csr, nS)
persistent hSpecAnalyzer
if isempty(hSpecAnalyzer)
    hSpecAnalyzer = dsp.SpectrumAnalyzer('SampleRate',  prmLTE.chanSRate, ...
        'SpectrumType', 'Power density', 'PowerUnits', 'dBW', ...
        'RBWSource', 'Property',   'RBW', 15000,...
        'FrequencySpan', 'Span and center frequency',...
        'Span',  prmLTE.BW, 'CenterFrequency', 0,...
        'SpectralAverages', 10, ...
        'Title', 'Transmitted & Received Signal Spectrum', 'YLimits', [-110 -60],...
        'YLabel', 'PSD');
end
yRecGrid = REmapper_mTx(yRec, csr, nS, prmLTE);
yRecGridSig = OFDMTx(yRecGrid, prmLTE);
step(hSpecAnalyzer, ...
    [SymbSpec(txSig(:,1), prmLTE), SymbSpec(rxSig(:,1), prmLTE), SymbSpec(yRecGridSig(:,1), prmLTE)]);
end
%% Case of numTx = 2
function zVisSpectrum_2(prmLTE, txSig, rxSig, yRec, csr, nS)
persistent hSpec1 hSpec2
if isempty(hSpec1)
    hSpec1 = dsp.SpectrumAnalyzer('SampleRate',  prmLTE.chanSRate, ...
        'SpectrumType', 'Power density', 'PowerUnits', 'dBW', ...
        'RBWSource', 'Property',   'RBW', 15000,...
        'FrequencySpan', 'Span and center frequency',...
        'Span',  prmLTE.BW, 'CenterFrequency', 0,...
        'SpectralAverages', 10, ...
        'Title', 'Transmitted & Received Signal Spectrum', 'YLimits', [-110 -60],...
        'YLabel', 'PSD');
    hSpec2 = clone(hSpec1);
end
yRecGrid = REmapper_mTx(yRec, csr, nS, prmLTE);
yRecGridSig = OFDMTx(yRecGrid, prmLTE);
step(hSpec1, ...
    [SymbSpec(txSig(:,1), prmLTE), SymbSpec(rxSig(:,1), prmLTE), SymbSpec(yRecGridSig(:,1), prmLTE)]);
step(hSpec2, ...
    [SymbSpec(txSig(:,2), prmLTE), SymbSpec(rxSig(:,2), prmLTE), SymbSpec(yRecGridSig(:,2), prmLTE)]);
end
%% Case of numTx = 4
function zVisSpectrum_4(prmLTE, txSig, rxSig, yRec, csr, nS)
persistent hSpec1 hSpec2 hSpec3 hSpec4
if isempty(hSpec1)
    hSpec1 = dsp.SpectrumAnalyzer('SampleRate',  prmLTE.chanSRate, ...
        'SpectrumType', 'Power density', 'PowerUnits', 'dBW', ...
        'RBWSource', 'Property',   'RBW', 15000,...
        'FrequencySpan', 'Span and center frequency',...
        'Span',  prmLTE.BW, 'CenterFrequency', 0,...
        'SpectralAverages', 10, ...
        'Title', 'Transmitted & Received Signal Spectrum', 'YLimits', [-110 -60],...
        'YLabel', 'PSD');
    hSpec2 = clone(hSpec1);
    hSpec3 = clone(hSpec1);
    hSpec4 = clone(hSpec1);
end
yRecGrid = REmapper_mTx(yRec, csr, nS, prmLTE);
yRecGridSig = OFDMTx(yRecGrid, prmLTE);
step(hSpec1, ...
    [SymbSpec(txSig(:,1), prmLTE), SymbSpec(rxSig(:,1), prmLTE), SymbSpec(yRecGridSig(:,1), prmLTE)]);
step(hSpec2, ...
    [SymbSpec(txSig(:,2), prmLTE), SymbSpec(rxSig(:,2), prmLTE), SymbSpec(yRecGridSig(:,2), prmLTE)]);
step(hSpec3, ...
    [SymbSpec(txSig(:,3), prmLTE), SymbSpec(rxSig(:,3), prmLTE), SymbSpec(yRecGridSig(:,3), prmLTE)]);
step(hSpec4, ...
    [SymbSpec(txSig(:,4), prmLTE), SymbSpec(rxSig(:,4), prmLTE), SymbSpec(yRecGridSig(:,4), prmLTE)]);
end
%% Helper function
function y = SymbSpec(in, prmLTE)
N = prmLTE.N;
cpLenR = prmLTE.cpLen0;
y = complex(zeros(N+cpLenR, 1));
% Use the first Tx/Rx antenna of the input for the display
y(:,1) = in(end-(N+cpLenR)+1:end, 1);
end