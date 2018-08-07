clc
clear all
[d1,name,ext]=fileparts(which(mfilename));
d2=[d1,'\Datasets\BCICIV_calib_ds1'];
Nsub=7;
name='abcdefg';
PERFORMANCE=[];
regularizer_coef = [];
regularizer_coef = [0.00,0.05,0.1,0.15,0.2];
PerformanceRegularizer = [];
for isub=2:Nsub;
    %% load subject data
    dirc=[d2,name(isub),'_100Hz.mat'];
    load(dirc)
    cnt= 0.1*double(cnt);
    Fs=100;
    %%filter raw data
    [b,a]=butter(3,[8 30]/(Fs/2),'bandpass');
    %[b,a] = cheby2(4,20,[8/(Fs/2) 30/(Fs/2)]);
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
    
    %% find best Regularizer with 10-fold
    K=10;
    % random indices
    indx1= crossvalind('Kfold', length(class1) , K);
    indx2= crossvalind('Kfold', length(class2) , K);
%     ind1=round(linspace(1,length(class1),K+1));
%     ind2=round(linspace(1,length(class2),K+1));
    SparseIndeces = {};
    Ftrain1=[];Ftrain2=[];Ftest1=[];Ftest2=[];
    for i_regularizer =1:length(regularizer_coef)
        [ W_Sparse ] = SCSP_OPTIMIZER({class1,class2},1,regularizer_coef(i_regularizer));
        choosedIndex = find(abs(sum(W_Sparse)) > 10e-6);
        SparseIndeces{i_regularizer} = choosedIndex;
        
        for i=1:length(class1)
            FoldTrainClass1{i} = class1{i}(:,choosedIndex);
        end
        for i=1:length(class2)
            FoldTrainClass2{i} = class2{i}(:,choosedIndex);
        end
        PERF=[];
        for i_iteration = 1 : 10
            indx1= crossvalind('Kfold', length(class1) , K);
            indx2= crossvalind('Kfold', length(class2) , K);
            PerfK = [];
            for k=1:K
                % Class 1            
                Xtr1=FoldTrainClass1(indx1 ~= k);
                Xte1=FoldTrainClass1(indx1 == k);

                % Class 2
                Xtr2=FoldTrainClass2(indx2 ~= k);
                Xte2=FoldTrainClass2(indx2 == k);
                m=3;
                [W] = MultiCSP({Xtr1,Xtr2},m);
                Ftrain1=[];Ftrain2=[];
                Ftest1=[];Ftest2=[];
                %% Training 1
                for i=1:length(Xtr1)
                    x=Xtr1{i};
                    y=x*W';
                    f=var(y);
                    Ftrain1=[Ftrain1;f];
                end
                %% Training 2
                for i=1:length(Xtr2)
                    x=Xtr2{i};
                    y=x*W';
                    f=var(y);
                    Ftrain2=[Ftrain2;f];
                end
                %% Test 1
                for i=1:length(Xte1)
                    x=Xte1{i};
                    y=x*W';
                    f=var(y);
                    Ftest1=[Ftest1;f];
                end
                %% Test 2
                for i=1:length(Xte2)
                    x=Xte2{i};
                    y=x*W';
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
                %PERF(i_iteration)=perf;
                PerfK(k) = perf;
            end
            PERF(i_iteration) = mean(PerfK);
        end
        disp(['Subject ',name(isub),' Performance with ',num2str(regularizer_coef(i_regularizer)),'Regularizer :',num2str(mean(mean(PERF)))]);
        figure
        plot(PERF);
        PerformanceRegularizer(i_regularizer) = mean(PERF);
    end
    % find best performan 
    [ dontcare , index ] = max(PerformanceRegularizer(:));
    
    for i=1:length(class1)
        SparseTrainClass1{i} = class1{i}(:,SparseIndeces{index});
    end
    for i=1:length(testClass1)
        SparseTestClass1{i} = testClass1{i}(:,SparseIndeces{index});
    end
    for i=1:length(class2)
        SparseTrainClass2{i} = class2{i}(:,SparseIndeces{index});
    end
    for i=1:length(testClass2)
        SparseTestClass2{i} = testClass2{i}(:,SparseIndeces{index});
    end
    
    [W] = MultiCSP({SparseTrainClass1,SparseTrainClass2},m);
    Ftrain1=[];Ftrain2=[];
    Ftest1=[];Ftest2=[];
    %% Training 1
    for i=1:length(SparseTrainClass1)
        x=SparseTrainClass1{i};
        y=x*W';
        f=var(y);
        Ftrain1=[Ftrain1;f];
    end
    %% Training 2
    for i=1:length(SparseTrainClass2)
        x=SparseTrainClass2{i};
        y=x*W';
        f=var(y);
        Ftrain2=[Ftrain2;f];
    end
    %% Test 1
    for i=1:length(SparseTestClass1)
        x=SparseTestClass1{i};
        y=x*W';
        f=var(y);
        Ftest1=[Ftest1;f];
    end
    %% Test 2
    for i=1:length(SparseTestClass2)
        x=SparseTestClass2{i};
        y=x*W';
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
    disp(['Performance with Regularizer ',num2str(regularizer_coef(index)),'on test data :',num2str(perf)]);
    PERFORMANCE(isub) = perf;
end
disp(['Mean Performance :',num2str(mean(PERFORMANCE))]);
