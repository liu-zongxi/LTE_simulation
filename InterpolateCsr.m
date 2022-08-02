function y = InterpolateCsr(x,  Separation, Edges)
%#codegen
xIndex = 1:numel(x); 
zIndex = 1:(1/Separation):numel(x);
z= interp1(xIndex',x,zIndex');
delta          = z(2)-z(1);
z_before    = z(1)     -  delta*(Edges(1):-1:1)';
z_after       = z(end) + delta*(1:Edges(2))';
y             = [z_before;z;z_after];