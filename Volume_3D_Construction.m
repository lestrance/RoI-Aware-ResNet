clc 
close all
clear 

%% Stage-1 : Create MATfile from the original DICOM files
% Dicom_Dir = fullfile('/home/COVID-CT-MD'); % DICOM Dir
% 
% Mat_Save_Dir = fullfile('MatFIles_3D_Volumes/');
% 
% 
% imds = imageDatastore(Dicom_Dir, 'IncludeSubfolders', true, 'FileExtensions', '.dcm', 'LabelSource', 'foldernames');
% 
% 
% labels_imds = countEachLabel(imds); 
% 
% 
% Dicom_volume_folders = unique(fileparts(imds.Files));
% 
% 
% num_labels = length(Dicom_volume_folders);
% 
% 
% 
% for i = 1:2 %num_labels
%    
%     data = dicomreadVolume(Dicom_volume_folders{i});
%     
%     First_dicomfile = strcat(Dicom_volume_folders{i}, '/IM0001.dcm');
%     
%     SPECTinfo = dicominfo(First_dicomfile);
%     PixelSpacing = SPECTinfo.PixelSpacing;  
%     SliceThickness = SPECTinfo.SliceThickness;  
%     
%     
%     
%     % Volume Resampling
%     %data = volume_resample(data, SPECTPixelSpacing, SPECTSliceThickness);
%     
%     % Pulmonary Segmentation and Slice Range Selection
%     %data = matRead_LungSegMask_SliceSelect_Compact_224(data);
%     
%     
%     matFileName = strcat(Mat_Save_Dir, string(labels_imds{i,1}));
%     %save(matFileName,'data', 'PixelSpacing', 'SliceThickness');  % Save
%     %MAT files into the mat_directory
%     
% end

%% Stage-2 : Preprocessing the MAT files into the input data ready for training the 3D network

covid_dir = fullfile('MatFIles_3D_Volumes/covid');

imds_covid = imageDatastore(covid_dir, 'FileExtensions', '.mat');

num_covid = length(imds_covid.Files);



cap_dir = fullfile('MatFIles_3D_Volumes/cap');

imds_cap = imageDatastore(cap_dir, 'FileExtensions', '.mat');

num_cap = length(imds_cap.Files);


np_dir = fullfile('MatFIles_3D_Volumes/normal');

imds_np = imageDatastore(np_dir, 'FileExtensions', '.mat');

num_np = length(imds_np.Files);


% Volume Area Percentage Thresholding


for it = 1:3
    
    VA_t = [0.6; 0.7; 0.8];
    VA_t = VA_t(it);

