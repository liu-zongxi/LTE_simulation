function data = genPayload_HZ(nS,  outLenVec)
% Generate the data payload per subframe.
% Due to the varying overheads the output length of the payload can vary
% with the slot number, which varies from [0, 19].

%#codegen

% Extract parameters
outLen = max(outLenVec);

switch nS
    case 0
        outLen = outLenVec(1);
        
    case 10
        outLen = outLenVec(2);
    otherwise
       outLen = outLenVec(3); 
end

data = logical(randi( [0 1], outLen, 1));

% [EOF]