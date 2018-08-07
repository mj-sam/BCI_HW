function [W] = MyTRCSP(Xtr1,Xtr2,m,alpha)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
C1=0;
C2=0;
Ntr1=length(Xtr1);
Ntr2=length(Xtr2);
for itr=1:max(Ntr1,Ntr2)
    if itr<=Ntr1
        x=Xtr1{itr};
        for ich=1:size(x,2)
            x(:,ich)=x(:,ich)-mean(x(:,ich));
        end
%         c=x'*x/size(x,1);
        c=x'*x/trace(x'*x);
        C1=C1+c;
    end
    if itr<=Ntr2
        x=Xtr2{itr};
        for ich=1:size(x,2)
            x(:,ich)=x(:,ich)-mean(x(:,ich));
        end
%         c=x'*x/size(x,1);
        c=x'*x/trace(x'*x);
        C2=C2+c;
    end
end
Ndim=size(C1,1);
C1=C1/Ntr1;
C2=C2/Ntr2;

[W1,L]=eig(C1,(C2+alpha*eye(size(C2))));
[L,indx]=sort(diag(L),'descend');
W1=W1(:,indx);
[W2,L]=eig(C2,(C1+alpha*eye(size(C1))));
[L,indx]=sort(diag(L),'descend');
W2=W2(:,indx);
W=[W1(:,1:m),W2(:,1:m)];
end

