function y = ChanModelFading(in, Chan)
%#codegen
% Get simulation params
numTx=1;
numRx=1;
chanSRate = Chan.chanSRate;
PathDelays = Chan.PathDelays;
PathGains  = Chan.PathGains;
Doppler      = Chan.DopplerShift;
% Initialize objects
persistent chanObj
if isempty(chanObj)
    chanObj = comm.MIMOChannel(...
        'SampleRate', chanSRate, ...
        'MaximumDopplerShift', Doppler, ...
        'PathDelays', PathDelays,...
        'AveragePathGains', PathGains,...
        'TransmitCorrelationMatrix', eye(numTx),...
        'ReceiveCorrelationMatrix', eye(numRx),...
        'PathGainsOutputPort', false,...
        'NormalizePathGains', true,...
        'NormalizeChannelOutputs', true);
end
y = step(chanObj, in);
