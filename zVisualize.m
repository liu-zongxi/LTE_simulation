function zVisualize(prmLTE, txSig, rxSig, yRec, dataRx, csr, nS)
% Constellation Scopes & Spectral Analyzers
persistent hScope1 hScope2 hSpecAnalyzer
if isempty(hSpecAnalyzer)
    % Constellation Diagrams
    hScope1 = comm.ConstellationDiagram('ShowReferenceConstellation', false,...
        'YLimits', [-2 2], 'XLimits', [-2 2], 'Position', ...
        figposition([5 60 20 25]), 'Name', 'Before Equalizer');
    hScope2 = comm.ConstellationDiagram( 'ShowReferenceConstellation', false,...
        'YLimits', [-2 2], 'XLimits', [-2 2], 'Position', ...
        figposition([6 21 20 25]), 'Name', 'After Equalizer');
    if verLessThan('comm','5.5')
        hScope1.SymbolsToDisplay=prmLTE.numDataResources;
        hScope2.SymbolsToDisplay=prmLTE.numDataResources;
    end
    % Spectrum Scope
    hSpecAnalyzer = dsp.SpectrumAnalyzer('SampleRate',  prmLTE.chanSRate, ...
        'SpectrumType', 'Power density', 'PowerUnits', 'dBW', ...
        'RBWSource', 'Property',   'RBW', 15000,...
        'FrequencySpan', 'Span and center frequency',...
        'Span',  prmLTE.BW, 'CenterFrequency', 0,...
        'SpectralAverages', 10, ...
        'Title', 'Transmitted & Received Signal Spectrum', 'YLimits', [-110 -60],...
        'YLabel', 'PSD');
end
% Update Spectrum scope
% Received signal after equalization
yRecGrid = REmapper_1Tx(yRec, csr, nS, prmLTE);
yRecGridSig = OFDMTx(yRecGrid, prmLTE);
% Take certain symbols off a subframe only
step(hSpecAnalyzer, ...
    [SymbSpec(txSig, prmLTE), SymbSpec(rxSig, prmLTE), SymbSpec(yRecGridSig, prmLTE)]);
% Update Constellation Scope
if  (nS~=0 && nS~=10)
    step(hScope1, dataRx(:, 1));
    step(hScope2, yRec(:, 1));
end
end

function y = SymbSpec(in, prmLTE)
N = prmLTE.N;
cpLenR = prmLTE.cpLen0;
y = complex(zeros(N+cpLenR, 1));
% Use the first Tx/Rx antenna of the input for the display
y(:,1) = in(end-(N+cpLenR)+1:end, 1);
end