# CEREBELLUM PIPELINE
The LoBeS Cerebellum Pipeline includes the usage of ACAPULCO pipeline for cerebellum parcellation followed by QC scripts
## ACAPULCO 3 (AC3)
This is a cerebellum parcellation pipeline. Automatic Cerebellum Anatomical Parcellation Using U-Net with Locally Constrained Optimization (ACAPULCO) located at `https://iacl.ece.jhu.edu/index.php?title=Cerebellum_CNN` version 3 is an updated pipeline that is different from its previous software versions due to its repeatability, use of same weight metrics for the CNNs during parcellation and its nature to generate a more limited set of files thereby saving storage space. The AC3 pipeline is run through a singularity container (`Acapulco_030.sif`) which inherently does n4 bias correction -> registration to MNI template -> parcellation
## Pipeline Workflow
The Cerebellum Pipeline contains scripts that have be run in the following order:
| Script to be run by user | Inherently calls |
|--------------------------|------------------|
| script_01_AC3.sh         | Acapulco_030.sif |
| check_if_csv_exists.py   |                  |
| script_02_QC.sh          |  - colormap.txt  |
|                          |  - cerebellum_playbook.py |
| make_html.sh             | 									|
| combine_csvs.py          |                  |

### script_01_AC3.sh
This script is a wrapper to run AC3 for cerebellum parcellation for a single subject on a linux cluster. It creates a subject folder with the given subjectID inside the given output directory.
#### Anatomy of script_01_AC3.sh call:
``./script_01_AC3.sh --subject <subjectID> --input <T1/image/path> --outdir <output/directory> --container <singularity/directory> --bind <singularity/bind/directory>``
  
Example: ``./script_01_AC3.sh --subject subject0000 --input /ifs/loni/faculty/mydirectory/subject0000_T1.nii.gz --outdir /ifs/loni/faculty/mydirectory --container /ifs/loni/faculty/mydirectory --bind /ifs/loni/faculty`` 

`--subject`: This the subjectID to be run  
`--input`: The absolute path to the T1 image of the subject  
`--outdir`: The absolute path of the directory where you want to store the AC3 outputs  
`--container`: The absolute path to where the AC3 singularity container is located  
`--bind`: The absolute path to where you want to bind the AC3 singularity container  
A qsub wrapper can be created by the user for this script to run for large cohorts.
### check_if_csv_exists.py
Not needed when running for a single subject but very useful when running AC3 on large cohorts.
This script identifies the subjects that AC3 failed to generate outputs for. It generates another text file containing the failed subset of subjects which can be used as the new input to script_01_AC3.sh especially when running large cohorts.
#### Anatomy of check_if_csv_exists.py call:
``python check_if_csv_exists.py -i <AC3/output/directory>``  

Example:``python check_if_csv_exists.py -i /ifs/loni/faculty/mydirectory``  
`-i`: The absolute path to the AC3 output directory containing the subjects folders
### script_02_QC.sh
This script generates an img folder containing .png files of the various anatomical views(axial/coronal/sagittal) and 10 slices per view of a subject which show maximum information of the cerebellum ROIs required for QC.
#### Anatomy of script_02_QC.sh call:
``./script_02_QC.sh --subject <subjectID> --input </path/mni/xxxx_n4_mni.nii.gz> --slice </path/parc/xxxx_n4_mni_seg_post.nii.gz> --outdir <output/directory> --play <cerebellum_playbook.py/path> --color <colormap.txt> ``
  
Example: ``./script_02_QC.sh --subject subject0000 --input /ifs/loni/faculty/mydirectory/subject0000/mni/subject0000_T1_n4_mni.nii.gz --slice /ifs/loni/faculty/mydirectory/subject0000/parc/subject0000_T1_n4_mni_seg_post.nii.gz --outdir /ifs/loni/faculty/mydirectory/QC --play /ifs/loni/faculty/mydirectory/cerebellum_playbook.py --color /ifs/loni/faculty/mydirectory/colormap.txt``  

`--subject`: This the subjectID to be run  
`--input`: The absolute path to the Input image (This is the /mni/xxxx_n4_mni.nii.gz inside AC3 output directory of a subject)  
`--slice`: The absolute path to the Slice image (This is the /parc/xxx_n4_mni_seg_post.nii.gz  inside AC3 output directory of a subject)  
`--outdir`: The absolute path to the output directory to store pngs  
`--play`: The absolute path to `cerebellum_playbook.py`  
`--color`: The absolute path to `colormap.txt`  
A qsub wrapper can be created by the user for this script to run for large cohorts.  
##### colormap.txt
This text file contains the labels and the RGB values for the 28 Cerebellum ROIs.
##### cerebellum_playbook.py
This script is inherently called by `script_02_QC.sh`. It assigns colors to cerebellum ROIs in the slice image based on the `colormap.txt` and overlays it on the input image. It also checks for any over/incorrect segmentations outside a defined cerebellum bounding box and generates a text file containing the subject names if they failed the check.  
### make_html.sh
This script gnerates an html containing all the pngs of the subjects in cohort for QC.  
#### Prerequisites
A text file with all subject names/IDs in a cohort.  
#### Anatomy of make_html call:
``./make_html.sh --subjects <subjects_list.txt> --pngdir <png/directory> --name <html/name>``  

Example:``./make_html.sh --subjects /ifs/loni/faculty/mydirectory/subjects_list.txt --pngdir /ifs/loni/faculty/mydirectory/QC --name QC_Cohort1``  

`--subjects`: The absolute path to the text file containing a list of subject IDs  
`--pngdir`: The absolute path to the directory containing the img folder  
`--name`: Name of the html to be generated  
### combine_csvs.py
Not needed for a single subject but is very useful for large cohorts.
It merges the .csvs obtained as part of AC3 of all the subjects in a cohort to generate a master spreadsheet.
#### Anatomy of combine_csvs.py call:
``python combine_csvs.py -i <AC3/output/directory> -o <output/directory>``  

Example:``python combine_csvs.py -i /ifs/loni/faculty/mydirectory -o /ifs/loni/faculty/mydirectory/QC``   

`-i`: The absolute path to the AC3 output directory containing all the subjeect folders
`-o`: The absolute path to where you want to save the combined csv
