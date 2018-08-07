% clc
clear all
[d1,name,ext]=fileparts(which(mfilename));
d2=[d1,'\Datasets\BCICIV_calib_ds1'];
Nsub=7;
name='abcdefg';
PERFORMANCE=[];
FilterBand = linspace(4,40,10);
Ncls=2;
Band = 8;
m=3;
NFeature = 2;
PerfTot=[];
N_F=2*m*Band;
Nch=59;
PairIND=[];
for i_band=1:Band
    PairIND=[PairIND,[((i_band-1)*2*m+1):((i_band-1)*2*m+m);(((i_band-1)*2*m+2*m):-1:((i_band-1)*2*m+2*m)-m+1)]];
end
Cutofflow = [6.788, 8.273, 10.089, 12.295, 14.993, 18.252, 22.274, 27.153 ];
Cutoffhigh = [9.428, 11.491, 14.013, 17.077, 20.824, 25.35, 30.936, 37.713 ];

for isub=1:Nsub;
    %% initialize parameter
    dirc=[d2,name(isub),'_100Hz.mat'];
    load(dirc)
    cnt= 0.1*double(cnt);
    Fs=100;
    Signal = {};
    pos=mrk.pos;
    y=mrk.y;
    class1 = {} ;
    class1_train = {};
    class1_test = {};
    class2 = {} ;
    class2_train = {};
    class2_test = {};
    W = {};
    Ftrain1={};
    Ftrain2={};
    Ftest1={};
    Ftest2={};
    
    for i_band=1:Band
        %% for each band
        Ftrain1{i_band} = [] ;
        Ftrain2{i_band} = [] ;
        Ftest1{i_band} = [] ;
        Ftest2{i_band} = [] ;
        class1{i_band}=[];
        class2{i_band}=[];
    end
    %% segmenting the signals
    cntr1 = 0;
    cntr2 = 0;
    for i=1:length(pos)
        indx=pos(i)+100:pos(i)+400;
        if y(i)==1
            cntr1=cntr1+1;
            for i_band=1:Band
                [b,a] = cheby2(4,30,[Cutofflow(i_band)/(Fs/2) Cutoffhigh(i_band)/(Fs/2)]);
                class1{i_band}{cntr1} = filtfilt(b,a,cnt(indx,:));
            end
        else
            cntr2=cntr2+1;
            for i_band=1:Band
                [b,a] = cheby2(4,30,[Cutofflow(i_band)/(Fs/2) Cutoffhigh(i_band)/(Fs/2)]);
                class2{i_band}{cntr2} = filtfilt(b,a,cnt(indx,:));
            end
        end
    end
    Perf = [];
    for i_itr =1 : 10
         Ftrain1={};Ftrain2={};Ftest1={};Ftest2={};
         for i_band=1:Band
            Ftrain1{i_band} = [] ;
            Ftrain2{i_band} = [] ;
            Ftest1{i_band} = [] ;
            Ftest2{i_band} = [] ;
         end
        %%
        [train_c1 , test_c1] = crossvalind('HoldOut', size(class1{i_band},2), 0.25);
        [train_c2 , test_c2] = crossvalind('HoldOut', size(class2{i_band},2), 0.25);
        for i_band=1:Band
            %% Split into train and test
            class1_train{i_band} =  class1{i_band}(train_c1);
            class1_test{i_band}  =  class1{i_band}(test_c1);
            class2_train{i_band} =  class2{i_band}(train_c2);
            class2_test{i_band}  =  class2{i_band}(test_c2);

            %% computing spatial filter and converting it
            [ W{i_band} ] = MyCSP(class1_train{i_band},class2_train{i_band},m);
            for i=1:length(class1_train{i_band})
                x = class1_train{i_band}{i} ;
                y = x * W{i_band} ;
                f = log(var(y)) ;
                Ftrain1{i_band} =   [Ftrain1{i_band}    ;   f];
            end
            for i=1:length(class2_train{i_band})
                x=class2_train{i_band}{i};
                y = x * W{i_band} ;
                f = log(var(y));
                Ftrain2{i_band} =   [Ftrain2{i_band}    ;   f];
            end
            % for test
            for i=1:length(class1_test{i_band})
                x = class1_test{i_band}{i} ;
                y = x * W{i_band} ;
                f = log(var(y));
                Ftest1{i_band} =   [Ftest1{i_band}    ;   f];
            end
            for i=1:length(class2_test{i_band})
                x=class2_test{i_band}{i};
                y = x * W{i_band} ;
                f = log(var(y));
                Ftest2{i_band} =   [Ftest2{i_band}    ;   f];
            end
        end
        % Train
        FVTrain1 = [];
        FVTrain2 = [];
        FVBandName = [];
        for i_band=1:Band
            FVTrain1 = [FVTrain1 , Ftrain1{i_band}];
            FVTrain2 = [FVTrain2 , Ftrain2{i_band}];        
            FVBandName = [FVBandName , i_band *    ones(1,size(Ftrain1{i_band},2))];
        end
        
        FeatureVectorTrain = [FVTrain1 ; FVTrain2];
        LabelsTrain = [ones(1,size(FVTrain1,1)),2*ones(1,size(FVTrain2,1))]';
        %% Test
        FVTest1 = [];
        FVTest2 = [];
        for i_band=1:Band
            FVTest1 = [FVTest1 , Ftest1{i_band}];
            FVTest2 = [FVTest2 , Ftest2{i_band}];        
        end
        FeatureVectorTest = [FVTest1 ; FVTest2];
        LabelsTest = [ones(1,size(FVTest1,1)),2*ones(1,size(FVTest2,1))]';

        score=[];
        for i_dim=1:size(FeatureVectorTrain,2)
            score(i_dim)=myMUT2(FeatureVectorTrain(:,i_dim)',LabelsTrain');
        end

        %% Sort the scores
        
        [mm ,ind] = sort(score,'descend');
        Selected=[];
        cnt=0;
        while length(Selected)<NFeature
            cnt=cnt+1;
            [a,b]=find(ind(cnt)==PairIND);
            cond=0;
            for i=1:size(PairIND,1)
                cond=cond+sum(Selected==PairIND(i,b));
            end
            if cond==0
                Selected=[Selected,PairIND(:,b)];
            end
        end
        

        %% SVM Classification
        FeatureTrain = FeatureVectorTrain(:,Selected);
        FeatureTest = FeatureVectorTest(:,Selected);
        
        option1 = statset('MaxIter',150000);
        SVMStruct=svmtrain(FeatureTrain,LabelsTrain,'kernel_function','linear','options',option1);

        Predict_lbl = svmclassify(SVMStruct,FeatureTest);
        acc=sum(Predict_lbl== LabelsTest)/length(LabelsTest);
        Perf(i_itr) = acc;
        
    end
    disp(['Mean Acc for subjec : ',num2str(isub),'is :',num2str(mean(Perf))])
    PerfTot(isub)=mean(Perf);
end
disp(['Mean Ac is :',num2str(mean(PerfTot))])
