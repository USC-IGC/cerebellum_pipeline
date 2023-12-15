# CEREBELLUM PIPELINE
The LoBeS Cerebellum Pipeline provides wrappers to run ACAPULCO pipeline for cerebellum parcellation and AFNI on MP2RAGE acquired images as well as provides a multilevel QC approach.  

## Pipeline Workflow
The Cerebellum Pipeline contains scripts that have be run in the following order:
| Script to be run by user | Inherently calls |
|--------------------------|------------------|
| [script_01_AC3.sh](#script_01_AC3.sh)         | - Acapulco_030.sif |
|                          | - AFNI, R, PYTHON softwares |
| [check_if_csv_exists.py](#check_if_csv_exists.py)   |                  |
| [script_02_QC.sh](#script_02_QC.sh)          |  - colormap.txt  |
|                          |  - cerebellum_image_generator.py |
| [make_html.sh](#make_html.sh)             | 									|
| [combine_csvs.py](#combine_csvs.py)          |                  |

### script_01_AC3.sh<a name="script_01_AC3.sh"></a>  
This script is a wrapper to run ACAPULCO 3.0 for cerebellum parcellation for a single subject on a linux cluster. It creates a subject folder with the given subjectID inside the given output directory. This script also runs AFNI on MP2RAGE acquired images so that they can be handled properly by AC3.  

#### ACAPULCO 3 (AC3)
This is a cerebellum parcellation pipeline. Automatic Cerebellum Anatomical Parcellation Using U-Net with Locally Constrained Optimization (ACAPULCO) located at `https://iacl.ece.jhu.edu/index.php?title=Cerebellum_CNN` version 3 is an updated pipeline that is different from its previous software versions due to its repeatability, use of same weight metrics for the CNNs during parcellation and its nature to generate a more limited set of files thereby saving storage space. The AC3 pipeline is run through a singularity container (`Acapulco_030.sif`) which inherently does n4 bias correction -> registration to MNI template -> parcellation.  
Downloading Acapulco_030.sif: The .sif file can be downloaded from the above website by right clicking on `Singularity image CPU` and choosing save link as.
#### MP2RAGE Acquisition Image Handling  
We noticed that AC3 did not perform well on T1w MP2RAGE acquired images and hence have added an __AFNI__ step to handle such images to improve the AC3 failure rate.  
__Background:__
MP2RAGE collects 2 sets of Gradient Echo signals for each inversion pulse using 2 turbo flash GREs. The first inversion pulse (inv1) inverts the longitudinal magnetization of all tissues, while the second inversion pulse (inv2) selectively nulls the signal from cerebrospinal fluid (CSF) in order to improve the contrast between gray matter (GM) and white matter (WM). The UNIT method is a modification of the original MP2RAGE sequence that aims to improve the uniformity of image intensity across the brain, helping in improving the contract of the image. Any subject acquired this way has UNIT, INV2 and INV1 images available.  
We perform the following functions defined in AFNI, a software developed for the analysis and display of anatomical and functional MRI (FMRI) data, on the inv2 and UNIT images  
* `3dcopy`, to make the inv2 available for AFNI  
* `3dinfo`, to extract maximum and minimum intensities of the inv2  
* `3dcalc`, to apply these intensity mappings on the UNIT image by taking a mean at each point of inv2 and then multiplying it with UNIT images intensity.  
The output of this step becomes the input to AC3.  
##### Prerequisites
The AFNI software requires R and Python to be pre-installed on your system.  
#### Anatomy of script_01_AC3.sh call:
    script_01_AC3.sh --subject <subjectID> --input <T1/image/path> --outdir <output/directory> 
                     --container <singularity/directory> --bind <singularity/bind/directory> 
                     --mp2rage <mp2rage/acquisition/true/false> --inv2image <inv2image/path/(optional)> 
                     --afnipath <AFNI/software/path/(optional)>   

`--subject`: This the subjectID to be run  
`--input`: The absolute path to the T1 image of the subject  
`--outdir`: The absolute path of the directory where you want to store the AC3 outputs  
`--container`: The absolute path to where the AC3 singularity container is located  
`--bind`: The absolute path to where you want to bind the AC3 singularity container  
`--mp2rage`: If the input image is an MP2RAGE acquisition enter true else false  
`--inv2image`: Path to Inv2 image of a subject if it is MP2RAGE acquired (optional)  
`--afnipath`: path to AFNI software (optional)  

Example 1: ``./script_01_AC3.sh --subject subject0000 --input /mypath/mydirectory/subject0000/sub-0000_T1.nii.gz --outdir /mypath/mydirectory --container /mypath/mydirectory/acapulco_030.sif --bind /mypath --mp2rage false``  

Example 2: ``./script_01_AC3.sh --subject subject0000 --input /mypath/mydirectory/subject0000/sub-0000_UNIT1.nii.gz --outdir /mypath/mydirectory --container /mypath/mydirectory/acapulco_030.sif --bind /mypath --mp2rage true --inv2image /mypath/mydirectory/subject0000/sub-0000_inv-2_MP2RAGE.nii.gz --afnipath /mypath/mydirectory/software/AFNI ``  

A qsub wrapper can be created by the user for this script to run for large cohorts.  

### check_if_csv_exists.py<a name="check_if_csv_exists.py"></a>  
Not needed when running for a single subject but very useful when running AC3 on large cohorts.  
This script identifies the subjects that AC3 failed to generate outputs for by checking if xxxx_n4_mni_seg_post_volumes.csv file exists as it is the last generated output of a successful AC3 run. It generates another text file containing the failed subset of subjects which can be used as the new input to script_01_AC3.sh especially when running large cohorts.  

#### Anatomy of check_if_csv_exists.py call:
    python check_if_csv_exists.py -i <AC3/output/directory>     

Example:``python check_if_csv_exists.py -i /mypath/mydirectory``  
`-i`: The absolute path to the AC3 output directory containing the subjects folders  

### script_02_QC.sh<a name="script_02_QC.sh"></a>  
This script is a wrapper for `cerebellum_image_generator.py`.  

#### colormap.txt
This text file contains the labels and the RGB values for the 28 Cerebellum ROIs.  
#### cerebellum_image_generator.py
This script is inherently called by `script_02_QC.sh`. It assigns colors to cerebellum ROIs in the slice image based on the `colormap.txt` and overlays it on the input image with some transparency so that the underlaying anatomy is visible. It also checks for any over/incorrect segmentations outside a defined cerebellum bounding box (the dimensions of the bounding box have been chosen based on where one might expect to locate the cerebellum in a 3D image) and generates a text file containing the subject names if they failed the check. It generates an img folder within the output directory that contains .png files of the various anatomical views(axial/coronal/sagittal) and 10 slices per view of a subject which show maximum information of the cerebellum ROIs required for QC.  
#### Anatomy of script_02_QC.sh call:
    script_02_QC.sh --subject <subjectID> --input </path/mni/xxxx_n4_mni.nii.gz> --slice </path/parc/xxxx_n4_mni_seg_post.nii.gz> --outdir <output/directory> 
                    --imagegen <cerebellum_image_generator.py/path> --label <colormap.txt> --bbfile <boundingboxfile/path/>   

`--subject`: This the subjectID to be run  
`--input`: The absolute path to the Input image (This is the /mni/xxxx_n4_mni.nii.gz inside AC3 output directory of a subject)  
`--slice`: The absolute path to the Slice image (This is the /parc/xxx_n4_mni_seg_post.nii.gz inside AC3 output directory of a subject)  
`--outdir`: The absolute path to the output directory to store pngs  
`--imagegen`:  Path to cerebellum_image_generator.py  
`--label`: Path to colormap.txt file  
`--bbfile`: Path along with textfile name to store bounding box failed subjects  

Example: ``./script_02_QC.sh --subject subject0000 --input /mypath/mydirectory/subject0000/mni/subject0000_T1_n4_mni.nii.gz --slice /mypath/mydirectory/subject0000/parc/subject0000_T1_n4_mni_seg_post.nii.gz --outdir /mypath/mydirectory/QC --imagegen /mypath/mydirectory/cerebellum_image_generator.py --label /mypath/mydirectory/ --bbfile /mypath/mydirectory/QC/BoundingBox_failed_subjects.txt``  

A qsub wrapper can be created by the user for this script to run for large cohorts.  

### make_html.sh<a name="make_html.sh"></a>    

This script generates two htmls - 1 sagittal and 1 coronal containing 5 slices/view which show all the 28 ROIs for fast QC.
The logic in each of the html dictates that all subjects are QC Pass unless the subjectID button is clicked upon. Upon clicking the subjectID button, it is identified as QC Fail and is disabled. A notes box is present to add reasoning for the failure.
At the end of each Html a `Download CSV` button is present which downloads the Subject list along with QC info as a CSV.
Each html generates its own csv file which can be merged at the end. 
The Html has the same properties of any other webpage which allows the user to save individual images to their local desktop or view them in a new tab on a search engine. 
#### Prerequisites
A text file with all subject names/IDs in a cohort.  
#### Anatomy of make_html call:
    make_html.sh --subjects <subjects_list.txt> --pngdir <png/directory> --name <html/name>   

`--subjects`: The absolute path to the text file containing a list of subject IDs  
`--pngdir`: The absolute path to the directory containing the img folder  
`--name`: Name of the html to be generated  

Example:``./make_html.sh --subjects /mypath/mydirectory/subjects_list.txt --pngdir /mypath/mydirectory/QC --name QC_Cohort1``  
Outputs: __QC_Cohort1_coronal.html__ and __QC_Cohort1_sagittal.html__  
CSVs: __AC3_QC_Coronal.csv__ and __AC3_QC_Sagittal.csv__  
Merging the two csvs: Merging the two CSVs can be done either in python or R to get the complete list of QC failed subjects taking both the views into account.  
Here are some examples of the Html:  
__Coronal View__  
![Example of Coronal View Html](https://github.com/USC-IGC/cerebellum_pipeline/blob/main/images/Html_Coronal_View_Example.png)  
__Sagittal View with Download CSV button__  
![Example of Sagittal View Html](https://github.com/USC-IGC/cerebellum_pipeline/blob/main/images/Html_Sagittal_View_Example.png)  

#### Notes on QC:  
As mentioned earlier the pipeline ensures that the data is QC'ed at every level.
* The first level of QC is done by `check_if_csv-exists.py` which identifies unsuccessful run of AC3 on a subject.
* The second level of QC is done by `cerebellum_image_generator.py` which identifies the subjects that have segmentations outside the cerebellum bounding box.
* The third level of QC is through the Htmls which help the user to visually check for failures of over/under/mis segmentations and take notes on it. Here is the key for the Cerebellum labels.  
__Cerebellum Labels Key:__  
![Cerebllum labels key ](https://github.com/USC-IGC/cerebellum_pipeline/blob/main/images/Cerebellum_Labels.jpg)  

* The Htmls only consider 5 slices per view but for the user's ease, the `img` folder has 10 slices per anatomical view which can further aid in QC.
* In some cases it is also advisable to view /parc/xxx_n4_mni_seg_post.nii.gz overlayed on /mni/xxxx_n4_mni.nii.gz in image viewing softwares like Fslview and FSLeyes to further ascertain failure.  

Here are some examples of the failure cases:  
__QC Fail Example 1 in Coronal View__  
![Example 1 of QC Fail in Coronal View ](https://github.com/USC-IGC/cerebellum_pipeline/blob/main/images/Html_Coronal_View_AC3Fail_Example1.png)  
This case requires a little bit of caution by the user as the Corpus Medullare is being identified as Right VI. Such mis segmentation can only be identified if the user is familiar with the `Cerebellum_Labels_Key` 
 
__QC Fail Example 1 in Sagittal View__  
![Example 1 of QC Fail in Sagittal View ](https://github.com/USC-IGC/cerebellum_pipeline/blob/main/images/Html_Sagittal_View_AC3Fail_Example1.png)  

__QC Fail Example 2 in Sagittal View__  
![Example 2 of QC Fail in Sagittal View ](https://github.com/USC-IGC/cerebellum_pipeline/blob/main/images/Html_Sagittal_View_AC3Fail_Example2.png)  
This case would have been identified in the `BoundingBox_failed_subjects.txt` file as well since the segmentation is beyond the FOV.
  
### combine_csvs.py  

Not needed for a single subject but is very useful for large cohorts.  
It merges the .csvs obtained as part of AC3 of all the subjects in a cohort to generate a master spreadsheet.  
#### Anatomy of combine_csvs.py call:
    python combine_csvs.py -i <AC3/output/directory> -o <output/directory>      

Example:``python combine_csvs.py -i /mypath/mydirectory -o /mypath/mydirectory/QC``   

`-i`: The absolute path to the AC3 output directory containing all the subjeect folders  
`-o`: The absolute path to where you want to save the combined csv  

 ## References
* S. Han, A. Carass, Y. He, and J.L. Prince, "Automatic Cerebellum Anatomical Parcellation using U-Net with Locally Constrained Optimization", NeuroImage, 218:116819, 2020.
* RW Cox. AFNI: Software for analysis and visualization of functional magnetic resonance neuroimages. Computers and Biomedical Research, 29:162-173, 1996.  
* RW Cox and JS Hyde. Software tools for analysis and visualization of FMRI Data. NMR in Biomedicine, 10:171-178, 1997.  
* S Gold, B Christian, S Arndt, G Zeien, T Cizadlo, DL Johnson, M Flaum, and NC Andreasen. Functional MRI statistical software packages: a comparative analysis. Human Brain Mapping, 6:73-84, 1998.  
