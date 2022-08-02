clc
close all
clear



%% 4D volume data directory 

train_dir = 'C:\Users\Roy XUE\Documents\MATLAB\COVID_SPGC_Further_Research\Preprocessed_Mat_09_15\T80\Fullset';
%valid_dir = 'D:\DownLoads\ChromeDownloads\SPGC-COVID\4D_Volume\V';
%test_dir = 'C:\Users\Roy XUE\Documents\MATLAB\COVID_SPGC_Further_Research\Preprocessed_Mat_09_15\T60\EXP04\Test';




%% ImageDatastore creation
train_imds = imageDatastore(train_dir, 'IncludeSubfolders', true, 'Labelsource','foldernames', ...
   'FileExtensions','.mat','ReadFcn',@(x) matRead(x));

%valid_imds = imageDatastore(valid_dir, 'IncludeSubfolders', true, 'Labelsource','foldernames', ...
%   'FileExtensions','.mat','ReadFcn',@(x) matRead(x));

%test_imds = imageDatastore(test_dir, 'IncludeSubfolders', true, 'Labelsource','foldernames', ...
%   'FileExtensions','.mat','ReadFcn',@(x) matRead(x));

[train_imds, valid_imds] = splitEachLabel(train_imds, 0.8, 'randomized');
%[train_imds, valid_imds] = splitEachLabel(train_imds, 0.75, 'randomized');
%[valid_imds, t_imds_v] = splitEachLabel(valid_imds, 0.75, 'randomized');
%% Loading the pre-trained 3D_ResNet50

%ResNet50_3d = resnet50TL3Dfun();


%% Trimed the Network for transfer learning

% This section is processed using MATLAB Deep Network Designer Toolbox; 

%% Train the 3D CNN 

%load('ResNet18_3D_TF.mat')
load('Mod_ResNet_101_3D_TF.mat')



opts = trainingOptions('adam', ...
    'LearnRateSchedule', 'piecewise',...
    'Shuffle', 'every-epoch', ...
    'LearnRateDropFactor',0.2, ...
    'LearnRateDropPeriod',15, ...
    'InitialLearnRate', 0.0001,... 
    'MaxEpochs', 35, ...
    'MiniBatchSize', 2, ...
    'ValidationData',valid_imds, ...
    'ValidationFrequency',100, ...
    'Plots', 'training-progress');



Trained_3D_ResNet101_2021_11_07_T80 = trainNetwork(train_imds, lgraph_1, opts);

%[labels,err_test] = classify(Trained_3D_ResNet18_2021_11_02_Fold03, test_imds, 'MiniBatchSize', 2);
%confusionchart(test_imds.Labels, labels);
%set(gcf,'position', [400 400 450 400]);

