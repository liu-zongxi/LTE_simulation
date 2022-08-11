function Wn = PrecoderMatrix(cbIdx, numTx, v)
% LTE Precoder for PDSCH spatial multiplexing.
%#codegen
%  v           = Number of layers
%  numTx  = Number of Tx antennas
% cbIdx是对应的码本编号
switch numTx
    case 2
        Wn = complex(ones(numTx, v));
        switch v
            case 1
                a=(1/sqrt(2));
                codebook = [a,a; a,-a; a, 1j*a; a, -1j*a];
                Wn = codebook(cbIdx+1,:).';
            case 2
                if cbIdx==1
                    Wn = (1/2)*[1 1; 1 -1];
                elseif cdIdx==2
                    Wn = (1/2)*[1 1; 1j -1j];
                else
                    error('Not used. Please try with a different index.');
                end
        end
    case 4
        un = complex(ones(numTx, 1));
        switch cbIdx
            case 0,   un = [1 -1 -1 -1].';
            case 1,   un = [1 -1j 1 1j].';
            case 2,   un = [1 1 -1 1].';
            case 3,   un = [1 1j 1 -1j].';
            case 4,   un = [1 (-1-1j)/sqrt(2) -1j (1-1j)/sqrt(2)].';
            case 5,   un = [1 (1-1j)/sqrt(2) 1j (-1-1j)/sqrt(2)].';
            case 6,   un = [1 (1+1j)/sqrt(2) -1j (-1+1j)/sqrt(2)].';
            case 7,   un = [1 (-1+1j)/sqrt(2) 1j (1+1j)/sqrt(2)].';
            case 8,   un = [1 -1 1 1].';
            case 9,   un = [1 -1j -1 -1j].';
            case 10, un = [1 1 1 -1].';
            case 11, un = [1 1j -1 1j].';
            case 12, un = [1 -1 -1 1].';
            case 13, un = [1 -1 1 -1].';
            case 14, un = [1 1 -1 -1].';
            case 15, un = [1 1 1 1].';
        end
        Wn = eye(4) - 2*(un*un')./(un'*un);
        switch cbIdx    % order columns, for numLayers=4 only
            case {2, 3, 14}
                Wn = Wn(:, [3 2 1 4]);
            case {6, 7, 10, 11, 13}
                Wn = Wn(:, [1 3 2 4]);
        end
        Wn = Wn./sqrt(v);
end