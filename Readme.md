# Structual MRI data analysis
## preprocessing by freesurfer
+ Kim, D., et al., & Lee, J. S. (2024). Improving 18F-FDG PET Quantification Through a Spatial Normalization Method. Journal of Nuclear Medicine, 65(10), 1645–1651. doi:10.2967/jnumed.123.267360
+ [freesurfer tutorial website](https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/PracticeV6.0)
### Usage
`2parallel_reconall.sh`could used to execute following steps:
 - Finding the dicoms for all subjects.
   - `script_loop_folder.sh` has the same separate fundtion.
 - Identifying the T1-weighted image.
   - `dcmunpack.sh` has the same separate fundtion.
 - Performs all, or any part of, the FreeSurfer cortical reconstruction process.
   - ```recon-all -all -i I50 -s  Subj001```
   - `reconall`has the same separate fundtion.
 - Parallel batching analysis.
   - This approach leverages GNU Parallel to run multiple instances of recon-all simultaneously, improving efficiency.
   - Ensure GNU Parallel is installed by running:
   ```
    sudo apt-get install parallel
   ```

### Note
Following code must be kept, or you could not use the _dcmunpack_ and _recon-all_.
```
export FREESURFER_HOME="/path/to/freesurfer"
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export FS_LOAD_DWI=0
```
----
