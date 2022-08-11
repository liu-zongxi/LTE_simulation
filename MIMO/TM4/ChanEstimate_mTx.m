function hD = ChanEstimate_mTx(prmLTE, Rx, Ref, Mode)
%#codegen
% 基本的参数
Nrb           = prmLTE.Nrb;     % Number of resource blocks
Nrb_sc      = prmLTE.Nrb_sc;                 % 12 for normal mode
Ndl_symb = prmLTE.Ndl_symb;        % 7    for normal mode
numTx      = prmLTE.numTx;
numRx      = prmLTE.numRx;
% Initialize output buffer
switch numTx
    % 单天线情况
    case 1                                                                                       % Case of 1 Tx
        % hd的大小和网格是一致的
        hD = complex(zeros(Nrb*Nrb_sc, Ndl_symb*2,numRx));   % Iniitalize Output
        % size(Rx) = [2*Nrb,  4,numRx]  size(Ref) = [2*Nrb, 4] 
        % 这个是四个符号的起始值
        % 这是一个RB中CSR的位置前后的空缺，要从下往上看！看我ppt里的图
        Edges=[0,3,0,3];
        for n=1:numRx                                                                     
            Rec=Rx(:,:,n);
            hp= Rec./Ref;
            % 根据CSR的位置生成全部的频谱了，三种方法都是非常巧妙的，值得学习！
            hD(:,:,n)=gridResponse(hp, Nrb, Nrb_sc, Ndl_symb, Edges,Mode);
        end
    % 两天线
    case 2                                                           % Case of 2 Tx
        % 多一维发射天线
        hD = complex(zeros(Nrb*Nrb_sc, Ndl_symb*2,numTx, numRx));
        % size(Rx) = [4*Nrb,  4,numRx]  size(Ref) = [2*Nrb, 4, numTx] 
        for n=1:numRx
            % 
            Rec=Rx(:,:,n);
            for m=1:numTx
                % 这个函数从CSR中取出了当前天线的CSR位置
                [R,Edges]=getBoundaries2(m, Rec);
                T=Ref(:,:,m);
                hp= R./T;
                % 得到完整的估计
                hD(:,:,m,n)=gridResponse(hp, Nrb, Nrb_sc, Ndl_symb, Edges,Mode);
            end
        end
    % 四天线
    case 4
        hD = complex(zeros(Nrb*Nrb_sc, Ndl_symb*2,numTx, numRx));
        % size(Rx) = [4*Nrb,  4,numRx]  size(Ref) = [2*Nrb, 4, numTx] 
        for n=1:numRx
            Rec=Rx(:,:,n);
            for m=1:numTx
                % 取出当前天线的CSR
                [R,idx3, Edges]=getBoundaries4(m, Rec);
                T=Ref(:,idx3,m);
                hp= R./T;
                % 获得完整的hD
                hD(:,:,m,n)=gridResponse(hp, Nrb, Nrb_sc, Ndl_symb, Edges,Mode);
            end
        end
end
end
%% Helper function
function [R,idx3, Edges]=getBoundaries4(m,  Rec)
coder.varsize('Edges');coder.varsize('idx3');
% 和2是类似的
% idx3也是为了三四天线特殊处理的
numPN=size(Rec,1);
idx_0=(1:2:numPN);
idx_1=(2:2:numPN);
Edges=[0,3,0,3];
idx3=1:4;
switch m
    case 1
        index=[idx_0,  2*numPN+idx_1, 3*numPN+idx_0,  5*numPN+idx_1]';
        Edges=[0,3,0,3];   idx3=1:4;
    case 2
        index=[idx_1,  2*numPN+idx_0, 3*numPN+idx_1,  5*numPN+idx_0]';
        Edges=[3,0,3,0];    idx3=1:4;
    case 3
        index=[numPN+idx_0,  4*numPN+idx_1]';
        Edges=[0,3];           idx3=[1 3];
    case 4
        index=[numPN+idx_1,  4*numPN+idx_0]';
        Edges=[3,0];          idx3=[1 3];
end
R=reshape(Rec(index),numPN/2,numel(Edges));
end
%% Helper function
% 
function [R, Edges]=getBoundaries2(m, Rec)
% numPN是一个符号中CSR的个数
% 首先区分出第一个和第二个天线的CSR，因为他是两种拼起来的
numPN=size(Rec,1);
idx_0=(1:2:numPN);
idx_1=(2:2:numPN);
Edges=[0,3,0,3]; 
switch m
    case 1
        index=[idx_0,  numPN+idx_1, 2*numPN+idx_0, 3*numPN+idx_1]';
        Edges=[0,3,0,3]; 
    case 2
        index=[idx_1,  numPN+idx_0, 2*numPN+idx_1,  3*numPN+idx_0]';
        Edges=[3,0,3,0];  
end
% 取出当前天线的CSR，然后reshape成正确的形状
R=reshape(Rec(index),numPN/2,4);
end