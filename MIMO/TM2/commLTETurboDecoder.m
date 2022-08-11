classdef commLTETurboDecoder < matlab.System %#ok<*EMCLS>
%commLTETurboDecoder Decode input using an early-terminating LTE turbo decoder.
%   H = commLTETurboDecoder creates an LTE turbo decoder System object, H.
%   This object uses the a-posteriori probability (APP) constituent decoder
%   to iteratively decode the parallel-concatenated convolutionally encoded
%   input data. It uses a CRC check for early decoder termination and
%   outputs only the message bits (minus the checksum) corresponding to the
%   code-block.
%
%   H = commLTETurboDecoder(Name, Value) creates an LTE turbo decoder
%   object, H, with the specified property Name set to the specified Value.
%   You can specify additional name-value pair arguments in any order as
%   (Name1, Value1, ... , NameN, ValueN).
%
%   H = commLTETurboDecoder(INTERLVRINDICES, MAXITER) creates an LTE turbo
%   decoder object, H, with the InterleaverIndices property set to
%   INTERLVRINDICES and the MaximumIterations property set to MAXITER.
%
%   Step method syntax:
%
%   Y = step(H, X) decodes the input data, X, using the parallel
%   concatenated convolutional coding scheme that is specified by the LTE
%   standard and the corresponding InterleaverIndices property. It returns
%   the binary decoded data, Y. Both X and Y are column vectors of double
%   or single precision data type. For the rate 1/2 code, the step method
%   sets the length of the output vector, Y, to (M-12)/3 -24, where M is
%   the input vector length, 12 is the number of tail bits and 24 is the
%   length of checksum removed per code block. The output length, L, is the
%   length of the interleaver indices minus the checksum length.
%
%   Y = step(H, X, INTERLVRINDICES) uses the INTERLVRINDICES specified as
%   an input. INTERLVRINDICES is a column vector containing integer values
%   from 1 to N with no repeated values where N is the code-block length.
%   For this syntax, N can vary per call. 
%
%   commLTETurboDecoder methods:
%
%   step     - Perform turbo decoding (see above)
%   release  - Allow property value and input characteristics changes
%   clone    - Create turbo decoder object with same property values
%   isLocked - Locked status (logical)
%
%   commLTETurboDecoder properties:
%
%   InterleaverIndicesSource - Source of interleaving indices
%   InterleaverIndices       - Interleaving indices
%   Algorithm                - Decoding algorithm
%   NumScalingBits           - Number of scaling bits
%   MaximumIterations        - Maximum number of decoding iterations
%
%   % Example:
%   %   Transmit turbo-encoded blocks of data over a BPSK-modulated AWGN
%   %   channel, decode using an iterative turbo decoder and display errors
% 
%   noiseVar = 2.5; frmLen = 1000;
%   intrlvrIndices = commExamplePrivate('lteIntrlvrIndices', frmLen+24);
%   s = RandStream('mt19937ar', 'Seed', 991);
% 
%   hCRCGen = comm.CRCGenerator('Polynomial', ...
%                               [1 1 zeros(1, 16) 1 1 0 0 0 1 1]);
%   hTEnc  = comm.TurboEncoder('TrellisStructure', poly2trellis(4, ...
%            [13 15], 13), 'InterleaverIndices', intrlvrIndices);
%   hMod   = comm.BPSKModulator;
%   hChan  = comm.AWGNChannel('NoiseMethod', 'Variance', 'Variance', noiseVar);
%   hTDec  = commLTETurboDecoder('InterleaverIndices', intrlvrIndices, ...
%            'MaximumIterations', 9);
%   hError = comm.ErrorRate;
% 
%   for frmIdx = 1:8
%       data = randi(s, [0 1], frmLen, 1);
%       crcData = step(hCRCGen, data);
%       encodedData = step(hTEnc, crcData);
%       modSignal = step(hMod, encodedData);
%       receivedSignal = step(hChan, modSignal);
% 
%       % Convert received signal to log-likelihood ratios for decoding
%       [receivedBits, flag, iter]  = step(hTDec, (-2/(noiseVar/2))*real(receivedSignal));
%     
%       errorStats = step(hError, data, receivedBits);
%       fprintf(['Frame number = %d, Iterations used = %d,',...
%       ' Checksum flag = %d\n'], frmIdx, iter, flag)
%   end
%   fprintf('Bit error rate = %f\nNumber of errors = %d\nTotal bits = %d\n', ...
%   errorStats(1), errorStats(2), errorStats(3))     
%
%   See also comm.TurboDecoder, comm.APPDecoder, comm.TurboEncoder.
%
%   Reference: 
%   "3GPP Technical Specification Group Radio Access Network; Evolved
%   Universal Terrestrial Radio Access (E-UTRA); Multiplexing and channel
%   coding (Release 10)", 3GPP TS 36.212 v10.0.0 (2010-12), Sec. 5.1.3.2.
 
