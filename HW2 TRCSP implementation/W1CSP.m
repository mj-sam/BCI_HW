function [W] = W1CSP(Xtr1,Xtr2,m,alpha)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
C1=0;
C2=0;
Ntr1=length(Xtr1);
Ntr2=length(Xtr2);
Ce1 = 0;
Ce2 = 0;
for itr=1:max(Ntr1,Ntr2)
    if itr<=Ntr1
        x=Xtr1{itr};
        for ich=1:size(x,2)
            x(:,ich)=x(:,ich)-mean(x(:,ich));
        end
        c=x'*x/trace(x'*x);
        C1=C1+c;
        % noise covariance estimation
        Xe = x(2:end,:) - x(1:end-1,:);
        ce = Xe'*Xe / trace(x'*x);
        Ce1 = Ce1 + ce;
    end
    if itr<=Ntr2
        x=Xtr2{itr};
        for ich=1:size(x,2)
            x(:,ich)=x(:,ich)-mean(x(:,ich));
        end
        c=x'*x/trace(x'*x);
        C2=C2+c;
        % noise covariance estimation
        Xe = x(2:end,:) - x(1:end-1,:);
        ce = Xe'*Xe / trace(x'*x);
        Ce2 = Ce2 + ce;
    end
end
Ndim=size(C1,1);
C1=C1/Ntr1;
Ce1=Ce1/Ntr1;
C2=C2/Ntr2;
Ce2=Ce2/Ntr2;
% [W,L]=eig(pinv(C2)*C1);
% C2=C2+alpha*eye(size(C2));
[W1,L]=eig(C1,(C2+alpha * Ce2 ));
[L,indx]=sort(diag(L),'descend');
W1=W1(:,indx);
[W2,L]=eig(C2,(C1+alpha * Ce1));
[L,indx]=sort(diag(L),'descend');
W2=W2(:,indx);
W=[W1(:,1:m),W2(:,1:m)];
end

