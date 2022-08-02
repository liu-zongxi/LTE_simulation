function [data, csr, idx_data, pdcch, pss, sss, bch] = REdemapper_1Tx(in, nS, prmLTE)
%#codegen
% NcellID = 0;                                     % One of possible 504 values
% numTx = 1;                                      % prmLTE.numTx;
% Get input params
Nrb = prmLTE.Nrb;                              % either of {6, }
Nrb_sc = prmLTE.Nrb_sc;                 % 12 for normal mode
numContSymb    = prmLTE.contReg;  % either {1, 2, 3}
%% Specify resource grid location indices for CSR, PDCCH, PDSCH, PBCH, PSS, SSS
%% 1st: Indices for CSR pilot symbols
% 生成第一类和第二类CSR
lenOFDM = Nrb*Nrb_sc;
idx            = 1:lenOFDM;
idx_csr0   = 1:6:lenOFDM;              % More general starting point = 1+mod(NcellID, 6);
idx_csr4   = 4:6:lenOFDM;              % More general starting point = 1+mod(3+NcellID, 6);
idx_csr     =[idx_csr0, 4*lenOFDM+idx_csr4, 7*lenOFDM+idx_csr0, 11*lenOFDM+idx_csr4];
%% 2nd: Indices for PDCCH control data symbols
% 放置DCI的位置
ContREs=numContSymb*lenOFDM;
idx_dci=1:ContREs;
idx_pdcch = ExpungeFrom(idx_dci,idx_csr0);
%% 3rd: Indices for PDSCH and PDSCH data in OFDM symbols whee pilots are present
idx_data0= ExpungeFrom(idx,idx_csr0);
idx_data4 = ExpungeFrom(idx,idx_csr4);
%% Handle 3 types of subframes differently
pss=complex(zeros(72,1));
sss=complex(zeros(72,1));
bch=complex(zeros(72*4,1));
switch nS
    %% 4th: Indices for BCH, PSS, SSS are only found in specific subframes 0 and 5
    % Thsese symbols share the same 6 center sub-carrier locations (idx_ctr)
    % and differ in OFDM symbol number.
    case 0    % Subframe 0
        % PBCH, PSS, SSS are available + CSR, PDCCH, PDSCH
        idx_6rbs = (1:72);
        idx_ctr = 0.5* lenOFDM - 36 + idx_6rbs ;
        idx_SSS  = 5* lenOFDM + idx_ctr;
        idx_PSS  = 6* lenOFDM + idx_ctr;
        idx_ctr0 = ExpungeFrom(idx_ctr,idx_csr0);
        idx_bch=[7*lenOFDM + idx_ctr0, 8*lenOFDM + idx_ctr, 9*lenOFDM + idx_ctr, 10*lenOFDM + idx_ctr];
        idx_data5   = ExpungeFrom(idx,idx_ctr);
        idx_data7 = ExpungeFrom(idx_data0,idx_ctr);
        idx_data   = [ContREs+1:4*lenOFDM,   4*lenOFDM+idx_data4, ...
            5*lenOFDM+idx_data5, 6*lenOFDM+idx_data5,  7*lenOFDM+idx_data7, 8*lenOFDM+idx_data5, ...
            9*lenOFDM+idx_data5, 10*lenOFDM+idx_data5, 11*lenOFDM+idx_data4, ...
            12*lenOFDM+1:14*lenOFDM];
        pss=in(idx_PSS.');    % Primary Synchronization Signal (PSS)
        sss=in(idx_SSS.');     % Secondary Synchronization Signal (SSS)
        bch=in(idx_bch.');    % Broadcast Cahnnel data (BCH)
        
    case 10  % Subframe 5
        % PSS, SSS are available + CSR, PDCCH, PDSCH
        % Primary ans Secondary synchronization signals in OFDM symbols 5 and 6
        idx_6rbs = (1:72);
        idx_ctr = 0.5* lenOFDM - 36 + idx_6rbs ;
        idx_SSS  = 5* lenOFDM + idx_ctr;
        idx_PSS  = 6* lenOFDM + idx_ctr;
        idx_data5 = ExpungeFrom(idx,idx_ctr);
        idx_data   = [ContREs+1:4*lenOFDM, 4*lenOFDM+idx_data4,  5*lenOFDM+idx_data5, 6*lenOFDM+idx_data5, ...
            7*lenOFDM+idx_data0, 8*lenOFDM+1:11*lenOFDM,  11*lenOFDM+idx_data4, ...
            12*lenOFDM+1:14*lenOFDM];
        pss=in(idx_PSS.');     % Primary Synchronization Signal (PSS)
        sss=in(idx_SSS.');      % Secondary Synchronization Signal (SSS)
        
    otherwise % other subframes
        % Only CSR, PDCCH, PDSCH
        idx_data = [ContREs+1:4*lenOFDM, 4*lenOFDM+idx_data4, ...
            5*lenOFDM+1:7*lenOFDM, ...
            7*lenOFDM+idx_data0, ...
            8*lenOFDM+1:11*lenOFDM, ...
            11*lenOFDM+idx_data4, ...
            12*lenOFDM+1:14*lenOFDM];
end
idx_data=idx_data.';
data=in(idx_data);       % Physical Downlink Shared Channel (PDSCH) = user data
csr=in(idx_csr.');            % Cell-Specific Reference signal (CSR) = pilots
pdcch = in(idx_pdcch.');   % Physical Downlink Control Channel (PDCCH)