function out = LayerMapper(in1, in2, prmLTEPDSCH)
% LTE Layer mapper for spatial multiplexing.
%
%   Assumes two codeword input for spatial multiplexing.
%   As per TS 36.211 v10.0.0, Section 6.3.3.2.

%   Copyright 2012 The MathWorks, Inc.

%#codegen
% Assumes the incoming codewords are of the same length.
% 参数获取
q = prmLTEPDSCH.numCodeWords;           % Number of codewords
v = prmLTEPDSCH.numLayers;                   % Number of layers
% 两个数据流，TM3总是支持双流的，而现在考虑的是满秩情况
inLen1 = size(in1, 1);
inLen2 = size(in2, 1);
% 根据数据流分类
switch q
    % 如果是单流，那直接根据层数分列就可以了
    case 1  % Single codeword
        % for numLayers = 1,2,3,4
        out = reshape(in1, [], v);
    % 双流的情况
    case 2  % Two codewords
        switch v
            % 两层
            case 2
                % 双流双层，分别对应即可
                out = complex(zeros(inLen1, v));
                out(:,1) = in1(:,1);
                out(:,2) = in2(:,1);
            case 3 % => different length input codewords
                assert(false, '3 layers for 2 codewords is not implemented yet.');
            case 4
                % 双流四层
                % 一个流则对应两个层
                out = complex(zeros(inLen1/2, v));
                out(:,1:2) = reshape(in1, 2, inLen1/2).';
                out(:,3:4) = reshape(in2, 2, inLen2/2).';
            case 5 % => different length input codewords
                assert(false, '5 layers for 2 codewords is not implemented yet.');
            case 6
                % 双流六层
                % 一个流对应三个层
                out = complex(zeros(inLen1/3, v));
                out(:,1:3) = reshape(in1, 3, inLen1/3).';
                out(:,4:6) = reshape(in2, 3, inLen2/3).';
            case 7 % => different length input codewords
                assert(false, '7 layers for 2 codewords is not implemented yet.');
            case 8
                % 双流八层
                out = complex(zeros(inLen1/4, v));
                out(:,1:4) = reshape(in1, 4, inLen1/4).';
                out(:,5:8) = reshape(in2, 4, inLen2/4).';
        end
end

% [EOF]
