%%
clear;clc;
N_frame = 10000;
% u = randi(1, N_frame,1);
u = ones(N_frame,1);
nS = 1;
SNRs_dB = 3:1:20;   % 信噪比
SNRs = 10.^(SNRs_dB./10);
rng(8);
for itype = 1:2
    sum_error = 0;
    for iSNR = 1:length(SNRs)
        SNR = SNRs(iSNR);
        sigma = sqrt(1/(2*SNR));
        u_scramble = Scrambler(u, nS);
        u_mod = Modulator(u_scramble, 1);
        v = u_mod+sigma*randn(N_frame/2,1);
        if itype == 1
            v_demod = DemodulatorSoft(v, 1, sigma);
            v_descramble = DescramblerSoft(v_demod, nS)
            v = sign(-v_descramble);
            v(find(v == -1)) = 0;
        elseif itype == 2
            v_demod = DemodulatorHard(v, 1);
            v = DescramblerHard(v_demod, nS);
        end
        error = sum(abs(u-v));
        sum_error = sum_error + error;
    end
    sum_error
end