%   Copyright 2011-2013 The MathWorks, Inc.
 
%#codegen
 
properties (Nontunable)
  %InterleaverIndicesSource Source of interleaver indices
  %   Specify the source of the interleaver indices as one of 'Property' |
  %   'Input port'. The default is 'Property'. When you set this property
  %   to 'Input port' the object uses the interleaver indices specified as
  %   an input to the step method. When you set this property to
  %   'Property', the object uses the interleaver indices that you specify
  %   in the InterleaverIndices property.
  InterleaverIndicesSource = 'Property';
  %InterleaverIndices Interleaver indices
  %   Specify the mapping used to permute the input bits at the encoder as
  %   a column vector of integers. The default is (64:-1:1).'. This mapping
  %   is a vector with the number of elements equal to L+24, where L is the
  %   length of the output of the step method. Each element must be an
  %   integer between 1 and L+24, with no repeated values.
  InterleaverIndices = (64:-1:1).';
  %Algorithm Decoding algorithm
  %   Specify the decoding algorithm that the object uses for decoding as
  %   one of 'True APP' | 'Max*' | 'Max'. The default is 'TrueAPP'. When
  %   you set this property to 'True APP', the object implements true a
  %   posteriori probability decoding. When you set this property to any
  %   other value, the object uses approximations to increase the speed of
  %   the computations.
  Algorithm = 'True APP';
  %NumScalingBits Number of scaling bits
  %   Specify the number of bits the constituent decoders use to scale the
  %   input data to avoid losing precision during computations. The
  %   constituent decoders multiply the input by 2^NumScalingBits and
  %   divide the pre-output by the same factor. NumScalingBits must be a
  %   scalar integer between 0 and 8. This property applies when you set
  %   the Algorithm property to 'Max*'. The default is 3.
  NumScalingBits = 3;
  %MaximumIterations Maximum number of decoding iterations
  %   Specify the maximum number of decoding iterations used for each call
  %   to the step method. The default is 6. The object will iterate and
  %   provide updates to the log-likelihood ratios (LLR) of the uncoded
  %   output bits. The output of the step method is the hard-decision
  %   output of the LLR update corresponding to the final iteration or an
  %   earlier one if the CRC check was positive for that iteration.
  MaximumIterations = 6;
end
 
properties (Constant, Hidden)
    InterleaverIndicesSourceSet = comm.CommonSets.getSet('SpecifyInputs');
    AlgorithmSet = comm.CommonSets.getSet('Algorithm');
end
 
properties(Access = private, Nontunable)
    % Constituent components
    cAPPDec1;       % decoder1
    cAPPDec2;       % decoder2
    cCBCRCDet;      % CRC detector
end
 
methods
    % CONSTRUCTOR
    function obj = commLTETurboDecoder(varargin)
        setProperties(obj, nargin, varargin{:}, ...
                      'InterleaverIndices', 'MaximumIterations');
    end
     
    function set.InterleaverIndices(obj, value)
        validateattributes(value,...
            {'numeric'}, {'real', 'finite', 'positive', 'integer', ...
            'vector'}, '','InterleaverIndices');     %#ok<EMCA>
        obj.InterleaverIndices = value;
    end
     
    function set.NumScalingBits(obj, value)
        validateattributes(value, ...
            {'numeric'}, {'real', 'finite', 'nonnegative', 'integer', ...
            'scalar', '>=', 0, '<=', 8}, '', 'NumScalingBits');     %#ok<EMCA>
        obj.NumScalingBits = value;
    end
     
    function set.MaximumIterations(obj, value)
        validateattributes(value,...
            {'numeric'}, {'real', 'finite', 'positive', 'integer', ...
            'scalar'}, '', 'MaximumIterations'); %#ok<EMCA>
        obj.MaximumIterations = value;
    end
end
     
