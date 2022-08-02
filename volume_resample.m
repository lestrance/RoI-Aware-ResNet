function [new_SPECT] = volume_resample(SPECT, SPECTPixelSpacing, SpacingCoefficient,  SPECTSliceThickness, ThicknessCoefficient)




SPECT = squeeze(double(SPECT));


[rows, columns, slices] = size(SPECT);
%SPECTPixelSpacing = SPECTinfo.PixelSpacing;  
%SPECTSliceThickness = SPECTinfo.SliceThickness;

% define original SPECT meshgrid
[Xold, Yold, Zold] = meshgrid(SPECTPixelSpacing(1)*[0:1:size(SPECT, 2)-1],...
                 SPECTPixelSpacing(1)*[0:1:size(SPECT, 1)-1],...
            SPECTSliceThickness*[0:1:size(SPECT, 3)-1]);
        
        
        
% define CT PixelSpacing (these values are taken from CT images)
n = SPECTPixelSpacing * SpacingCoefficient;
CTPixelSpacing = [n,n];
CTSliceThickness = SPECTSliceThickness * ThicknessCoefficient;


% define the new SPECT matrix using meshgrid
[Xnew, Ynew, Znew] = meshgrid(SPECTPixelSpacing(1)*[0:CTPixelSpacing(2)/SPECTPixelSpacing(1):size(SPECT, 2)],...
              SPECTPixelSpacing(1)*[0:CTPixelSpacing(1)/SPECTPixelSpacing(1):size(SPECT, 1)],...
      SPECTSliceThickness*[0:CTSliceThickness/SPECTSliceThickness:size(SPECT, 3)]);
% calculate the 3D interpolation
new_SPECT = interp3(Xold, Yold, Zold, SPECT, Xnew, Ynew, Znew, 'cubic');





end