% clc
clear all
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
Method = {'LLaplacian','SLaplacian'};
for i_method = 1:size(Method,2)
    disp('')
    disp([Method(i_method)]);
    PERFORMANCE=[];
    isub=1;
    dirc=[d2,name(isub),'_100Hz.mat'];
    load(dirc);
    cnt= 0.1*double(cnt);
    Fs=100;
    [b,a]=butter(3,[8 30]/(Fs/2),'bandpass');
    Signal=filtfilt(b,a,cnt);
    %% spatial filtering
    Signal=SpatialFilter(Signal,plane,Method(i_method),[27,31]);
    disp('filtered done')
end