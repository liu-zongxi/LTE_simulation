function CheckAntennaConfig(numTx, numRx)
% 有点逆天了这个函数，总之就是找出这个MIMO是否是支持的
MyConfig=[numTx,numRx];
Allowed=[1,1;1,2;1,3;1,4;2,2;4,4];
tmp=MyConfig(ones(size(Allowed,1),1),:);
err=sum(abs(tmp-Allowed),2);
if isempty(find(~err,1))
    Status=0;
else
    Status=1;
end
if ~Status
    disp('Wrong antenna configuration! Allowable configurations are:');
    disp(Allowed);
    error('Please change number of Tx and/or Rx antennas!');
end