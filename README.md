# Region-of-Interest Aware 3D ResNet for COVID-19 CT Scan Classification

[![License](https://img.shields.io/badge/license-CC%20BY%204.0-blue)](https://creativecommons.org/licenses/by/4.0/) [![Paper DOI](https://img.shields.io/badge/DOI-10.1109/ACCESS.2023.3260632-blue)](https://doi.org/10.1109/ACCESS.2023.3260632)

This repository contains the implementation of the Region-of-Interest (RoI) Aware 3D ResNet model for the classification of COVID-19, Community Acquired Pneumonia (CAP), and Normal cases from volumetric chest CT scans. The model and its methodology are detailed in our IEEE Access paper:

> **S. Xue and C. Abhayaratne**, "Region-of-Interest Aware 3D ResNet for Classification of COVID-19 Chest Computerised Tomography Scans," *IEEE Access*, vol. 11, pp. 28856-28871, 2023. DOI: [10.1109/ACCESS.2023.3260632](https://doi.org/10.1109/ACCESS.2023.3260632).

## Key Features

- **RoI-Aware Architecture**: Incorporates RoI masking to enhance feature learning and improve classification accuracy.
- **Single-Stage 3D Approach**: Eliminates the need for slice-wise annotations, simplifying data preparation.
- **State-of-the-Art Results**: Achieves 90% overall accuracy with the RoI-aware 3D ResNet-101.
- **Explainable AI**: Utilizes 3D Grad-CAM for visualizing class activation regions in the CT scans.

## Dataset

The model is evaluated using the publicly available **COVID-CT-MD** dataset, consisting of 231 volumetric chest CT scans:
- **171 COVID-19 cases**
- **60 CAP cases**
- **76 Normal cases**

For details on obtaining the dataset, please refer to the [COVID-CT-MD repository](https://github.com/icassp21-covid19-spgc).

## Installation

### Pre-trained 3D ResNet Downloads
Note that the backbone pre-trained 3D ResNets (for MATLAB only) can be downloaded via: \
[3D ResNet-18](https://uk.mathworks.com/matlabcentral/fileexchange/82585-pre-trained-3d-resnet-18)\
[3D ResNet-50](https://uk.mathworks.com/matlabcentral/fileexchange/87427-pre-trained-3d-resnet-50)\
[3D ResNet-101](https://uk.mathworks.com/matlabcentral/fileexchange/87432-pre-trained-3d-resnet-101)

### Prerequisites
- MATLAB R2022b or later (for preprocessing and training)
- GPU support (recommended: NVIDIA RTX 2080 Ti or equivalent)


### MATLAB Dependencies
Ensure that MATLAB has the following toolboxes installed:
- Deep Learning Toolbox
- Image Processing Toolbox

## Usage

### Data Preprocessing
Prepare the volumetric CT scans by segmenting the lungs, resampling the volumes, and extracting salient slices. Use the MATLAB script provided:
```matlab
run('preprocess_data.m')
```

### Training the Model
Train the RoI-aware 3D ResNet using the provided MATLAB code:
```matlab
run('train_model.m')
```

### Evaluation
Evaluate the trained model on the test set using:
```matlab
run('evaluate_model.m')
```

### Visualization
Generate 3D Grad-CAM visualizations to interpret the predictions:
```matlab
run('visualize_gradcam.m')
```

## Results
The proposed RoI-aware 3D ResNet-101 achieved:
- **Overall Accuracy**: 90%
- **Sensitivity**:
  - COVID-19: 88.2%
  - CAP: 96.4%
  - Normal: 96.1%
- **Specificity**:
  - COVID-19: 91.7%
  - CAP: 80.0%
  - Normal: 97.1%

Refer to the `results` folder for detailed results and confusion matrices.

## Directory Structure
```
.
├── data/               # Directory for input datasets and preprocessed data
├── src/                # Core MATLAB source code for the project
│   ├── preprocess/     # Scripts for data preprocessing
│   ├── training/       # Training-related scripts
│   ├── evaluation/     # Scripts for evaluation and metrics calculation
│   ├── visualization/  # Scripts for 3D Grad-CAM and result visualization
├── models/             # Directory for saving trained models
├── results/            # Outputs including metrics, visualizations, and logs
├── LICENSE             # License information
└── README.md           # Project documentation
```

## Citation
If you use this code or dataset in your research, please cite our paper:

```bibtex
@article{xue2023roi,
  title={Region-of-Interest Aware 3D ResNet for Classification of COVID-19 Chest Computerised Tomography Scans},
  author={Xue, Shuohan and Abhayaratne, Charith},
  journal={IEEE Access},
  volume={11},
  pages={28856-28871},
  year={2023},
  publisher={IEEE}
}
```




## Author's Biography

Shuohan XUE received the B.E. degree in Mechatronics Engineering from The North University of China, Shanxi, China, in 2015, and the MSc degree in electronic and electrical engineering from the University of Sheffield, U.K., in 2019. He is currently a Ph.D. student in the Department of Electronic and Electrical engineering in The University of Sheffield. 

<img src="Images/xue.jpg" width="150" height="200">

Charith Abhayaratne(M’98) received the B.E. degree in electrical and electronic engineering from The University of Adelaide, Australia, in 1998, and the Ph.D. degree in electronic and electrical engineering from the University of Bath, U.K., in 2002. He was a recipient of the European Research Consortium for Informatics and Mathematics (ERCIM) Post-Doctoral Fellowship (2002-2004) to carry out research at the Centre of Mathematics and Computer Science (CWI), The Netherlands, and the National Research Institute for Computer Science and Control (INRIA), Sophia Antipolis, France.  He is currently a Lecturer with the Department of Electronic and Electrical Engineering, The University of Sheffield, U.K. His research interests include visual content analysis, visual content security, machine learning and multidimensional signal processing. He has published over 90 peer reviewed papers in leading journals, conferences and book editions. Currently, he serves as an associate editor for IEEE Transactions on Image Processing, IEEE Access and Elsevier Journal of Information Security and Applications (JISA). 

<img src="Images/charith_2022.jpg" width="150" height="200">
