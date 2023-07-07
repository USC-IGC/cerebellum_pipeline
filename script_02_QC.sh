#!/bin/bash
# 06/27/2023
# Cerebellum QC
# This script is to be run on the outputs of script_01_AC3.sh
# Written by Iyad Ba Gari and Siddharth Narula

function Usage(){
    cat << USAGE

Usage:

$(basename "$0") --subject <subjectID> --input </mni/xxxx_n4_mni.nii.gz/path> --slice </parc/xxxx_n4_mni_seg_post.nii.gz> --outdir <output/directory> --play <cerebellum_playbook.py/path> --color <colormap.txt> 

Mandatory arguments:
    --subject   Provide a subject ID
    --input     Input image (This is the /mni/xxxx_n4_mni.nii.gz inside AC3 output directory of a subject)
    --slice     Slice image (This is the /parc/xxx_n4_mni_seg_post.nii.gz  inside AC3 output directory of a subject)
    --outdir    Output directory to store pngs
    --play      cerebellum_playbook.py script path
    --color     colormap.txt file path

Please provide absolute path in all arguments

USAGE
    exit 1
}

if [[ $# -eq 0 ]]; then
    Usage >&2
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            Usage >&2
            exit 0
            ;;
        --subject)
            subjectID=$2
            shift 2
            ;;
        --input)
            input_image=$2
            shift 2
            ;;
        --slice)
            slice_image=$2
            shift 2
            ;;
        --outdir)
            output_dir=$2
            shift 2
            ;;
        --play)
            playbook_dir=$2
            shift 2
            ;;
        --color)
            colormap_txt=$2
            shift 2
            ;;
        *) # Unexpected option
            Usage >&2
            ;;
    esac
done

# Checking mandatory arguments
if [[ -z ${subjectID} || -z ${input_image} ||  -z ${slice_image} || -z ${output_dir} || -z ${playbook_dir} || -z ${colormap_txt} ]]; then
	echo "ERROR: --subject --input, --slice, --outdir, --bind are mandatory arguments. Please see usage: \n"
    Usage >&2
fi

echo "Running QC for ${subjectID}"
echo "Input Image: ${input_image}"
echo "Slice Image: ${slice_image}"
echo "Output Directory: ${output_dir}/img/${subjectID}"
rm -rf ${output_dir}/img/${subjectID}
mkdir -p ${output_dir}/img/${subjectID}

echo "Cerebellum playbook located at: ${playbook_dir}"
echo "Colormap text file: ${colormap_txt}"

python ${playbook_dir}/cerebellum_playbook.py -i $input_image -l $slice_image -c ${colormap_txt}/colormap.txt -o ${output_dir}/img/${subjectID}/coronal -v coronal
echo "Done generating coronal pngs at: ${output_dir}/img/${subjectID}/coronal"
python ${playbook_dir}/cerebellum_playbook.py -i $input_image -l $slice_image -c ${colormap_txt}/colormap.txt -o ${output_dir}/img/${subjectID}/sagittal -v sagittal
echo "Done generating sagittal pngs at: ${output_dir}/img/${subjectID}/sagittal"       
python ${playbook_dir}/cerebellum_playbook.py -i $input_image -l $slice_image -c ${colormap_txt}/colormap.txt -o ${output_dir}/img/${subjectID}/axial -v axial
echo "Done generating axial pngs at: ${output_dir}/img/${subjectID}/axial"

echo "Done generating all pngs at: ${output_dir}/img/${subjectID}"
