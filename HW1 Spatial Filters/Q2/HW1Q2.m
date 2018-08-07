% clc
clear all;
[d1,name,ext]=fileparts(which(mfilename));
d2=[d1,'\Datasets\BCICIV_calib_ds1'];
Nsub=7;
name='abcdefg';
%% initializing plane and plot based on number and name
dirc=[d2,'a','_100Hz.mat'];
load(dirc)
X = nfo.xpos;
Y = nfo.ypos;
plane = cat(2,X,Y);
% figure()
% scatter(plane(:,1), plane(:,2), 'filled')
% labels = num2str((1:size(plane,1))','%d');    %'
% text(plane(:,1), plane(:,2), labels, 'horizontal','left', 'vertical','bottom')
% 
% figure()
% scatter(plane(:,1), plane(:,2), 'filled')
% text(plane(:,1), plane(:,2), nfo.clab, 'horizontal','left', 'vertical','bottom')
%% classification
Method = {'Nofilter','CAR','LLaplacian','SLaplacian'};
for i_method = 1:size(Method,2)
    disp('')
    disp(['Result For ',Method(i_method)]);
    PERFORMANCE=[];
    for isub=1:Nsub;
        dirc=[d2,name(isub),'_100Hz.mat'];
        load(dirc)
        cnt= 0.1*double(cnt);
        Fs=100;
        [b,a]=butter(3,[8 30]/(Fs/2),'bandpass');
        Signal=filtfilt(b,a,cnt);
        %% spatial filtering
        Signal=SpatialFilter(Signal,plane,Method(i_method),[27,31]);
        pos=mrk.pos;
        y=mrk.y;
        class1=[];class2=[];
        cntr1=0;cntr2=0;
        for i=1:length(pos)
            indx=pos(i):pos(i)+400;
            if y(i)==1
                cntr1=cntr1+1;
                class1{cntr1}=Signal(indx,:);
            else
                cntr2=cntr2+1;
                class2{cntr2}=Signal(indx,:);
            end
        end

        F1=[];
        F2=[];

        for i=1:length(class1)
            x=class1{i};
            F1(:,i)=var(x);
            x=class2{i};
            F2(:,i)=var(x);
        end

        K=10;
        indx1=1:length(class1);
        indx2=1:length(class2);
        ind1=round(linspace(1,length(class1),K+1));
        ind2=round(linspace(1,length(class2),K+1));
        Ftrain1=[];Ftrain2=[];Ftest1=[];Ftest2=[];
        PERF=[];
        for k=1:K
            a=indx1;
            b=indx1(ind1(k)):indx1(ind1(k+1)-1);
            a(b)=[];
            Ftest1=F1(:,b);
            Ftrain1=F1(:,a);
            a=indx2;
            b=indx2(ind2(k)):indx2(ind2(k+1)-1);
            a(b)=[];
            Ftest2=F2(:,b);
            Ftrain2=F2(:,a);
            Ftrain=[Ftrain1,Ftrain2]';
            Ftest=[Ftest1,Ftest2]';
            GroupTR=[zeros(1,size(Ftrain1,2)),ones(1,size(Ftrain2,2))]';
            GroupTE=[zeros(1,size(Ftest1,2)),ones(1,size(Ftest2,2))]';
            SVMStruct = svmtrain(Ftrain,GroupTR);
            pred=svmclassify(SVMStruct,Ftest);
            perf=sum(pred==GroupTE)/length(GroupTE);
            PERF(k)=perf;
        end
        PerfTOT=mean(PERF);
        PERFORMANCE(isub)=PerfTOT;
        disp(['Subject ',name(isub),' Performance:',num2str(PerfTOT)]);
    end
    disp(['Mean Performance:',num2str(mean(PERFORMANCE))]);
end