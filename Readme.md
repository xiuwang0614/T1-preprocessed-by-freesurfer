#Structual MRI data analysis
## preprocessing by freesurfer
+ Kim, D., et al., & Lee, J. S. (2024). Improving 18F-FDG PET Quantification Through a Spatial Normalization Method. Journal of Nuclear Medicine, 65(10), 1645–1651. doi:10.2967/jnumed.123.267360
+ [freesurfer tutorial website](https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/PracticeV6.0)
### Usage
`parallel_reconall.sh`could used to following steps:
 - Finding the dicoms for all subjects.
  - `script_loop_folder.sh` has the same separate fundtion.
 - Identifying the T1-weighted image.
  - `dcmunpack.sh` has the same separate fundtion.
 - Performs all, or any part of, the FreeSurfer cortical reconstruction process.
  - ```recon-all -all -i I50 -s  Subj001```
  - `reconall`has the same separate fundtion.
 - Parallel proposed.
----
