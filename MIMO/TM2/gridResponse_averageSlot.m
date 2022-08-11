function hD=gridResponse_averageSlot(hp, Nrb, Nrb_sc, Ndl_symb, Edges)
% Average over the two same Freq subcarriers, and then interpolate between
% them - get all estimates and then repeat over all columns (symbols).
% The interpolation assmues NCellID = 0.
% Time average two pilots over the slots, then interpolate (F)
% between the 4 averaged values, repeat for all symbols in sframe
% 首先把两个拼起来，然后插值
Separation=3;
hD = complex(zeros(Nrb*Nrb_sc, Ndl_symb*2));
N=numel(Edges);
% Compute channel response over all resource elements of OFDM symbols
switch N
    % 四天线34天线特殊情况
    case 2
        % Interpolate between subcarriers
        Index=1:Ndl_symb;
        for n=1:N 
            E=Edges(n);Edge=[E, 5-E];
            % 在频域插值
            y = InterpolateCsr(hp(:,n),  2* Separation, Edge);
            % Repeat between OFDM symbols in each slot
            % 复制这一列
            yR=y(:,ones(1,Ndl_symb));
            % 先完成这一时隙
            hD(:,Index)=yR;
            Index=Index+Ndl_symb;
        end
    % 正常情况
    case 4
        Edge=[0 2];
        % 把两个CSR拼起来
        h1_a_mat = [hp(:,1),hp(:,2)].';
        % 非常巧妙，这样一抽就把12一个个交叉起来了，和频域是符合的
        h1_a = h1_a_mat(:);
        % 同理
        h2_a_mat = [hp(:,3),hp(:,4)].';
        h2_a = h2_a_mat(:);
        % 两个拼起来
        hp_a=[h1_a,h2_a];
        Index=1:Ndl_symb;
        for n=1:size(hp_a,2) 
            % 插值出频域的
            y = InterpolateCsr(hp_a(:,n),  Separation, Edge);
            % Repeat between OFDM symbols in each slot
            % 复制到每一个plot,也就是还是只有第一列有用
            yR=y(:,ones(1,Ndl_symb));
            hD(:,Index)=yR;
            Index=Index+Ndl_symb;
        end
    otherwise
        error('Wrong Edges parameter for function gridResponse.');
end