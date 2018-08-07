clc
clear all
[d1,name,ext]=fileparts(which(mfilename));
d2=[d1,'\Datasets\BCICIV_calib_ds1'];
Nsub=7;
name='abcdefg';
PERFORMANCE=[];
alpha = [0 power(10,-10) 5*power(10,-10) power(10,-5) 5*power(10,-5) power(10,-4) 0.001 0.005 0.01 0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 5 10 50 100];
PerformanceAlpha = [];
for isub=1:Nsub;
    %% load subject data
    dirc=[d2,name(isub),'_100Hz.mat'];
    load(dirc)
    cnt= 0.1*double(cnt);
    Fs=100;
    %%filter raw data
    [b,a]=butter(3,[8 30]/(Fs/2),'bandpass');
    Signal=filtfilt(b,a,cnt);
    pos=mrk.pos;
    y=mrk.y;
    class1=[];class2=[];
    cntr1=0;cntr2=0;
    for i=1:length(pos)
        indx=pos(i)+100:pos(i)+400;
        if y(i)==1
            cntr1=cntr1+1;
            class1{cntr1}=Signal(indx,:);
        else
            cntr2=cntr2+1;
            class2{cntr2}=Signal(indx,:);
        end
    end
    %% split data into train and test
    [train , test] = crossvalind('HoldOut', size(class1,2), 0.25);
    testClass1 = class1(test);
    class1 = class1(train);

    [train , test] = crossvalind('HoldOut', size(class2,2), 0.25);
    testClass2 = class2(test);
    class2 = class2(train);
    %% find best alpha with 10-fold
    K=10;
    % random indices
    indx1= crossvalind('Kfold', length(class1) , K);
    indx2= crossvalind('Kfold', length(class2) , K);
    ind1=round(linspace(1,length(class1),K+1));
    ind2=round(linspace(1,length(class2),K+1));
    Ftrain1=[];Ftrain2=[];Ftest1=[];Ftest2=[];
    for i_alpha =1:length(alpha)
        PERF=[];
        for k=1:K
            % Class 1            
            Xtr1=class1(indx1 ~= k);
            Xte1=class1(indx1 == k);

            % Class 2
            Xtr2=class2(indx2 ~= k);
            Xte2=class2(indx2 == k);
            m=1;
            [W] = MyTRCSP(Xtr1,Xtr2,m,alpha(i_alpha));
            Ftrain1=[];Ftrain2=[];
            Ftest1=[];Ftest2=[];
            %% Training 1
            for i=1:length(Xtr1)
                x=Xtr1{i};
                y=x*W;
                f=var(y);
                Ftrain1=[Ftrain1;f];
            end
            %% Training 2
            for i=1:length(Xtr2)
                x=Xtr2{i};
                y=x*W;
                f=var(y);
                Ftrain2=[Ftrain2;f];
            end
            %% Test 1
            for i=1:length(Xte1)
                x=Xte1{i};
                y=x*W;
                f=var(y);
                Ftest1=[Ftest1;f];
            end
            %% Test 2
            for i=1:length(Xte2)
                x=Xte2{i};
                y=x*W;
                f=var(y);
                Ftest2=[Ftest2;f];
            end

            Ftrain=[Ftrain1;Ftrain2];
            Ftest=[Ftest1;Ftest2];
            GroupTR=[zeros(1,size(Ftrain1,1)),ones(1,size(Ftrain2,1))]';
            GroupTE=[zeros(1,size(Ftest1,1)),ones(1,size(Ftest2,1))]';
            
            SVMStruct = svmtrain(Ftrain,GroupTR);
            % performance on validation data
            pred=svmclassify(SVMStruct,Ftest);
            perf=sum(pred==GroupTE)/length(GroupTE);
            PERF(k)=perf;
        end
        PerformanceAlpha(isub,i_alpha)=  mean(PERF);
        disp(['Subject ',name(isub),' Performance with ',num2str(alpha(i_alpha)),'alpha :',num2str(PerformanceAlpha(isub,i_alpha))]);
    end
    % find best performance 
    [ dontcare , index ] = max(PerformanceAlpha(isub,:));
    [W] = MyTRCSP(class1,class2,m,alpha(index));
    Ftrain1=[];Ftrain2=[];
    Ftest1=[];Ftest2=[];
    %% Training 1
    for i=1:length(class1)
        x=class1{i};
        y=x*W;
        f=var(y);
        Ftrain1=[Ftrain1;f];
    end
    %% Training 2
    for i=1:length(class2)
        x=class2{i};
        y=x*W;
        f=var(y);
        Ftrain2=[Ftrain2;f];
    end
    %% Test 1
    for i=1:length(testClass1)
        x=testClass1{i};
        y=x*W;
        f=var(y);
        Ftest1=[Ftest1;f];
    end
    %% Test 2
    for i=1:length(testClass2)
        x=testClass2{i};
        y=x*W;
        f=var(y);
        Ftest2=[Ftest2;f];
    end
    Ftrain=[Ftrain1;Ftrain2];
    Ftest=[Ftest1;Ftest2];
    GroupTR=[zeros(1,size(Ftrain1,1)),ones(1,size(Ftrain2,1))]';
    GroupTE=[zeros(1,size(Ftest1,1)),ones(1,size(Ftest2,1))]';
    SVMStruct = svmtrain(Ftrain,GroupTR);
    % performance on Test data
    pred=svmclassify(SVMStruct,Ftest);
    perf=sum(pred==GroupTE)/length(GroupTE);
    disp(['Performance with alpha ',num2str(alpha(index)),'on test data :',num2str(perf)]);
    PERFORMANCE(isub) = perf;
end
disp(['Mean Performance :',num2str(mean(PERFORMANCE))]);