methods(Access = protected)   % System object APIs
 
    function validateInputsImpl(~,varargin)
        if ~isfloat(varargin{1})
            matlab.system.internal.error(...
                'MATLAB:system:invalidInputDataType','X','floating-point');
        end
    end
     
    function num = getNumInputsImpl(obj)
        num = 1 + strcmp(obj.InterleaverIndicesSource, 'Input port');
    end
     
    function num = getNumOutputsImpl(~)
        num = 3;
    end
     
    function flag = isInputSizeLockedImpl(obj,~)
        if strcmp(obj.InterleaverIndicesSource, 'Input port')
            flag = false; % vars only via input port
        else
            flag = true;
        end
    end
 
    function flag = isInputComplexityLockedImpl(~,~)
        flag = true;
    end
     
    function flag = isOutputComplexityLockedImpl(~,~)
        flag = true;
    end
 
    function setupImpl(obj, varargin)
        trellis = poly2trellis(4, [13 15], 13);
        if strcmp(obj.Algorithm, 'Max*')
            obj.cAPPDec1 = comm.APPDecoder('TrellisStructure',...
                trellis,...
                'TerminationMethod', 'Terminated',...
                'Algorithm', obj.Algorithm,...
                'NumScalingBits', obj.NumScalingBits,...
                'CodedBitLLROutputPort', false);
            obj.cAPPDec2 = comm.APPDecoder('TrellisStructure',...
                trellis,...
                'TerminationMethod', 'Terminated',...
                'Algorithm', obj.Algorithm,...
                'NumScalingBits', obj.NumScalingBits,...
                'CodedBitLLROutputPort', false);
        else
            obj.cAPPDec1 = comm.APPDecoder('TrellisStructure',...
                trellis,...
                'TerminationMethod', 'Terminated',...
                'Algorithm', obj.Algorithm,...
                'CodedBitLLROutputPort', false);
            obj.cAPPDec2 = comm.APPDecoder('TrellisStructure',...
                trellis,...
                'TerminationMethod', 'Terminated',...
                'Algorithm', obj.Algorithm,...
                'CodedBitLLROutputPort', false);
        end
         
        obj.cCBCRCDet = comm.CRCDetector('Polynomial', ...
                                         [1 1 zeros(1, 16) 1 1 0 0 0 1 1]);
    end
 
    function [y2, flag, iterIdx] = stepImpl(obj, x, varargin)
        if strcmp(obj.InterleaverIndicesSource, 'Input port')
            interlvrIndices = varargin{1};
            blkLen = length(interlvrIndices); 
        else
            interlvrIndices = get(obj, 'InterleaverIndices');
            blkLen = length(interlvrIndices); 
        end        
        assert(isequal((1:blkLen).', sort(interlvrIndices(:))),...
                    'comm:system:commLTETurboDecoder:invalidIndices',...
                    ['The InterleaverIndices must be a positive ',...
                    'integer vector with unique elements.']);
        assert((length(x)-12)/3 == blkLen,...
            'comm:system:commLTETurboDecoder:inputLengthMismatch', ...
            ['Inconsistent input lengths. The length of the input ',...
            'must be related to the length of the interleaver indices ',...
            'as described in the step method help for the object.']);
                        
        typex = class(x);
        % Bit order
        dIdx   = 3*blkLen;
        yD     = reshape(x((1:dIdx).',1), 3, blkLen);
        lc1D   = yD(1:2, :);
        y1T    = x(dIdx + (1:6).', 1);
        Lc1_in = [lc1D(:); y1T];
 
        Lu1_in = zeros(blkLen+3, 1, typex);
         
        lc2D1  = zeros(1, blkLen, typex);
        lc2D2  = yD(3, :);
        lc2D   = [lc2D1; lc2D2];
        y2T    = x(dIdx+(7:12).', 1);
        Lc2_in = [lc2D(:); y2T];
 
        % Turbo decode with early termination
        out1 = zeros(blkLen, 1, typex);
        for iterIdx = 1:obj.MaximumIterations
            Lu1_out = step(obj.cAPPDec1, Lu1_in, Lc1_in);
            tmp = Lu1_out((1:blkLen).',1);
            tmp2 = tmp(:);
            Lu2_out = step(obj.cAPPDec2, ...
                [tmp2(interlvrIndices); zeros(3,1,typex)], Lc2_in);
 
            out1(interlvrIndices) = Lu2_out((1:blkLen).',1);
            Lu1_in = [out1; zeros(3,1,typex)];
 
            % Calculate llr and decoded bits 
            llr = out1 + tmp2; 
            y = (llr>=0);
             
            % Check checksum, if positive, break
            [y2, flag] = step(obj.cCBCRCDet, y);
            y2 = cast(y2, typex);
            if (flag == 0)  % no error
                break;      % early termination
            end
        end
    end
 
    function releaseImpl(obj)
        release(obj.cAPPDec1);
        release(obj.cAPPDec2);
        release(obj.cCBCRCDet);      
    end
end
 
methods (Access=protected)
    function flag = isInactivePropertyImpl(obj, prop)
        flag = false;
        switch prop
            case 'InterleaverIndices'
                if strcmp(obj.InterleaverIndicesSource, 'Input port')
                    flag = true;
                end
            case 'NumScalingBits'
                if ~strcmp(obj.Algorithm, 'Max*')
                    flag = true;
                end
        end
    end
end
 
end