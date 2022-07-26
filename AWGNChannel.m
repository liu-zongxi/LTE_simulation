%------------------------添加AWGN噪声-----------------------%
%-----------------------author:lzx-------------------------%
%-----------------------date:2022年6月27日10点55分-----------------%
function y = AWGNChannel(u, EbNo )
%% Initialization
persistent AWGN
if isempty(AWGN)
    AWGN             = comm.AWGNChannel;
end
AWGN.EbNo=EbNo;
y=AWGN.step(u);
end