%% COVID cases
for i = 1: num_covid
    
    [data, PixelSpacing, SliceThickness] = VolumeMatRead(imds_covid.Files{i,1});
    data = mat2gray(squeeze(data));       % HU values to gragscale image
    data_dim = size(data);
    seg_data = zeros(data_dim);
    
    for j = 1 : data_dim(3)
 
        [mask, seg_data(:,:,j)] = lung_region(data(:,:,j)); % pulmonary segmentation
        
    end
    
    SpacingCoefficient = 1.7 + 0.6 * rand(1,1);
    ThicknessCoefficient = 0.45 + 0.2 * rand(1,1);
    resampled_data = volume_resample(seg_data, PixelSpacing, SpacingCoefficient, SliceThickness, ThicknessCoefficient);
    
    [d1, d2, d3] = size(resampled_data);
    lungarea = zeros(d3, 1);
    
    for k = 1:d3
        
        lung_mask = resampled_data(:,:,k)>0;
       
        lungarea(k,1) = lungarea_detect(lung_mask);
        
    end
    
    max_lungarea_value = max(lungarea);
    lungarea = lungarea ./ max_lungarea_value;
    
    selected_slice = find(lungarea >= VA_t);
    new_data = resampled_data(:,:,selected_slice(1) : selected_slice(end));
    [d1_new, d2_new, d3_new] = size(new_data);
    
    
    
    crop_coefficient = 1- 0.25 * rand(1,1);
    target_cropsize = [round(d1_new * crop_coefficient), round(d2_new * crop_coefficient), d3_new];
    win_crop = centerCropWindow3d(size(new_data), target_cropsize);
    crop_data = imcrop3(new_data, win_crop);
    inputdata = imresize3(crop_data, [224 224 224], 'cubic');
    
    inputdata(isnan(inputdata)) = 0;
    inputdata(inputdata <= 0) = 0;
    
    [matfile_path, matfile_name, matfile_ext] = fileparts(imds_covid.Files{i,1});
    Folder_covid = strcat('Preprocessed_Mat_09_15\covid\Volume',string(VA_t*100),'\');
    if exist(Folder_covid) == 0
        mkdir(Folder_covid)
    end
    MatFileName_Training_covid = strcat(Folder_covid, matfile_name);
    
    
    save(MatFileName_Training_covid,'inputdata');
    
    % DataAugmentation
    Aug_data = imrotate3(inputdata, 3 * randi([-4 4]), [0 0 1], 'crop', 'FillValues', 0);
    
    Aug_data = imresize3(Aug_data, [224 224 224], 'cubic');
    Aug_data(isnan(Aug_data)) = 0;
    Aug_data(Aug_data <= 0) = 0;
    
    MatFileName_Training_covid = strcat(Folder_covid, matfile_name, '_Aug');
    save(MatFileName_Training_covid,'Aug_data');
end

%% Normal patients
for i = 1: num_np
    
    [data, PixelSpacing, SliceThickness] = VolumeMatRead(imds_np.Files{i,1});
    data = mat2gray(squeeze(data));       % HU values to gragscale image
    data_dim = size(data);
    seg_data = zeros(data_dim);
    
    for j = 1 : data_dim(3)
 
        [mask, seg_data(:,:,j)] = lung_region(data(:,:,j)); % pulmonary segmentation
        
    end
    
    SpacingCoefficient = 1.7 + 0.6 * rand(1,1);
    ThicknessCoefficient = 0.45 + 0.2 * rand(1,1);
    resampled_data = volume_resample(seg_data, PixelSpacing, SpacingCoefficient,  SliceThickness, ThicknessCoefficient);
    
    [d1, d2, d3] = size(resampled_data);
    lungarea = zeros(d3, 1);
    
    for k = 1:d3
        
        lung_mask = resampled_data(:,:,k)>0;
       
        lungarea(k,1) = lungarea_detect(lung_mask);
        
    end
    
    max_lungarea_value = max(lungarea);
    lungarea = lungarea ./ max_lungarea_value;
    
    selected_slice = find(lungarea >= VA_t);
    new_data = resampled_data(:,:,selected_slice(1) : selected_slice(end));
    [d1_new, d2_new, d3_new] = size(new_data);
    
    crop_coefficient = 1- 0.25 * rand(1,1);
    target_cropsize = [round(d1_new * crop_coefficient), round(d2_new * crop_coefficient), d3_new];
    win_crop = centerCropWindow3d(size(new_data), target_cropsize);
    crop_data = imcrop3(new_data, win_crop);
    inputdata = imresize3(crop_data, [224 224 224], 'cubic');
    
    inputdata(isnan(inputdata)) = 0;
    inputdata(inputdata <= 0) = 0;  
    
    [matfile_path, matfile_name, matfile_ext] = fileparts(imds_np.Files{i,1});
    Folder_np = strcat('Preprocessed_Mat_09_15\np\Volume',string(VA_t*100),'\');
    if exist(Folder_np) == 0
        mkdir(Folder_np)
    end
    MatFileName_Training_np = strcat(Folder_np, matfile_name);
    save(MatFileName_Training_np,'inputdata');
    
    % DataAugmentation
    Aug_data = imrotate3(inputdata, 3 * randi([-4 4]), [0 0 1], 'crop', 'FillValues', 0);
    Aug_data_2 = imrotate3(new_data, 3 * randi([-4 4]), [0 0 1], 'crop', 'FillValues', 0);
    
    Aug_data = imresize3(Aug_data, [224 224 224], 'cubic');
    Aug_data_2 = imresize3(Aug_data_2, [224 224 224], 'cubic');
    Aug_data(isnan(Aug_data)) = 0;
    Aug_data(Aug_data <= 0) = 0;
    Aug_data_2(isnan(Aug_data_2)) = 0;
    Aug_data_2(Aug_data_2 <= 0) = 0;
    
    MatFileName_Training_np = strcat(Folder_np, matfile_name, '_Aug');
    save(MatFileName_Training_np,'Aug_data');
    MatFileName_Training_np = strcat(Folder_np, matfile_name, '_Aug_2');
    save(MatFileName_Training_np,'Aug_data_2');
end



for i = 1: num_cap
    
    [data, PixelSpacing, SliceThickness] = VolumeMatRead(imds_cap.Files{i,1});
    data = mat2gray(squeeze(data));       % HU values to gragscale image
    data_dim = size(data);
    seg_data = zeros(data_dim);
    
    for j = 1 : data_dim(3)
 
        [mask, seg_data(:,:,j)] = lung_region(data(:,:,j)); % pulmonary segmentation
        
    end
    
    SpacingCoefficient = 1.7 + 0.6 * rand(1,1);
    ThicknessCoefficient = 0.45 + 0.2 * rand(1,1);
    resampled_data = volume_resample(seg_data, PixelSpacing, SpacingCoefficient,  SliceThickness, ThicknessCoefficient);
    
    [d1, d2, d3] = size(resampled_data);
    lungarea = zeros(d3, 1);
    
    for k = 1:d3
        
        lung_mask = resampled_data(:,:,k)>0;
       
        lungarea(k,1) = lungarea_detect(lung_mask);
        
    end
    
    max_lungarea_value = max(lungarea);
    lungarea = lungarea ./ max_lungarea_value;
    
    selected_slice = find(lungarea >= VA_t);
    new_data = resampled_data(:,:,selected_slice(1) : selected_slice(end));
    [d1_new, d2_new, d3_new] = size(new_data);
    
    
    
    crop_coefficient = 1- 0.25 * rand(1,1);
    target_cropsize = [round(d1_new * crop_coefficient), round(d2_new * crop_coefficient), d3_new];
    win_crop = centerCropWindow3d(size(new_data), target_cropsize);
    crop_data = imcrop3(new_data, win_crop);
    inputdata = imresize3(crop_data, [224 224 224], 'cubic');
    inputdata(isnan(inputdata)) = 0;
    inputdata(inputdata <= 0) = 0;
    
    [matfile_path, matfile_name, matfile_ext] = fileparts(imds_cap.Files{i,1});
    Folder_cap = strcat('Preprocessed_Mat_09_15\cap\Volume',string(VA_t*100),'\');
    if exist(Folder_cap) == 0
        mkdir(Folder_cap)
    end
    MatFileName_Training_cap = strcat(Folder_cap, matfile_name);
    save(MatFileName_Training_cap,'inputdata');
    
    % DataAugmentation
    Aug_data = imrotate3(inputdata, 3 * randi([-4 4]), [0 0 1], 'crop', 'FillValues', 0);
    Aug_data_2 = imrotate3(new_data, 3 * randi([-4 4]), [0 0 1], 'crop', 'FillValues', 0);
    

    
    Aug_data = imresize3(Aug_data, [224 224 224], 'cubic');
    Aug_data_2 = imresize3(Aug_data_2, [224 224 224], 'cubic');
    Aug_data(isnan(Aug_data)) = 0;
    Aug_data(Aug_data <= 0) = 0;
    Aug_data_2(isnan(Aug_data_2)) = 0;
    Aug_data_2(Aug_data_2 <= 0) = 0;
    
    
    MatFileName_Training_cap = strcat(Folder_cap, matfile_name, '_Aug');
    save(MatFileName_Training_cap,'Aug_data');
    MatFileName_Training_cap = strcat(Folder_cap, matfile_name, '_Aug_2');
    save(MatFileName_Training_cap,'Aug_data_2');
end
end