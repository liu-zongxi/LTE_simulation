function y = zReport_data_rate(p1, p2)
y=(1/10.0e-3)*(p1.TBLenVec(1)+p1.TBLenVec(2)+8*p1.TBLenVec(3));

Mod={'QPSK','16QAM','64QAM'};
fprintf(1,'Modulation = %s\n',Mod{p2.modType});
fprintf(1,'Coding rate = %6.4f \n',p1.cRate);
fprintf(1,'Bandwidth = %6.2f MHz\n',p2.Nrb/5);
fprintf(1,'MIMO Antenna  = %1d x %1d \n',p2.numTx, p2.numRx);
fprintf(1,'Data rate = %6.2f Mbps\n\n',y/1e6);

end

