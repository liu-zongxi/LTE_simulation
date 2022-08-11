function [data, csr, idx_data, pdcch, pss, sss, bch] = REdemapper_mTx(in, nS, prmLTE)
%#codegen
% NcellID = 0;                                     % One of possible 504 values
% Get input params
% 一些基本的参数设置
numTx                 = prmLTE.numTx;              % number of receive antennas
numRx                 = prmLTE.numRx;              % number of receive antennas
Nrb                      = prmLTE.Nrb;                    % either of {6,...,100 }
Nrb_sc                 = prmLTE.Nrb_sc;              % 12 for normal mode
Ndl_symb            = prmLTE.Ndl_symb;         % 7    for normal mode
numContSymb     = prmLTE.contReg;            % either {1, 2, 3}
Npss                    = prmLTE.numPSSRE;
Nsss                    = prmLTE.numSSSRE;
Nbch                   = prmLTE.numBCHRE;
%% Specify resource grid location indices for CSR, PDCCH, PDSCH, PBCH, PSS, SSS
coder.varsize('idx_data');
coder.varsize('idx_dataC');
lenOFDM = Nrb*Nrb_sc;
ContREs=numContSymb*lenOFDM;
idx_dci=1:ContREs;
lenGrid= lenOFDM * Ndl_symb*2;
idx_data  = ContREs+1:lenGrid;
%% 1st: Indices for CSR pilot symbols
idx_csr0   = 1:6:lenOFDM;              % More general starting point = 1+mod(NcellID, 6);
idx_csr4   = 4:6:lenOFDM;              % More general starting point = 1+mod(3+NcellID, 6);
% Depends on number of transmit antennas
switch numTx
    % 单天线
    case 1
        idx_csr      = [idx_csr0, 4*lenOFDM+idx_csr4, 7*lenOFDM+idx_csr0, 11*lenOFDM+idx_csr4];
        idx_data   = ExpungeFrom(idx_data,idx_csr);
        idx_pdcch = ExpungeFrom(idx_dci,idx_csr0);
        idx_ex       = 7.5* lenOFDM - 36 + (1:6:72);
    % 二天线
    case 2
        idx_csr1     = [idx_csr0, 4*lenOFDM+idx_csr4, 7*lenOFDM+idx_csr0, 11*lenOFDM+idx_csr4];
        idx_csr2     = [idx_csr4, 4*lenOFDM+idx_csr0, 7*lenOFDM+idx_csr4, 11*lenOFDM+idx_csr0];
        idx_csr       = [idx_csr1, idx_csr2];
        % Exclude pilots and NULLs
        idx_data    = ExpungeFrom(idx_data,idx_csr1);
        idx_data    = ExpungeFrom(idx_data,idx_csr2);  
        idx_pdcch  = ExpungeFrom(idx_dci,idx_csr0);
        idx_pdcch  = ExpungeFrom(idx_pdcch,idx_csr4);
        idx_ex        = 7.5* lenOFDM - 36 + (1:3:72);                                  
    % 四天线
    case 4
        idx_csr1     = [idx_csr0, 4*lenOFDM+idx_csr4, 7*lenOFDM+idx_csr0, 11*lenOFDM+idx_csr4];
        idx_csr2     = [idx_csr4, 4*lenOFDM+idx_csr0, 7*lenOFDM+idx_csr4, 11*lenOFDM+idx_csr0];
        idx_csr33   = [lenOFDM+idx_csr0, 8*lenOFDM+idx_csr4];     
        idx_csr44   = [lenOFDM+idx_csr4, 8*lenOFDM+idx_csr0];
        idx_csr       = [idx_csr1, idx_csr2, idx_csr33, idx_csr44];
        % Exclude pilots and NULLs
        idx_data    = ExpungeFrom(idx_data,idx_csr1);
        idx_data    = ExpungeFrom(idx_data,idx_csr2);
        idx_data    = ExpungeFrom(idx_data,idx_csr33);
        idx_data    = ExpungeFrom(idx_data,idx_csr44);
        % From pdcch
        idx_pdcch  = ExpungeFrom(idx_dci,idx_csr0);
        idx_pdcch  = ExpungeFrom(idx_pdcch,idx_csr4); 
        idx_pdcch  = ExpungeFrom(idx_pdcch,lenOFDM+idx_csr0);
        idx_pdcch  = ExpungeFrom(idx_pdcch,lenOFDM+idx_csr4);
        idx_ex        = [7.5* lenOFDM - 36 + (1:3:72), 8.5* lenOFDM - 36 + (1:3:72)];
    otherwise
        error('Number of transmit antennnas must be {1, 2, or 4}');
