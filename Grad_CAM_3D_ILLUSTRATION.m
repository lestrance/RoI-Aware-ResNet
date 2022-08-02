clc
close all
clear 
hold on

load('Trained_Mod_ResNet_18_3D_211101_T70.mat')
load('trained_3D_ResNet50_2021_Submission.mat')

net = Trained_3D_ResNet50_SPGC_2021_11_01;
net2 = Trained_3D_ResNet50_For_Submission;
%analyzeNetwork(net)

%img = matRead_2('D:\DownLoads\ChromeDownloads\SPGC-COVID\4D_Volume\T\NP\N0288.mat');
img = matRead('C:\Users\Roy XUE\Documents\MATLAB\COVID_SPGC_Further_Research\Preprocessed_Mat_09_15\T70\COVID\P011.mat');
%img = matRead_2('D:\DownLoads\ChromeDownloads\SPGC-COVID\4D_Volume\T\CAP\C0205_Aug.mat');


[classfn, score] = classify(net, img);



activationlayers_3d_resnet50 = {'res5b_relu'};
len_layers = size(activationlayers_3d_resnet50);
len_layers = len_layers(1);


%for i = 1:len_layers
    
    imgActivations = activations(net, img, activationlayers_3d_resnet50{1,1});
    scores = squeeze(mean(imgActivations,[1 2 3]));
    
    [~,classIds] = maxk(scores,3);
    

    classActivationMap = imgActivations(:,:,:,classIds(1));
    label_activation = imresize3(classActivationMap, [224,224,224], 'linear');
    %label_activation_INT = round(normalizeImage(label_activation));
    label_activation_INT = normalizeImage(label_activation);

    t_label = 0.45;
    label_activation_INT(label_activation_INT>=t_label) = 1;
    label_activation_INT(label_activation_INT<t_label) = 0;
    label_activation_categorical = categorical(label_activation_INT);
    
    viewPnl = uipanel(figure,'Title','Labeled Training Volume');

    num_slice = size(img);
    num_slice = num_slice(end);

    for i = 1:num_slice

        img(:,:,i) = imadjust(img(:,:,i), [0 0.4]);


    end

    hPred = labelvolshow(label_activation_categorical, img, 'Parent',viewPnl);
    hPred.LabelVisibility(1) = 0;
    hPred.LabelOpacity(1) = 1;
    hPred.LabelColor = [1 0 0; 0.8660 0.6740 0.1880];


    set(gcf, 'Position',  [800, 800, 550, 500])

%% Compared CAM


activationlayers_3d_resnet50 = {'activation_49_relu'};
len_layers = size(activationlayers_3d_resnet50);
len_layers = len_layers(1);

    imgActivations = activations(net2, img, activationlayers_3d_resnet50{1,1});
    scores = squeeze(mean(imgActivations,[1 2 3]));
    
    [~,classIds] = maxk(scores,3);
    

    classActivationMap = imgActivations(:,:,:,classIds(1));
    label_activation = imresize3(classActivationMap, [224,224,224], 'linear');
    %label_activation_INT = round(normalizeImage(label_activation));
    label_activation_INT = normalizeImage(label_activation);

    t_label = 0.4;
    label_activation_INT(label_activation_INT>=t_label) = 1;
    label_activation_INT(label_activation_INT<t_label) = 0;
    label_activation_categorical = categorical(label_activation_INT);
    
 

    viewPnl = uipanel(figure,'Title','Labeled Training Volume');

    num_slice = size(img);
    num_slice = num_slice(end);

    for i = 1:num_slice

        img(:,:,i) = imadjust(img(:,:,i), [0.1 0.8]);


    end

    hPred = labelvolshow(label_activation_categorical, img, 'Parent',viewPnl);
    hPred.LabelVisibility(1) = 0;
    hPred.LabelOpacity(1) = 1;
    hPred.LabelColor = [1 0 0; 0.8660 0.6740 0.1880];


    set(gcf, 'Position',  [800, 800, 550, 500])