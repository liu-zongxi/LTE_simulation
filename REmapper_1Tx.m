function y = REmapper_1Tx(in, csr, nS, prmLTE, varargin)
%#codegen
switch nargin
    % 只有数据
    case 4, pdcch=[];pss=[];sss=[];bch=[];
    % 正常子帧，要发送控制信道
    case 5, pdcch=varargin{1};pss=[];sss=[];bch=[];
    % 子帧5，有同步信号
    case 6, pdcch=varargin{1};pss=varargin{2};sss=[];bch=[];
    case 7, pdcch=varargin{1};pss=varargin{2};sss=varargin{3};bch=[];
    % 子帧0，有同步信号和BCH
    case 8, pdcch=varargin{1};pss=varargin{2};sss=varargin{3};bch=varargin{4};
    otherwise
        error('REMapper has 4 to 8 arguments!');
end
% NcellID = 0;                                     % One of possible 504 values
% numTx = 1;                                      % prmLTE.numTx;
% Get input params
Nrb = prmLTE.Nrb;                              % either of {6, }
Nrb_sc = prmLTE.Nrb_sc;                 % 12 for normal mode
Ndl_symb = prmLTE.Ndl_symb;         % 7    for normal mode
numContSymb    = prmLTE.contReg;  % DCI占据的符号数，either {1, 2, 3}
% Initialize output buffer
% 第一维是频域，二维是时域
y = complex(zeros(Nrb*Nrb_sc, Ndl_symb*2));
%% Specify resource grid location indices for CSR, PDCCH, PDSCH, PBCH, PSS, SSS
%% 1st: Indices for CSR pilot symbols
lenOFDM = Nrb*Nrb_sc;
idx            = 1:lenOFDM;
% 时隙0和时隙4上的
idx_csr0   = 1:6:lenOFDM;              % More general starting point = 1+mod(NcellID, 6);
idx_csr4   = 4:6:lenOFDM;              % More general starting point = 1+mod(3+NcellID, 6);
% 拼在一起
idx_csr     =[idx_csr0, 4*lenOFDM+idx_csr4, 7*lenOFDM+idx_csr0, 11*lenOFDM+idx_csr4];
%% 2nd: Indices for PDCCH control data symbols
% DCI中剔除CSR
ContREs=numContSymb*lenOFDM;
idx_dci=1:ContREs;
idx_pdcch = ExpungeFrom(idx_dci,idx_csr0);
%% 3rd: Indices for PDSCH and PDSCH data in OFDM symbols whee pilots are present
% 有参考信号的符号的子载波要特殊处理
% 去掉第一类CSR
idx_data0= ExpungeFrom(idx,idx_csr0);
% 去掉第二类CSR
idx_data4 = ExpungeFrom(idx,idx_csr4);
%% Handle 3 types of subframes differently
switch nS
    %% 4th: Indices for BCH, PSS, SSS are only found in specific subframes 0 and 5
    % Thsese symbols share the same 6 center sub-carrier locations (idx_ctr)
    % and differ in OFDM symbol number.
    % 子帧0
    case 0    % Subframe 0
        % PBCH, PSS, SSS are available + CSR, PDCCH, PDSCH
        % 中心的72个
        idx_6rbs = (1:72);
        idx_ctr = 0.5* lenOFDM - 36 + idx_6rbs ;
        % 第五个和第六个OFDM符号
        idx_SSS  = 5* lenOFDM + idx_ctr;
        idx_PSS  = 6* lenOFDM + idx_ctr;
        idx_ctr0 = ExpungeFrom(idx_ctr,idx_csr0);
        % 78910
        idx_bch=[7*lenOFDM + idx_ctr0, 8*lenOFDM + idx_ctr, 9*lenOFDM + idx_ctr, 10*lenOFDM + idx_ctr];
        % 去掉中央子载波
        idx_data5   = ExpungeFrom(idx,idx_ctr);
        % 去掉中央子载波和第一类CSR
        idx_data7 = ExpungeFrom(idx_data0,idx_ctr);
        % 详解每一项
        % 第一项：第四个OFDM符号，上面空空荡荡
        % 第二项：第五个OFDM符号，去掉第二类CSR
        % 第三项：第六个OFDM符号，去掉中间的同步符号
        % 第四项：第七个OFDM符号，去掉中间的同步符号
        % 第五项：第八个OFDM符号，去掉BCH还有第一类CSR
        % 第六项：第九个OFDM符号，去掉BCH
        % 后面的类似
        idx_data   = [ContREs+1:4*lenOFDM,   4*lenOFDM+idx_data4, ...
            5*lenOFDM+idx_data5, 6*lenOFDM+idx_data5,  7*lenOFDM+idx_data7, 8*lenOFDM+idx_data5, ...
            9*lenOFDM+idx_data5, 10*lenOFDM+idx_data5, 11*lenOFDM+idx_data4, ...
            12*lenOFDM+1:14*lenOFDM];
        y(idx_csr)=csr(:);                 % Insert Cell-Specific Reference signal (CSR) = pilots
        y(idx_data)=in;                    % Insert Physical Downlink Shared Channel (PDSCH) = user data
        if ~isempty(pdcch), y(idx_pdcch)=pdcch;end       % Insert Physical Downlink Control Channel (PDCCH)
        if ~isempty(pss), y(idx_PSS)=pss;end                   % Insert Primary Synchronization Signal (PSS)
        if ~isempty(sss), y(idx_SSS)=sss;end                    % Insert Secondary Synchronization Signal (SSS)
        if ~isempty(bch), y(idx_bch)=bch;end                   % Insert Broadcast Cahnnel data (BCH)
    % 子帧5，类似
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
        y(idx_csr)=csr(:);                 % Insert Cell-Specific Reference signal (CSR) = pilots
        y(idx_data)=in;                    % Insert Physical Downlink Shared Channel (PDSCH) = user data
        if ~isempty(pdcch), y(idx_pdcch)=pdcch;end       % Insert Physical Downlink Control Channel (PDCCH)
        if ~isempty(pss), y(idx_PSS)=pss;end                   % Insert Primary Synchronization Signal (PSS)
        if ~isempty(sss), y(idx_SSS)=sss;end                    % Insert Secondary Synchronization Signal (SSS)
    % 普通子帧    
    otherwise % other subframes
        % Only CSR, PDCCH, PDSCH
        idx_data = [ContREs+1:4*lenOFDM, 4*lenOFDM+idx_data4, ...
            5*lenOFDM+1:7*lenOFDM, ...
            7*lenOFDM+idx_data0, ...
            8*lenOFDM+1:11*lenOFDM, ...
            11*lenOFDM+idx_data4, ...
            12*lenOFDM+1:14*lenOFDM];
        y(idx_csr)=csr(:);                 % Insert Cell-Specific Reference signal (CSR) = pilots
        y(idx_data)=in;                    % Insert Physical Downlink Shared Channel (PDSCH) = user data
        if ~isempty(pdcch), y(idx_pdcch)=pdcch;end       % Insert Physical Downlink Control Channel (PDCCH)
end
end