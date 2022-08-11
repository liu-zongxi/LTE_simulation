function C= ExpungeFrom( A, B)
%#codegen
C=A(~ismember(A,B));
end
% Find a good alternative
% function C= ExpungeFrom( A, B)
% %#codegen
% C=A;
% for n=1:numel(B)
%     C(C==B(n)) = [];
% end
% end
% function C= ExpungeFrom( A, B)
% %#codegen
% C=setdiff(A,B);
% end
