function y=getSnrVector(modType, MaxIter)
switch modType
    case 1
        MaxSnr = 12;
    case 2
        MaxSnr = 16;
    case 3
        MaxSnr = 24;
end
y=fix(linspace(0,MaxSnr, MaxIter));