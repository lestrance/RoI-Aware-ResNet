clc
close all
clear 


%% Test volume files into Matfiles
% test_dir = fullfile('D:\DownLoads\ChromeDownloads\SPGC-COVID\Test_Data');
% 
% for k = 1:4
% 
%     testfiles_dir = strcat(test_dir, '\Test-', string(k));
%     dest_dir = strcat('Testset\', 'T_0',string(k));
% 
% 
% imds_test = imageDatastore(testfiles_dir, "IncludeSubfolders", true, 'FileExtensions','.dcm', 'LabelSource','foldernames');
% label_count = countEachLabel(imds_test);
% test_folder_list = string(table2array(label_count(:,1)));
% num_test_folder = length(test_folder_list);
% 
% for i = 1:num_test_folder
% 
%     test_folder_list(i) = strcat(testfiles_dir,'\', test_folder_list(i));
% 
% end
% 
% 
% for j = 1:num_test_folder
% 
%     volume_file = strcat(test_folder_list(j), '\IM0001.dcm');
%     volume_info = dicominfo(volume_file);
% 
%     volume_data = dicomreadVolume(test_folder_list(j));
%     Slice_Thickness = volume_info.SliceThickness;
%     Pixel_Spacing = volume_info.PixelSpacing(1);
%     
%     if exist(dest_dir) == 0
% 
%         mkdir(dest_dir)
% 
%     end
% 
%     filename = strcat(dest_dir, '\T', string(k), '_00', string(j));
% 
%     save(filename,'volume_data', "Slice_Thickness", "Pixel_Spacing");
% 
% end
% end

%% Matfile Volumes into volumes with percentage of saliency


VA_t = [0.6; 0.7; 0.8];

%imds_T1 = imageDatastore('Testset\T_01', 'FileExtensions','.mat');
%imds_T2 = imageDatastore('Testset\T_02', 'FileExtensions','.mat');
%imds_T3 = imageDatastore('Testset\T_03', 'FileExtensions','.mat');
%imds_T4 = imageDatastore('Testset\T_04', 'FileExtensions','.mat');


for i = 1:3

    dest_dir = strcat('Testset\', 'T', string(VA_t(i) * 100));




    for ii = 1:4

        test_dir = strcat('Testset\T_0', string(ii));
        imds_T = imageDatastore(test_dir, 'FileExtensions','.mat');

        for k = 1: length(imds_T.Files)

            load(imds_T.Files{k})

            data = volume_data;
            PixelSpacing = Pixel_Spacing;
            SliceThickness = Slice_Thickness;


            data = mat2gray(squeeze(data));
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
    
    for kk = 1:d3
        
        lung_mask = resampled_data(:,:,kk)>0;
       
        lungarea(kk,1) = lungarea_detect(lung_mask);
        
    end
    
    max_lungarea_value = max(lungarea);
    lungarea = lungarea ./ max_lungarea_value;
    
    selected_slice = find(lungarea >= VA_t(i));
    new_data = resampled_data(:,:,selected_slice(1) : selected_slice(end));
    [d1_new, d2_new, d3_new] = size(new_data);
    
    
    
    crop_coefficient = 1- 0.25 * rand(1,1);
    target_cropsize = [round(d1_new * crop_coefficient), round(d2_new * crop_coefficient), d3_new];
    win_crop = centerCropWindow3d(size(new_data), target_cropsize);
    crop_data = imcrop3(new_data, win_crop);
    inputdata = imresize3(crop_data, [224 224 224], 'cubic');
    
    inputdata(isnan(inputdata)) = 0;
    inputdata(inputdata <= 0) = 0;
    
    [matfile_path, matfile_name, matfile_ext] = fileparts(imds_T.Files{k});
    if exist(dest_dir) == 0
        mkdir(dest_dir)
    end


    MatFileName = strcat(dest_dir, '\',matfile_name);
    
    
    save(MatFileName,'inputdata');

        end


    end

end