end
%% 3rd: Indices for PDSCH and PDSCH data in OFDM symbols whee pilots are present
%% Handle 3 types of subframes differently
switch nS
    %% 4th: Indices for BCH, PSS, SSS are only found in specific subframes 0 and 5
    % Thsese symbols share the same 6 center sub-carrier locations (idx_ctr)
    % and differ in OFDM symbol number.
    case 0    % Subframe 0
        % PBCH, PSS, SSS are available + CSR, PDCCH, PDSCH
        % 都一样就不说了
        idx_ctr = 0.5* lenOFDM - 36 + (1:72) ;
        idx_SSS  = 5* lenOFDM + idx_ctr;
        idx_PSS  = 6* lenOFDM + idx_ctr;
        idx_bch0=[7*lenOFDM + idx_ctr, 8*lenOFDM + idx_ctr, 9*lenOFDM + idx_ctr, 10*lenOFDM + idx_ctr];
        idx_bch = ExpungeFrom(idx_bch0,idx_ex);
        idx_data   =  ExpungeFrom(idx_data,[idx_SSS, idx_PSS, idx_bch]);
    case 10  % Subframe 5
        % PSS, SSS are available + CSR, PDCCH, PDSCH
        % Primary ans Secondary synchronization signals in OFDM symbols 5 and 6
        idx_ctr = 0.5* lenOFDM - 36 + (1:72) ;
        idx_SSS  = 5* lenOFDM + idx_ctr;
        idx_PSS  = 6* lenOFDM + idx_ctr;
        idx_data   =  ExpungeFrom(idx_data,[idx_SSS, idx_PSS]);
    otherwise % other subframes
        % Nothing to do
end
%% Write user data PDCCH, PBCH, PSS, SSS, CSR
% 这里的东西都是按接收天线一个个存放的
pss=complex(zeros(Npss,numRx));
sss=complex(zeros(Nsss,numRx));
bch=complex(zeros(Nbch,numRx));
pdcch = complex(zeros(numel(idx_pdcch),numRx));
data=complex(zeros(numel(idx_data),numRx));
idx_dataC=idx_data.';
% 接收机肯定是遍历接收天线
for n=1:numRx
    % 一个个天线来
    grid=in(:,:,n);
    % 取出data
    data(:,n)=grid(idx_dataC);                               % Physical Downlink Shared Channel (PDSCH) = user data
    pdcch(:,n) = grid(idx_pdcch.');                       % Physical Downlink Control Channel (PDCCH)
    if nS==0
        pss(:,n)=grid(idx_PSS.');                             % Primary Synchronization Signal (PSS)
        sss(:,n)=grid(idx_SSS.');                             % Secondary Synchronization Signal (SSS)
        bch(:,n)=grid(idx_bch.');                            % Broadcast Cahnnel data (BCH)
    elseif nS==10
        pss(:,n)=grid(idx_PSS.');                             % Primary Synchronization Signal (PSS)
        sss(:,n)=grid(idx_SSS.');                              % Secondary Synchronization Signal (SSS)
    end
end
%% Cell-specifc Reference Signal (CSR) = pilots
% 发射天线数量不同，接收CSR的位置也不同
switch numTx
    % 一个发射天线
    case 1                                                            % Case of 1 Tx
        % CSR分别是一列2个，四列，接收天线
        csr=complex(zeros(2*Nrb,4,numRx));        % 4 symbols have CSR  per Subframe
        for n=1:numRx
            grid=in(:,:,n);
            % 取出改接收天线的CSR
            csr(:,:,n)=reshape(grid(idx_csr'), 2*Nrb,4) ;
        end
    % 两个发射天线
    case 2                                                            % Case of 2 Tx
        idx_0=(1:3:lenOFDM);                             % Total number of Nulls + CSR are constant
        idx_all=[idx_0,  4*lenOFDM+idx_0, 7*lenOFDM+idx_0,  11*lenOFDM+idx_0]';
         % CSR分别是一列4个，四列，接收天线
        csr=complex(zeros(4*Nrb,4,numRx));       % 4 symbols have CSR+NULLs  per Subframe
        for n=1:numRx
            grid=in(:,:,n);
            csr(:, :,n)=reshape(grid(idx_all), 4*Nrb,4) ;
        end
    case 4
        idx_0=(1:3:lenOFDM);                             % Total number of Nulls + CSR are constant
        idx_all=[idx_0,                       lenOFDM+idx_0,      4*lenOFDM+idx_0, ...
            7*lenOFDM+idx_0,  8*lenOFDM+idx_0,  11*lenOFDM+idx_0]';
        csr=complex(zeros(4*Nrb,6,numRx));       % 4 symbols have CSR+NULLs  per Subframe
        for n=1:numRx
            grid=in(:,:,n);
            csr(:, :,n)=reshape(grid(idx_all), 4*Nrb,6) ;
        end
end
end