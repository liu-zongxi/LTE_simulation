function [y, csrRx] = lteExtData(in, nS, prmLTEPDSCH, varargin)
%#codegen

% varargin{1} = 'data' for data extraction, default - not needed as input
% varargin{1} = 'chan' for channel extraction when h is given as input

% Copyright 2012 The MathWorks, Inc.

%Inverse of the resource element mapper
%   use it to extract the data elements and supporting elements for further
%   Rx processing.
%   Assumes NcellID = 0;

% Get input params
Nrb = prmLTEPDSCH.Nrb;              % = 100 for 20 MHz
Nrb_sc = prmLTEPDSCH.Nrb_sc;        % = 12
numContSymb    = prmLTEPDSCH.contReg;   % control region, numOFDM symbols
numTx = prmLTEPDSCH.numTx;  
numRx = prmLTEPDSCH.numRx;  

if (nargin==3)
    mode = 'data';
else
    mode = varargin{1};
end
    
%% Determine the data element indices in the input grid
%   Assuming only CSR and data in the incoming grid
%       account for PDCCH, PBCH, PSS, SSS later
% 首先找出非CSR的位置，对于多天线一个RB中有4个，单天线是两个
if (numTx>1) % for 2, 4    
    %   Per OFDM symbol is common for numTx = 2, 4
    dtIdx_OFDMSym_wCsr = zeros((Nrb_sc-4), Nrb);
    for i = 1:Nrb
        % 一列中就是这些可以放数据
        dtIdx_OFDMSym_wCsr(:, i) = [2;3;5;6;8;9;11;12]+12*(i-1);
    end
    dtIdx_OFDMSym_wCsrCol = dtIdx_OFDMSym_wCsr(:);
else % for 1
    % Only 2 reference symbols per RB
    dtIdx_OFDMSym_wCsr = zeros((Nrb_sc-2), Nrb);
    dtIdx_OFDMSym2_wCsr = zeros((Nrb_sc-2), Nrb);
    for i = 1:Nrb
        % 一列中就是这些可以放数据
        % 单天线有两种不同的情况
        dtIdx_OFDMSym_wCsr(:, i) = [2:6 8:12].'+12*(i-1);
        dtIdx_OFDMSym2_wCsr(:, i) = [1:3 5:9 11:12].'+12*(i-1);
    end
    dtIdx_OFDMSym_wCsrCol = dtIdx_OFDMSym_wCsr(:);
    dtIdx_OFDMSym2_wCsrCol = dtIdx_OFDMSym2_wCsr(:);
end
lenOFDM = dtIdx_OFDMSym_wCsrCol(end);
dtIdx_OFDMSym = (1:lenOFDM).';    

if (numTx==1)
    % Slot filling specific to numTx = 1
    % 一个时隙内可以放数据的idx，这是单天线的情况
    dtIdx_slot = [dtIdx_OFDMSym_wCsrCol; dtIdx_OFDMSym+lenOFDM; ...
                  dtIdx_OFDMSym+2*lenOFDM; dtIdx_OFDMSym+3*lenOFDM;...
                  dtIdx_OFDMSym2_wCsrCol+4*lenOFDM;...
                  dtIdx_OFDMSym+5*lenOFDM; dtIdx_OFDMSym+6*lenOFDM];    
elseif (numTx==2)
    % Slot filling specific to numTx = 2
    % 一个时隙内可以放数据的idx
    dtIdx_slot = [dtIdx_OFDMSym_wCsrCol; dtIdx_OFDMSym+lenOFDM; ...
                  dtIdx_OFDMSym+2*lenOFDM; dtIdx_OFDMSym+3*lenOFDM;...
                  dtIdx_OFDMSym_wCsrCol+4*lenOFDM;...
                  dtIdx_OFDMSym+5*lenOFDM; dtIdx_OFDMSym+6*lenOFDM];    
elseif (numTx==4)
    % Slot filling specific to numTx = 4
    % 一个时隙内可以放数据的idx
    dtIdx_slot = [dtIdx_OFDMSym_wCsrCol; dtIdx_OFDMSym_wCsrCol+lenOFDM; ...
                  dtIdx_OFDMSym+2*lenOFDM; dtIdx_OFDMSym+3*lenOFDM;...
                  dtIdx_OFDMSym_wCsrCol+4*lenOFDM;...
                  dtIdx_OFDMSym+5*lenOFDM; dtIdx_OFDMSym+6*lenOFDM];    
end
lenSlot = dtIdx_slot(end);
% 一个子帧内可以放数据的idx
dtIdx_subframe = [dtIdx_slot; dtIdx_slot+lenSlot];

%% 
% Account for PDCCH - remove the data idxes for these RE - in all subframes
% 删除掉放控制信号的idx，这些也是不能放data 的
numContRE = numContSymb * Nrb * Nrb_sc;
dtIdx_subframe(dtIdx_subframe <= numContRE) = [];

