# RoI-Aware-ResNet
RoI-Aware ResNet for COVID-19 volumetric CT-Scans 


## Pre=processing the DICOM Files
As the origianl dataset [COVID-CT-MD](https://doi.org/10.1038/s41597-021-00900-3) comes in DICOM format that each DICOM folder corresponds to one 3D volume comprised of all 2D slices. Hence, the first step is to transfer the DICOM files into '.mat' file so they can be fed into MATLAB deep learning framework. The method is demonstrated in the code


## Pre-trained 3D ResNet Downloads
Note that the backbone pre-trained 3D ResNets (for MATLAB only) can be downloaded via: \
[3D ResNet-18](https://uk.mathworks.com/matlabcentral/fileexchange/82585-pre-trained-3d-resnet-18)\
[3D ResNet-50](https://uk.mathworks.com/matlabcentral/fileexchange/87427-pre-trained-3d-resnet-50)\
[3D ResNet-101](https://uk.mathworks.com/matlabcentral/fileexchange/87432-pre-trained-3d-resnet-101)


<!-- LICENSE -->
## License

Distributed under the The GNU General Public License v3.0. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>


## Author's Biography

Charith Abhayaratne(M’98) received the B.E. degree in electrical and electronic engineering from The University of Adelaide, Australia, in 1998, and the Ph.D. degree in electronic and electrical engineering from the University of Bath, U.K., in 2002. He was a recipient of the European Research Consortium for Informatics and Mathematics (ERCIM) Post-Doctoral Fellowship (2002-2004) to carry out research at the Centre of Mathematics and Computer Science (CWI), The Netherlands, and the National Research Institute for Computer Science and Control (INRIA), Sophia Antipolis, France.  He is currently a Lecturer with the Department of Electronic and Electrical Engineering, The University of Sheffield, U.K. His research interests include visual content analysis, visual content security, machine learning and multidimensional signal processing. He has published over 90 peer reviewed papers in leading journals, conferences and book editions. Currently, he serves as an associate editor for IEEE Transactions on Image Processing, IEEE Access and Elsevier Journal of Information Security and Applications (JISA). 

<img src="Images/charith_2022.jpg" width="180" height="240">

Shuohan XUE received the B.E. degree in Mechatronics Engineering from The North University of China, Shanxi, China, in 2015, and the MSc degree in electronic and electrical engineering from the University of Sheffield, U.K., in 2019. He is currently a Ph.D. student in the Department of Electronic and Electrical engineering in The University of Sheffield. 

<img src="Images/xue.jpg" width="180" height="240">

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments
