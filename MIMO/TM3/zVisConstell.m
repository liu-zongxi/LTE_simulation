function zVisConstell(prmLTE, yRec, dataRx, nS)
% Constellation Scopes
switch prmLTE.numTx
    case 1
        zVisConstell_1(prmLTE, yRec, dataRx, nS);
    case 2
        zVisConstell_2(prmLTE, yRec, dataRx, nS);
    case 4
        zVisConstell_4(prmLTE, yRec, dataRx, nS);
end
end
%% Case of numTx =1
function zVisConstell_1(prmLTE, yRec, dataRx, nS)
persistent h1 h2
if isempty(h1)
      h1 = comm.ConstellationDiagram('ReferenceConstellation', prmLTE.Constellation,...
        'YLimits', [-2 2], 'XLimits', [-2 2], 'Position', ...
        figposition([5 60 20 25]), 'Name', 'Before Equalizer');
    h2 = comm.ConstellationDiagram('ReferenceConstellation', prmLTE.Constellation,...
        'YLimits', [-2 2], 'XLimits', [-2 2], 'Position', ...
        figposition([6 31 20 25]), 'Name', 'After Equalizer');
     if verLessThan('comm','5.5')
        h1.SymbolsToDisplay=prmLTE.numDataResources;
        h2.SymbolsToDisplay=prmLTE.numDataResources;
     end
end
% Update Constellation Scope
if  (nS~=0 && nS~=10)
    step(h1, dataRx(:,1));
    step(h2, yRec(:,1));
end
end
%% Case of numTx =2
function zVisConstell_2(prmLTE, yRec, dataRx, nS)
persistent h11 h21 h12 h22
if isempty(h11)
   h11 = comm.ConstellationDiagram('ReferenceConstellation', prmLTE.Constellation,...
        'YLimits', [-2 2], 'XLimits', [-2 2], 'Position', ...
        figposition([5 60 20 25]), 'Name', 'Before Equalizer');
    h21 = comm.ConstellationDiagram( 'ReferenceConstellation', prmLTE.Constellation,...
        'YLimits', [-2 2], 'XLimits', [-2 2], 'Position', ...
        figposition([6 31 20 25]), 'Name', 'After Equalizer');
     if verLessThan('comm','5.5')
        h11.SymbolsToDisplay=prmLTE.numDataResources;
        h21.SymbolsToDisplay=prmLTE.numDataResources;
    end
    h12 = clone(h11);
    h22 = clone(h21);
end
% Update Constellation Scope
if  (nS~=0 && nS~=10)
    step(h11, dataRx(:,1));
    step(h21, yRec(:,1));
    step(h12, dataRx(:,2));
    step(h22, yRec(:,2));
end
end
%% Case of numTx =4
function zVisConstell_4(prmLTE, yRec, dataRx, nS)
persistent ha1 hb1 ha2 hb2 ha3 hb3 ha4 hb4
if isempty(ha1)
    ha1 = comm.ConstellationDiagram( 'ReferenceConstellation', prmLTE.Constellation,...
        'YLimits', [-2 2], 'XLimits', [-2 2], 'Position', ...
        figposition([5 60 20 25]), 'Name', 'Before Equalizer');
    hb1 = comm.ConstellationDiagram('ReferenceConstellation', prmLTE.Constellation,...
        'YLimits', [-2 2], 'XLimits', [-2 2], 'Position', ...
        figposition([6 31 20 25]), 'Name', 'After Equalizer');
    if verLessThan('comm','5.5')
        ha1.SymbolsToDisplay=prmLTE.numDataResources;
        hb1.SymbolsToDisplay=prmLTE.numDataResources;
    end
    ha2 = clone(ha1);
    hb2 = clone(hb1);
    ha3 = clone(ha1);
    hb3 = clone(hb1);
    ha4 = clone(ha1);
    hb4 = clone(hb1);
end
% Update Constellation Scope
if  (nS~=0 && nS~=10)
    step(ha1, dataRx(:,1));
    step(hb1, yRec(:,1));
    step(ha2, dataRx(:,2));
    step(hb2, yRec(:,2));
    step(ha3, dataRx(:,3));
    step(hb3, yRec(:,3));
    step(ha4, dataRx(:,4));
    step(hb4, yRec(:,4));
end
end