% PBCH, PSS, SSS share the same center sub-carrier locations
%   they differ in the OFDM symbol number in the slots/subframe
% 找出中心idx
idx = (0:71).';
centerReIdx = idx - 36 + Nrb*Nrb_sc/2;
PSSReIdx = centerReIdx + lenOFDM*6;
SSSReIdx = centerReIdx + lenOFDM*5;
PBCHStrIdx = ones(4,1); 
switch nS
    case {0}
        % Account for PBCH - first 4 symbols in slot 1
        for i = 1:4
            % 生成BCH的idx还有起始idx
            PBCHReIdx = centerReIdx+lenSlot+(i-1)*lenOFDM;
            PBCHStrIdx(i) = find(dtIdx_subframe==PBCHReIdx(1));
        end
        if (numTx==1)
            % Account for CSR only
            % temp是需要多少个RB
            temp = reshape(idx, [], Nrb_sc);
            temp2 = temp(1:5, :);
            idx2 = temp2(:);
            % In reverse order - 4th, 3rd, 2nd symbols of slot1 - no CSR
            % 删除掉BCH，2，3，4的BCH所处的位置恰好是没有CSR的
            dtIdx_subframe(PBCHStrIdx(4)+idx) = [];
            dtIdx_subframe(PBCHStrIdx(3)+idx) = [];
            dtIdx_subframe(PBCHStrIdx(2)+idx) = [];
        else
            % Account for CSR & null indices
            % 
            temp = reshape(idx, 3, 24);
            temp2 = temp(1:2, :);
            idx2 = temp2(:);
            % In reverse order - 4th and 3rd symbols of slot1 - no CSR
            % 四天线只有34没有CSR了
            dtIdx_subframe(PBCHStrIdx(4)+idx) = [];
            dtIdx_subframe(PBCHStrIdx(3)+idx) = [];
            % 2nd symbol of slot1
            if (numTx==2)
                % 还是正常删
                dtIdx_subframe(PBCHStrIdx(2)+idx) = []; % no CSR
            elseif (numTx==4)
                % 只删除没有CSR的位置，他这个reshape巧妙地找到了CSR的位置
                dtIdx_subframe(PBCHStrIdx(2)+idx2) = []; % has CSR
            end
        end
        % 1st symbol of slot1 - has CSR
        % 1总是有CSR的，他只删除idx2那么多的，因为这中间CSR已经没有了
        dtIdx_subframe(PBCHStrIdx(1)+idx2) = [];
        
        % Account for PSS, SSS 
        % 删除PSS和SSS
        for i=1:length(PSSReIdx)
            dtIdx_subframe(dtIdx_subframe==PSSReIdx(i)) = [];
            dtIdx_subframe(dtIdx_subframe==SSSReIdx(i)) = [];
        end
    case {10}
        % Account for PSS, SSS 
        for i=1:length(PSSReIdx)
            dtIdx_subframe(dtIdx_subframe==PSSReIdx(i)) = [];
            dtIdx_subframe(dtIdx_subframe==SSSReIdx(i)) = [];
        end
    otherwise % no other overheads
        % Do nothing  
end

%% Determine the CSR element indices in the input grid
% 下面来找CSR的位置
if (numTx>1) % for 4 and 2 common    
    csrIdx = zeros(4, Nrb);
    for i = 1:Nrb
        % 一个RB里有四个CSR的位置
        csrIdx(:, i) = [1;4;7;10]+12*(i-1);
    end
    csrIdx_Col = csrIdx(:);
else
    % Only 2 reference symbols per RB
    csrIdx = zeros(2, Nrb);
    csrIdx2 = zeros(2, Nrb);
    for i = 1:Nrb
        % 有两种不同的符号
        csrIdx(:, i) = [1;7]+12*(i-1);
        csrIdx2(:, i) = [4;10]+12*(i-1);
    end
    csrIdx_Col = csrIdx(:);
    csrIdx2_Col = csrIdx2(:);
end

if (numTx==1)
    % Slot filling specific to numTx = 1
    csrRx = complex(zeros(Nrb*2*2*2, numTx));
    % 先生成时隙的，再生成子帧的
    csrIdx_slot = [csrIdx_Col; csrIdx2_Col+4*lenOFDM];    
    csrIdx_subframe = [csrIdx_slot; csrIdx_slot+lenSlot];
elseif (numTx==2)
    % Slot filling specific to numTx = 2
    csrRx = complex(zeros(Nrb*4*2*2, numTx));
    % 先生成时隙的，再生成子帧的
    csrIdx_slot = [csrIdx_Col; csrIdx_Col+4*lenOFDM];    
    csrIdx_subframe = [csrIdx_slot; csrIdx_slot+lenSlot];
elseif (numTx==4)
    % Slot filling specific to numTx = 4
    csrRx = complex(zeros(Nrb*4*3*2, numTx));
    csrIdx_slot = [csrIdx_Col; csrIdx_Col+lenOFDM; csrIdx_Col+4*lenOFDM];    
    csrIdx_subframe = [csrIdx_slot; csrIdx_slot+lenSlot];
end

%% Extract the data and the CSR elements using the indices

% Switch loop variable depending on input type: rxData or channelEstimate
if strcmp(mode, 'data')
    colVal = numRx;
elseif strcmp(mode, 'chan')
    % 肯定是一个接收机一个接收机来处理，所以遍历发射天线
    colVal = numTx;
end

y = complex(zeros(length(dtIdx_subframe), colVal));
for i = 1:colVal
    tmp  = reshape(in(:,:,i), prmLTEPDSCH.numResources, 1);
    y(:, i)     = tmp(dtIdx_subframe);
    csrRx(:, i) = tmp(csrIdx_subframe);
end

% The other channels (PDCCH, PBCH) and signals (PSS, SSS) are not extracted 
% for now.

% [EOF]
