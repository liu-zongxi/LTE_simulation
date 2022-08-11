function prmMdl = prmsMdl(chanSRate,  chanMdl, numTx, numRx, ...
    corrLvl, chEstOn, snrdB, maxNumErrs, maxNumBits)
% 首先是确定信道类型
prmMdl.chanMdl = chanMdl;
% ASCII码 几×几
prmMdl.AntConfig=char([48+numTx,'x',48+numRx]);
% 
switch chanMdl
    case 'flat-low-mobility',
        prmMdl.PathDelays = 0*(1/chanSRate);
        prmMdl.PathGains  = 0;
        prmMdl.Doppler=0;
        prmMdl.ChannelType =1;
    case 'flat-high-mobility',
        prmMdl.PathDelays = 0*(1/chanSRate);
        prmMdl.PathGains  = 0;
        prmMdl.Doppler=70;
        prmMdl.ChannelType =1;
    case 'frequency-selective-low-mobility',
        prmMdl.PathDelays = [0 10 20 30 100]*(1/chanSRate);
        prmMdl.PathGains  = [0 -3 -6 -8 -17.2];
        prmMdl.Doppler=0;
        prmMdl.ChannelType =1;
    case 'frequency-selective-high-mobility',
        prmMdl.PathDelays = [0 10 20 30 100]*(1/chanSRate);
        prmMdl.PathGains  = [0 -3 -6 -8 -17.2];
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