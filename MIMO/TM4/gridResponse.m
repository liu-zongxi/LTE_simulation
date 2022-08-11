function y=gridResponse(hp, Nrb, Nrb_sc, Ndl_symb, Edges,Mode)
% 插值
%#codegen
switch Mode
    case 1
        y=gridResponse_interpolate(hp, Nrb, Nrb_sc, Ndl_symb, Edges);
    case 2
        y=gridResponse_averageSlot(hp, Nrb, Nrb_sc, Ndl_symb, Edges);
    case 3
        y=gridResponse_averageSubframe(hp,  Ndl_symb, Edges);
    otherwise
        error('Choose the right Mode in function ChanEstimate.');
end
end