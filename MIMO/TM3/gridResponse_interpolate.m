function hD=gridResponse_interpolate(hp, Nrb, Nrb_sc, Ndl_symb, Edges)
% Average over the two same Freq subcarriers, and then interpolate between
% them - get all estimates and then repeat over all columns (symbols).
% The interpolation assmues NCellID = 0.
% Time average two pilots over the slots, then interpolate (F)
% between the 4 averaged values, repeat for all symbols in sframe
% 
Separation=6;
hD = complex(zeros(Nrb*Nrb_sc, Ndl_symb*2));
N=numel(Edges);
% Compute channel response over all resource elements of OFDM symbols
switch N
    % 边界为2，这是针对四天线的34天线的
    case 2
        % 所在的符号
        Symbols=[2, 9];
        % Interpolate between subcarriers
        for n=1:N
            % 为什么是5，12中间隔着6然后再加上本身两个CSR
            E=Edges(n);Edge=[E, 5-E];
            % 频域插值
            y = InterpolateCsr(hp(:,n),  Separation, Edge);
            % 得到了CSR的那两列的全频域的信道
            hD(:,Symbols(n))=y;
        end
        % Interpolate between OFDM symbols
        % m是还未被填充的列，即符号
        for m=[1,3:8,10:14]
            % 2，9之间间隔7，加权平均
            % 这应该加绝对值吧。。。
            alpha=(1/7)*(m-2);
            beta=1-alpha;
            hD(:,m)    = beta*hD(:,2) + alpha*hD(:,  9);
        end
    % 有四个起始idx，这是针对正常情况
    case 4
        %  类似的
        Symbols=[1, 5, 8, 12];
        % Interpolate between subcarriers
        for n=1:N
            E=Edges(n);Edge=[E, 5-E];
            y = InterpolateCsr(hp(:,n),  Separation, Edge);
            hD(:,Symbols(n))=y;
        end
        % Interpolate between OFDM symbols
        for m=[2, 3, 4, 6, 7]
            alpha=0.25*(m-1);
            beta=1-alpha;
            hD(:,m)    = beta*hD(:,1) + alpha*hD(:,  5);
            hD(:,m+7) =beta*hD(:,8) + alpha*hD(:,12);
        end
    otherwise
        error('Wrong Edges parameter for function gridResponse.');
end