clc
close all
clear 

%% 5-fold Training data directory

mat_dir = fullfile('C:\Users\Roy XUE\Documents\MATLAB\COVID_SPGC_Further_Research\Mat_08_01\');
output_dir = fullfile('C:\Users\Roy XUE\Documents\MATLAB\COVID_SPGC_Further_Research\Preprocessed_Mat_08_01\');

%% 

training_dir = {};
test_dir = {};

for i = 1 :5
    EXP_No = sprintf('EXP%d', i);
    training_dir{i} = strcat(mat_dir, EXP_No, '\Training');
    test_dir{i} = strcat(mat_dir, EXP_No, '\Test');

end

%% Creating the 5-fold training data imagedatastore


for ii = 1 : 5

covid_dir = strcat(training_dir{ii}, '\covid');

imds_covid = imageDatastore(covid_dir, 'FileExtensions', '.mat');

num_covid = length(imds_covid.Files);


cap_dir = strcat(training_dir{ii}, '\cap');

imds_cap = imageDatastore(cap_dir, 'FileExtensions', '.mat');

num_cap = length(imds_cap.Files);


np_dir = strcat(training_dir{ii}, '\normal');

imds_np = imageDatastore(np_dir, 'FileExtensions', '.mat');

num_np = length(imds_np.Files);

EXP_No = sprintf('EXP%d', ii);

%% Training Data preprocessing and augmentation

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
    resampled_data = volume_resample(seg_data, PixelSpacing, SpacingCoefficient,  SliceThickness, ThicknessCoefficient);
    
    [d1, d2, d3] = size(resampled_data);
    lungarea = zeros(d3, 1);
    
    for k = 1:d3
        
        lung_mask = resampled_data(:,:,k)>0;
       
        lungarea(k,1) = (lung_mask);
        
    end
    
    max_lungarea_value = max(lungarea);
    lungarea = lungarea ./ max_lungarea_value;
    
    selected_slice = find(lungarea >= 0.8);
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
    
    covid_training_dir = strcat(output_dir, EXP_No, '\Training\covid\');
    if exist(covid_training_dir) == 0
        mkdir(covid_training_dir)
    end
    
    MatFileName_Training_covid = strcat(output_dir, EXP_No, '\Training\covid\', matfile_name);
    save(MatFileName_Training_covid,'inputdata');
    
    % DataAugmentation
    Aug_data = imrotate3(inputdata, 3 * randi([-4 4]), [0 0 1], 'crop', 'FillValues', 0);
    
    % random flip
    Aug_rand = rand(1,1);
    if Aug_rand >= 0.6
        Aug_data = flip(Aug_data);
    end
    
    Aug_data = imresize3(Aug_data, [224 224 224], 'cubic');
    Aug_data(isnan(Aug_data)) = 0;
    Aug_data(Aug_data <= 0) = 0;
    
    MatFileName_Training_covid = strcat(output_dir, EXP_No, '\Training\covid\', matfile_name, '_Aug');
    save(MatFileName_Training_covid,'Aug_data');
end

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
    
    selected_slice = find(lungarea >= 0.8);
    new_data = resampled_data(:,:,selected_slice(1) : selected_slice(end));
    [d1_new, d2_new, d3_new] = size(new_data);
    
    crop_coefficient = 1- 0.25 * rand(1,1);
    target_cropsize = [round(d1_new * crop_coefficient), round(d2_new * crop_coefficient), d3_new];
    win_crop = centerCropWindow3d(size(new_data), target_cropsize);
    crop_data = imcrop3(new_data, win_crop);
    inputdata = imresize3(crop_data, [224 224 224], 'cubic');
    
    inputdata(isnan(inputdata)) = 0;
    inputdata(inputdata <= 0) = 0;  
    
    np_training_dir = strcat(output_dir, EXP_No, '\Training\np\');
    if exist(np_training_dir) == 0
        mkdir(np_training_dir)
    end
    
    [matfile_path, matfile_name, matfile_ext] = fileparts(imds_np.Files{i,1});
    MatFileName_Training_covid = strcat(output_dir, EXP_No, '\Training\np\', matfile_name);
    save(MatFileName_Training_covid,'inputdata');
    
    % DataAugmentation
    Aug_data = imrotate3(inputdata, 3 * randi([-4 4]), [0 0 1], 'crop', 'FillValues', 0);
    Aug_data_2 = imrotate3(new_data, 3 * randi([-4 4]), [0 0 1], 'crop', 'FillValues', 0);
    
    % random flip
    Aug_rand = rand(1,1);
    if Aug_rand >= 0.6
        Aug_data = flip(Aug_data);
        Aug_data_2 = flip(Aug_data_2);
    end
    
    Aug_data = imresize3(Aug_data, [224 224 224], 'cubic');
    Aug_data_2 = imresize3(Aug_data_2, [224 224 224], 'cubic');
    Aug_data(isnan(Aug_data)) = 0;
    Aug_data(Aug_data <= 0) = 0;
    Aug_data_2(isnan(Aug_data_2)) = 0;
    Aug_data_2(Aug_data_2 <= 0) = 0;
    
    MatFileName_Training_covid = strcat(output_dir, EXP_No, '\Training\np\', matfile_name, '_Aug');
    save(MatFileName_Training_covid,'Aug_data');
    MatFileName_Training_covid = strcat(output_dir, EXP_No, '\Training\np\', matfile_name, '_Aug_2');
    save(MatFileName_Training_covid,'Aug_data_2');
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
    
    selected_slice = find(lungarea >= 0.8);
    new_data = resampled_data(:,:,selected_slice(1) : selected_slice(end));
    [d1_new, d2_new, d3_new] = size(new_data);
    
    
    
    crop_coefficient = 1- 0.25 * rand(1,1);
    target_cropsize = [round(d1_new * crop_coefficient), round(d2_new * crop_coefficient), d3_new];
    win_crop = centerCropWindow3d(size(new_data), target_cropsize);
    crop_data = imcrop3(new_data, win_crop);
    inputdata = imresize3(crop_data, [224 224 224], 'cubic');
    inputdata(isnan(inputdata)) = 0;
    inputdata(inputdata <= 0) = 0;
    
    cap_training_dir = strcat(output_dir, EXP_No, '\Training\cap\');
    if exist(cap_training_dir) == 0
        mkdir(cap_training_dir)
    end
    
    [matfile_path, matfile_name, matfile_ext] = fileparts(imds_cap.Files{i,1});
    MatFileName_Training_covid = strcat(output_dir, EXP_No, '\Training\cap\', matfile_name);
    save(MatFileName_Training_covid,'inputdata');
    
    % DataAugmentation
    Aug_data = imrotate3(inputdata, 3 * randi([-4 4]), [0 0 1], 'crop', 'FillValues', 0);
    Aug_data_2 = imrotate3(new_data, 3 * randi([-4 4]), [0 0 1], 'crop', 'FillValues', 0);
    
    % random flip
    Aug_rand = rand(1,1);
    if Aug_rand >= 0.6
        Aug_data = flip(Aug_data);
        Aug_data_2 = flip(Aug_data_2);
    end
    
    Aug_data = imresize3(Aug_data, [224 224 224], 'cubic');
    Aug_data_2 = imresize3(Aug_data_2, [224 224 224], 'cubic');
    Aug_data(isnan(Aug_data)) = 0;
    Aug_data(Aug_data <= 0) = 0;
    Aug_data_2(isnan(Aug_data_2)) = 0;
    Aug_data_2(Aug_data_2 <= 0) = 0;
    
    
    MatFileName_Training_covid = strcat(output_dir, EXP_No, '\Training\cap\', matfile_name, '_Aug');
    save(MatFileName_Training_covid,'Aug_data');
    MatFileName_Training_covid = strcat(output_dir, EXP_No, '\Training\cap\', matfile_name, '_Aug_2');
    save(MatFileName_Training_covid,'Aug_data_2');
end


end

%% Creating the 5-fold test data imagedatastore


for ii = 1 : 5

covid_dir = strcat(test_dir{ii}, '\covid');

imds_covid = imageDatastore(covid_dir, 'FileExtensions', '.mat');

num_covid = length(imds_covid.Files);


cap_dir = strcat(test_dir{ii}, '\cap');

imds_cap = imageDatastore(cap_dir, 'FileExtensions', '.mat');

num_cap = length(imds_cap.Files);


np_dir = strcat(test_dir{ii}, '\normal');

imds_np = imageDatastore(np_dir, 'FileExtensions', '.mat');

num_np = length(imds_np.Files);

EXP_No = sprintf('EXP%d', ii);

%% Test Data preprocessing

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
    resampled_data = volume_resample(seg_data, PixelSpacing, SpacingCoefficient,  SliceThickness, ThicknessCoefficient);
    
    [d1, d2, d3] = size(resampled_data);
    lungarea = zeros(d3, 1);
    
    for k = 1:d3
        
        lung_mask = resampled_data(:,:,k)>0;
       
        lungarea(k,1) = lungarea_detect(lung_mask);
        
    end
    
    max_lungarea_value = max(lungarea);
    lungarea = lungarea ./ max_lungarea_value;
    
    selected_slice = find(lungarea >= 0.8);
    new_data = resampled_data(:,:,selected_slice(1) : selected_slice(end));
    [d1_new, d2_new, d3_new] = size(new_data);
    
    
    
    crop_coefficient = 1- 0.25 * rand(1,1);
    target_cropsize = [round(d1_new * crop_coefficient), round(d2_new * crop_coefficient), d3_new];
    win_crop = centerCropWindow3d(size(new_data), target_cropsize);
    crop_data = imcrop3(new_data, win_crop);
    inputdata = imresize3(crop_data, [224 224 224], 'cubic');
    
    inputdata(isnan(inputdata)) = 0;
    inputdata(inputdata <= 0) = 0;
    
    covid_test_dir = strcat(output_dir, EXP_No, '\Test\covid\');
    if exist(covid_test_dir) == 0
        mkdir(covid_test_dir)
    end
    
    [matfile_path, matfile_name, matfile_ext] = fileparts(imds_covid.Files{i,1});
    MatFileName_Training_covid = strcat(output_dir, EXP_No, '\Test\covid\', matfile_name);
    save(MatFileName_Training_covid,'inputdata');
    
end

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
    
    selected_slice = find(lungarea >= 0.8);
    new_data = resampled_data(:,:,selected_slice(1) : selected_slice(end));
    [d1_new, d2_new, d3_new] = size(new_data);
    
    crop_coefficient = 1- 0.25 * rand(1,1);
    target_cropsize = [round(d1_new * crop_coefficient), round(d2_new * crop_coefficient), d3_new];
    win_crop = centerCropWindow3d(size(new_data), target_cropsize);
    crop_data = imcrop3(new_data, win_crop);
    inputdata = imresize3(crop_data, [224 224 224], 'cubic');
    
    inputdata(isnan(inputdata)) = 0;
    inputdata(inputdata <= 0) = 0;  
    
    np_test_dir = strcat(output_dir, EXP_No, '\Test\np\');
    if exist(np_test_dir) == 0
        mkdir(np_test_dir)
    end
    
    [matfile_path, matfile_name, matfile_ext] = fileparts(imds_np.Files{i,1});
    MatFileName_Training_covid = strcat(output_dir, EXP_No, '\Test\np\', matfile_name);
    save(MatFileName_Training_covid,'inputdata');
    
    
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
    
    selected_slice = find(lungarea >= 0.8);
    new_data = resampled_data(:,:,selected_slice(1) : selected_slice(end));
    [d1_new, d2_new, d3_new] = size(new_data);
    
    
    
    crop_coefficient = 1- 0.25 * rand(1,1);
    target_cropsize = [round(d1_new * crop_coefficient), round(d2_new * crop_coefficient), d3_new];
    win_crop = centerCropWindow3d(size(new_data), target_cropsize);
    crop_data = imcrop3(new_data, win_crop);
    inputdata = imresize3(crop_data, [224 224 224], 'cubic');
    inputdata(isnan(inputdata)) = 0;
    inputdata(inputdata <= 0) = 0;
    
    cap_test_dir = strcat(output_dir, EXP_No, '\Test\cap\');
    if exist(cap_test_dir) == 0
        mkdir(cap_test_dir)
    end
    
    [matfile_path, matfile_name, matfile_ext] = fileparts(imds_cap.Files{i,1});
    MatFileName_Training_covid = strcat(output_dir, EXP_No, '\Test\cap\', matfile_name);
    save(MatFileName_Training_covid,'inputdata');
end


end
