function prmMdl = prmsMdl(txMode, chanSRate,  chanMdl, numTx, numRx, ...
    corrLvl, chEstOn, enPMIfback, cbIdx, snrdB, maxNumErrs, maxNumBits)
prmMdl.chanMdl = chanMdl;
prmMdl.AntConfig=char([48+numTx,'x',48+numRx]);
switch chanMdl
    case 'flat-low-mobility',
        prmMdl.PathDelays = 0;
        prmMdl.PathGains  = 0;
        prmMdl.Doppler=0;
        prmMdl.ChannelType =1;
    case 'flat-high-mobility',
        prmMdl.PathDelays = 0;
        prmMdl.PathGains  = 0;
        prmMdl.Doppler=70;
        prmMdl.ChannelType =1;
    case 'frequency-selective-low-mobility',
        prmMdl.PathDelays = (0:1:4)*(1.0e-06);
        prmMdl.PathGains  = [0 -4 -8 -12 -16];
        prmMdl.Doppler=1;
        prmMdl.ChannelType =1;
    case 'frequency-selective-high-mobility',
        prmMdl.PathDelays = (0:1:4)*(1.0e-06);
        prmMdl.PathGains  = [0 -4 -8 -12 -16];
        prmMdl.Doppler=70;
        prmMdl.ChannelType =1;
    case 'EPA 0Hz'
        prmMdl.PathDelays = [0 30 70 90 110 190 410]*1e-9;
        prmMdl.PathGains  = [0 -1 -2 -3 -8 -17.2 -20.8];
        prmMdl.Doppler=0;
        prmMdl.ChannelType =1;
    otherwise
        prmMdl.PathDelays = 0*(1/chanSRate);
        prmMdl.PathGains  = 0;
        prmMdl.Doppler=0;
        prmMdl.ChannelType =2;
end
prmMdl.corrLevel = corrLvl;
prmMdl.chEstOn = chEstOn;
prmMdl.snrdB=snrdB;
prmMdl.maxNumBits=maxNumBits;
prmMdl.maxNumErrs=maxNumErrs;
if (txMode==4) % Spatial multiplexing
    prmMdl.enPMIfback = enPMIfback;
    prmMdl.cbIdx = cbIdx;
end