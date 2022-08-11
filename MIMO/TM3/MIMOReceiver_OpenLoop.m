function y = MIMOReceiver_OpenLoop(in, chEst, prmLTE, nVar)
%#codegen
% 根据信道还有层数解算出接收信号
v=prmLTE.numTx;
switch prmLTE.Eqmode
    case 1 % ZF receiver
        y = MIMOReceiver_ZF_OpenLoop(in, chEst, v);
    case 2 % MMSE receiver
       y = MIMOReceiver_MMSE_OpenLoop(in, chEst, nVar, v);
    case 3 % Sphere Decoder
        y = MIMOReceiver_SD_OpenLoop(in, chEst, prmLTE, nVar, v);
    otherwise
        error('Function MIMOReceiver: ZF, MMSE, Sphere decoder are only supported MIMO detectors');
end
