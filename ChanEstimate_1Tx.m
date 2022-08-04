function hD = ChanEstimate_1Tx(prmLTE, Rx, Ref, Mode)
%#codegen
Nrb           = prmLTE.Nrb;     % Number of resource blocks
Nrb_sc      = prmLTE.Nrb_sc;                 % 12 for normal mode
Ndl_symb = prmLTE.Ndl_symb;        % 7    for normal mode
numRx = prmLTE.numRx;
% Assume same number of Tx and Rx antennas = 1
% Initialize output buffer
% 信道矩阵和子载波矩阵大小是一致的,但这里添加了一维numRX
hD = complex(zeros(Nrb*Nrb_sc, Ndl_symb*2,numRx));
% Estimate channel based on CSR - per antenna port
% 操作都是在一个子帧内，这样一分，就获得了05712四个位置的CSR
csrRx = reshape(Rx, numel(Rx)/(4*numRx), 4, numRx); % Align received pilots with reference pilots
for n=1:numRx
    % 这就是CSR的估计结果了
    hp= csrRx(:,:,n)./Ref;                  % Just divide received pilot by reference pilot
    % to obtain channel response at pilot locations
    % Now use some form of averaging/interpolation/repeating to
    % compute channel response for the whole grid
    % Choose one of 3 estimation methods "average" or "interpolate" or "hybrid"
    switch Mode
        case 'average'
            tmp=gridResponse_averageSubframe(hp, Nrb, Nrb_sc, Ndl_symb);
        case 'interpolate'
            tmp=gridResponse_interpolate(hp, Nrb, Nrb_sc, Ndl_symb);
        case 'hybrid'
            tmp=gridResponse_averageSlot(hp, Nrb, Nrb_sc, Ndl_symb);
        otherwise
            error('Choose the right mode for function ChanEstimate.');
    end
    hD(:,:,n)=tmp;
end





