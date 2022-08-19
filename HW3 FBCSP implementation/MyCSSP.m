function [W] = MyCSSP(Xtr1,Xtr2,tau,m)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
C1=0;
C2=0;
Ntr1=length(Xtr1);
Ntr2=length(Xtr2);
for itr=1:max(Ntr1,Ntr2)
    if itr<=Ntr1
        x=Xtr1{itr};
        x=[x(1:end-tau,:),x(1+tau:end,:)];
        for ich=1:size(x,2)
            x(:,ich)=x(:,ich)-mean(x(:,ich));
        end
%         c=x'*x/size(x,1);
        c=x'*x/trace(x'*x);
        C1=C1+c;
    end
    if itr<=Ntr2
        x=Xtr2{itr};
        x=[x(1:end-tau,:),x(1+tau:end,:)];
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
% [W,L]=eig(pinv(C2)*C1);
[W,L]=eig(C1,C2);
[L,indx]=sort(diag(L),'descend');
W=W(:,indx);
W=W(:,[1:m,Ndim-m+1:Ndim]);
end

