function [W, D, U] = PrecoderMatrixOpenLoop(n, v)
% 开环MIMO的预编码矩阵
% 实现有问题，参考https://zhuanlan.zhihu.com/p/495045923进行了修改
% LTE Precoder for PDSCH spatial multiplexing.
%#codegen
% i四个就循环了，所以直接mod4
idx=mod(n-1,4);
switch v
    % 层为1，会退化到TM2，不考虑这样的情况
    case 1
        % 涉及到TM3模式的CCD有WUD三个矩阵
        % 单流就是这样，相当于没有进行CCD
        W=complex(1,0);
        U=W;D=W;
    % 层为2
    case 2
        % 是否少了(1/sqrt(2))
        % W= [1 0; 0 1];
        W=(1/sqrt(2)) * [1 0; 0 1];
        U=(1/sqrt(2))*[1 1;1 exp(-1j*pi)];
        D=[1 0;0 exp(-1j*pi*idx)];
    case 4 
        k=1+mod(floor(n/4),4);
        switch k
            case 1, un = [1 -1 -1 1].';
            case 2, un = [1 -1 1 -1].';
            case 3, un = [1 1 -1 -1].';
            case 4, un = [1 1 1 1].';
        end
        W = eye(4) - 2*(un*un')./(un'*un);
        switch k    % order columns
            case 3
                W = W(:, [3 2 1 4]);
            case 2
                W = W(:, [1 3 2 4]);
        end
        a=[0*(0:1:3);2*(0:1:3);4*(0:1:3);6*(0:1:3)];
        U=(1/2)*exp(-1j*pi*a/4);
        b=0:1:3;
        D=diag(exp(-1j*2*pi*idx*b/4));
end