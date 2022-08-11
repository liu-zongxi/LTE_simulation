function y = REmapper_mTx(in, csr, nS, prmLTE, varargin)
% in是一个（numData,numTx）的矩阵
% csr是一个(numCSR,4,numTX)的矩阵，4是因为一个子帧有四个符号会有CSR
%#codegen
switch nargin
    % 不同子帧内的情况
    case 4, pdcch=[];pss=[];sss=[];bch=[];
    case 5, pdcch=varargin{1};pss=[];sss=[];bch=[];
    case 6, pdcch=varargin{1};pss=varargin{2};sss=[];bch=[];
    case 7, pdcch=varargin{1};pss=varargin{2};sss=varargin{3};bch=[];
    case 8, pdcch=varargin{1};pss=varargin{2};sss=varargin{3};bch=varargin{4};
    otherwise
        error('REMapper has 4 to 8 arguments!');
end
% NcellID = 0;                                               % One of possible 504 values
% Get input params
% 获得基本参数信息
numTx                 = prmLTE.numTx;              % Number of transmit antennas
Nrb                      = prmLTE.Nrb;                   % either of {6, }
Nrb_sc                = prmLTE.Nrb_sc;              % 12 for normal mode
Ndl_symb           = prmLTE.Ndl_symb;         % 7    for normal mode
numContSymb    = prmLTE.contReg;            % either {1, 2, 3}
%% Specify resource grid location indices for CSR, PDCCH, PDSCH, PBCH, PSS, SSS
% 区分出基本的DCI区域和数据区域，之后再一一区分
% idxdata是可变的
coder.varsize('idx_data');
lenOFDM = Nrb*Nrb_sc;
ContREs=numContSymb*lenOFDM;
idx_dci=1:ContREs;
lenGrid= lenOFDM * Ndl_symb*2;
idx_data  = ContREs+1:lenGrid;
%% 1st: Indices for CSR pilot symbols
% 有两种不同的CSR符号
idx_csr0   = 1:6:lenOFDM;              % More general starting point = 1+mod(NcellID, 6);
idx_csr4   = 4:6:lenOFDM;              % More general starting point = 1+mod(3+NcellID, 6);
% Depends on number of transmit antennas
switch numTx
    % 单发射天线情况
    case 1
        % CSR在一个子帧中的位置
        idx_csr      = [idx_csr0, 4*lenOFDM+idx_csr4, 7*lenOFDM+idx_csr0, 11*lenOFDM+idx_csr4];
        % data区域去除CSR
        idx_data   = ExpungeFrom(idx_data,idx_csr);
        % DCI区域去除CSR
        idx_pdcch = ExpungeFrom(idx_dci,idx_csr0);
        % BCH中的CSR
        idx_ex       = 7.5* lenOFDM - 36 + (1:6:72);
        % IDX每两个个数据代表着每一根天线的天线开始和结束idx
        a=numel(idx_csr); IDX=[1, a];
    % 二发射天线
    case 2
        % 看书上的图，分别对应两个天线的CSR分布
        idx_csr1     = [idx_csr0, 4*lenOFDM+idx_csr4, 7*lenOFDM+idx_csr0, 11*lenOFDM+idx_csr4];
        idx_csr2     = [idx_csr4, 4*lenOFDM+idx_csr0, 7*lenOFDM+idx_csr4, 11*lenOFDM+idx_csr0];
        idx_csr       = [idx_csr1, idx_csr2];
        % Exclude pilots and NULLs
        % 从data中摘出CSR
        idx_data    = ExpungeFrom(idx_data,idx_csr1);
        idx_data    = ExpungeFrom(idx_data,idx_csr2);
        % DCI区域去除CSR
        idx_pdcch  = ExpungeFrom(idx_dci,idx_csr0);
        idx_pdcch  = ExpungeFrom(idx_pdcch,idx_csr4);
        % BCH中的CSR
        idx_ex        = 7.5* lenOFDM - 36 + (1:3:72);     
        % Point to pilots only
        % IDX每两个个数据代表着每一根天线的天线开始和结束idx
        a=numel(idx_csr1); IDX=[1, a; a+1, 2*a];  
    % 四天线情况
    case 4
        % 看书，12天线和两天先类似
        idx_csr1     = [idx_csr0, 4*lenOFDM+idx_csr4, 7*lenOFDM+idx_csr0, 11*lenOFDM+idx_csr4];
        idx_csr2     = [idx_csr4, 4*lenOFDM+idx_csr0, 7*lenOFDM+idx_csr4, 11*lenOFDM+idx_csr0];
        % 4 5 天线的CSR更少
        idx_csr33   = [lenOFDM+idx_csr0, 8*lenOFDM+idx_csr4];     
        idx_csr44   = [lenOFDM+idx_csr4, 8*lenOFDM+idx_csr0];
        idx_csr       = [idx_csr1, idx_csr2, idx_csr33, idx_csr44];
        % Exclude pilots and NULLs
        idx_data    = ExpungeFrom(idx_data,idx_csr1);
        idx_data    = ExpungeFrom(idx_data,idx_csr2);
        idx_data    = ExpungeFrom(idx_data,idx_csr33);
        idx_data    = ExpungeFrom(idx_data,idx_csr44);
        % From pdcch
        % 注意DCI部分只有1，2符号上有可能有CSR
        idx_pdcch  = ExpungeFrom(idx_dci,idx_csr0);
        idx_pdcch  = ExpungeFrom(idx_pdcch,idx_csr4); 
        idx_pdcch  = ExpungeFrom(idx_pdcch,lenOFDM+idx_csr0);
        idx_pdcch  = ExpungeFrom(idx_pdcch,lenOFDM+idx_csr4);
        % BCH中的CSR
        idx_ex        = [7.5* lenOFDM - 36 + (1:3:72), 8.5* lenOFDM - 36 + (1:3:72)];
        % Point to pilots only
        a=numel(idx_csr1); b=numel(idx_csr33);
        % IDX每两个个数据代表着每一根天线的天线开始和结束idx
        IDX =[1, a; a+1, 2*a; 2*a+1, 2*a+b; 2*a+b+1, 2*a+2*b];
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
        idx_ctr = 0.5* lenOFDM - 36 + (1:72) ;
        idx_SSS  = 5* lenOFDM + idx_ctr;
        idx_PSS  = 6* lenOFDM + idx_ctr;
        idx_bch0=[7*lenOFDM + idx_ctr, 8*lenOFDM + idx_ctr, 9*lenOFDM + idx_ctr, 10*lenOFDM + idx_ctr];
        % 在BCH中删掉CSR
        idx_bch = ExpungeFrom(idx_bch0,idx_ex);
        % data中删掉BCH
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
% Initialize output buffer
y = complex(zeros(Nrb*Nrb_sc, Ndl_symb*2, numTx));
for m=1:numTx
    grid = complex(zeros(Nrb*Nrb_sc, Ndl_symb*2));
    % 放入该天线的数据
    grid(idx_data.')=in(:,m);                                              % Insert user data
    % 找到属于该天线的CSR
    Range=idx_csr(IDX(m,1):IDX(m,2)).';                          % How many pilots in this antenna
    % csr按理来说应该直接放进对应的idx中，但是由于四天线34天线的特殊情况
    csr_flat=packCsr(csr, m, numTx);                              % Pack correct number of CSR values
    % 放置进去
    grid(Range)=  csr_flat(:);                                             % Insert CSR pilot symbols
    if ~isempty(pdcch), grid(idx_pdcch)=pdcch(:,m);end  % Insert Physical Downlink Control Channel (PDCCH)
    if ~isempty(pss),     grid(idx_PSS)=pss(:,m);end          % Insert Primary Synchronization Signal (PSS)
    if ~isempty(sss),     grid(idx_SSS)=sss(:,m);end           % Insert Secondary Synchronization Signal (SSS)
    if ~isempty(bch),     grid(idx_bch)=bch(:,m);end          % Insert Broadcast Cahnnel data (BCH)
    y(:,:,m)=grid;
end
end
%% Helper function
% 34 的特殊情况就是别人有4个符号而这里还有2个符号，所以只取出1 3
function  csr_flat=packCsr(csr,  m, numTx)                          
    if ((numTx==4)&&(m>2))                                              % Handle special case of 4Tx 
       csr_flat=csr(:,[1,3],m);                                               % Extract pilots in this antenna
    else
        csr_flat=csr(:,:,m);
    end
end