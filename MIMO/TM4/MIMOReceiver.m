function y = MIMOReceiver(in, chEst, prmLTE, nVar, Wn)
%#codegen
switch prmLTE.Eqmode
    case 1 % ZF receiver
        y = MIMOReceiver_ZF(in, chEst, Wn);
    case 2 % MMSE receiver
       y = MIMOReceiver_MMSE(in, chEst, nVar, Wn);
    case 3 % Sphere Decoder
        y = MIMOReceiver_SphereDecoder(in, chEst, prmLTE, nVar, Wn);
    otherwise
        error('Function MIMOReceiver: ZF, MMSE, Sphere decoder are only supported MIMO detectors');
end
