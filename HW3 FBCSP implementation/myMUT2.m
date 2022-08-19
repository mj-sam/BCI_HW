function [I] = myMUT2(F,Labels)
%% Base on the paper: Optimum Spatio-Spectral Filtering Network for Brain–Computer Interface
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
C=unique(Labels);
Ncls=length(C);
Fx={};
Nx=[];
nF=length(Labels);
Mx={};
Xx={};
Nd=size(F,1);
for i=1:Ncls
    indx=find(Labels==C(i));
    Fx{i}=F(:,indx);
    Nx(i)=length(indx);
    Mx{i}=mean(Fx{i}')';
    Xx{i}=0;
    Px(i)=Nx(i)/nF;
end
mFtot=mean(F')';
% nF=Nfa+Nfb;


x=0;
xa=0;
xb=0;
for i_nf=1:nF
    x=x+(F(:,i_nf)-mFtot).^2;
    for i=1:Ncls
        if i_nf<=Nx(i)
            Xx{i}=Xx{i}+(Fx{i}(:,i_nf)-Mx{i}).^2;
        end
    end
end
zeta=(4/(3*nF))^0.1;
psi=zeta*x/(nF-1);
PSIinvTOT=psi;

for i=1:Ncls
    zeta=(4/(3*Nx(i)))^0.1;
    psiX{i}=zeta*Xx{i}/(Nx(i)-1);
    HcondX(i)=0;
end


H=0;
for i_nf=1:nF
%         H=H+log(prob(F(:,i_nf),F,PSIinvTOT));
    H=H+log(kerGAU(F(:,i_nf)-mFtot,PSIinvTOT));
    for i=1:Ncls
        if i_nf<=Nx(i)
%             HcondX(i)=HcondX(i)+log(prob(Fx{i}(:,i_nf),Fx{i},psiX{i}));
            HcondX(i)=HcondX(i)+log(kerGAU(Fx{i}(:,i_nf)-Mx{i},psiX{i}));
        end
    end
end
H=-H/nF;
I=H;
for i=1:Ncls
    HcondX(i)=-HcondX(i)/Nx(i);
    I=I-HcondX(i)*Px(i);
end
I=I/Nd;


end

